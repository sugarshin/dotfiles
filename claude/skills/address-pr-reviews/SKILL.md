---
name: address-pr-reviews
description: PRレビューコメントを Claude + Codex デュアル評価で精査し、修正 or 返信を実行する
disable-model-invocation: true
argument-hint: "<PR URL>"
---

# Address PR Reviews (Dual Evaluation — Team Orchestration)

PR 上の未解決レビューコメントを取得し、Claude と Codex で並列に精査・評価。
チーム内のエージェントが相互レビュー・クロスチェックを経て最終判断し、修正が必要ならコード修正、不要なら PR 上で返信する。

## Input

PR URL: $ARGUMENTS

## Step 1: PR 情報取得

1. PR URL からオーナー、リポジトリ名、PR番号を解析する:
   - URL形式: `https://github.com/<OWNER>/<REPO>/pull/<NUMBER>`
   - `$OWNER`, `$REPO_NAME`, `$PR_NUMBER` として保持

2. PR 情報を `gh` で取得:
   ```bash
   gh pr view "$PR_NUMBER" --repo "$OWNER/$REPO_NAME" --json title,body,state,headRefName,baseRefName,url
   ```

3. PR URL のリポジトリがカレントリポジトリと一致するか検証する:
   - `git remote get-url origin` と比較
   - 不一致の場合は「このPRはカレントリポジトリのものではありません」と伝えて終了

4. PR の `state` を確認:
   - `OPEN` → 続行
   - `MERGED` / `CLOSED` → ユーザーに通知して終了

5. `$REPO_ROOT` として現在のリポジトリルートの絶対パスを控える:
   ```bash
   REPO_ROOT=$(git rev-parse --show-toplevel)
   REPO_BASENAME=$(basename "$REPO_ROOT")
   ```

6. 作業ディレクトリを作成:
   ```bash
   mkdir -p ~/worktrees/$REPO_BASENAME/address-reviews-<PR番号>
   ```

## Step 2: レビューコメント収集

### 2-1. 未解決レビュースレッドの取得

```bash
gh api graphql -f query='
  query($owner: String!, $repo: String!, $number: Int!) {
    repository(owner: $owner, name: $repo) {
      pullRequest(number: $number) {
        reviewThreads(first: 100) {
          nodes {
            isResolved
            isOutdated
            id
            comments(first: 20) {
              nodes {
                id
                databaseId
                path
                line
                body
                author { login }
                createdAt
              }
            }
          }
        }
      }
    }
  }
' -f owner="$OWNER" \
  -f repo="$REPO_NAME" \
  -F number="$PR_NUMBER"
```

### 2-2. フィルタリング（GitHub ステータスベース）

以下の条件でコメントをまず除外する:
- `isResolved == true` → **除外**（すでに解決済み）
- `isOutdated == true` → **除外**（コードが変更済みで該当しない）
- 各スレッドの最初のコメント（`comments.nodes[0]`）がレビュー指摘の本体

### 2-2b. 実質解決済みコメントの推定除外

GitHub 上で resolved/outdated マークされていなくても、会話内容やコードの状態から **実質的に解決済み** と推定できるコメントを特定し、除外候補とする。

以下のシグナルを総合的に判断する:

1. **スレッド内の後続コメントで解決を示唆**:
   - PR 作成者が「修正しました」「対応しました」「Fixed」「Done」「Updated」等と返信している
   - レビュアーが「LGTM」「Thanks」「Looks good now」等と返信している
   - 後続コメントで議論が収束している（最後のコメントが肯定的）

2. **指摘箇所のコードが既に変更されている**:
   - コメントが指す行のコードが、コメント投稿後のコミットで変更されている
   - `gh pr diff` と `git log --since=<comment.createdAt>` を突き合わせて確認

3. **指摘内容が既に反映されている**:
   - コメントの要求内容（例:「変数名を変更して」「null チェックを追加して」）が現在のコードに反映済み
   - 対象ファイルを Read して現在の状態を確認

**除外判定の出力**:
推定除外の場合、サマリーにその旨と根拠を明示する:
```
### 実質解決済みと推定（J件）

| # | ファイル | 行 | レビュアー | 推定根拠 |
|---|---------|----|---------|--------------------|
| 1 | src/foo.ts | 42 | @reviewer1 | PR作成者が「Fixed in abc1234」と返信済み |
| 2 | src/bar.ts | 100 | @reviewer2 | 指摘箇所のコードが後続コミットで変更済み |
```

**重要**: 推定に自信がないコメントは除外しない。疑わしい場合は評価対象として残す。

### 2-3. レビューレベルコメントの取得

レビュー全体に対するコメント（ファイル単位でないもの）も取得:

```bash
gh api graphql -f query='
  query($owner: String!, $repo: String!, $number: Int!) {
    repository(owner: $owner, name: $repo) {
      pullRequest(number: $number) {
        reviews(first: 100) {
          nodes {
            author { login }
            body
            state
          }
        }
      }
    }
  }
' -f owner="$OWNER" \
  -f repo="$REPO_NAME" \
  -F number="$PR_NUMBER"
```

- `state == "PENDING"` → 除外
- `body` が空 → 除外
- 残りをレビューレベルコメントとして収集

### 2-4. 結果の保存と表示

- 収集したコメントを `~/worktrees/$REPO_BASENAME/address-reviews-<PR番号>/comments.json` に保存
- コメントがゼロ件の場合は「未解決のレビューコメントはありません」と表示して終了
- コメント一覧のサマリーを表示:
  ```
  ## 収集したレビューコメント

  **評価対象コメント**: N件
  **除外**: M件 resolved, K件 outdated, J件 実質解決済み（推定）

  ### 評価対象
  | # | ファイル | 行 | レビュアー | 概要（冒頭50文字） |
  |---|---------|----|---------|--------------------|
  | 1 | src/foo.ts | 42 | @reviewer1 | コメント冒頭... |
  | 2 | src/bar.ts | 100 | @reviewer2 | コメント冒頭... |

  ### 実質解決済みと推定（J件）
  | # | ファイル | 行 | レビュアー | 推定根拠 |
  |---|---------|----|---------|--------------------|
  | 1 | ... | ... | ... | ... |
  ```

## Step 3: コンテキスト準備

1. PR の diff を取得:
   ```bash
   gh pr diff <PR番号>
   ```

2. 各コメントの対象ファイルを Read ツールで読み込み、変更箇所周辺のコードを把握

3. 以下の情報を `~/worktrees/$REPO_BASENAME/address-reviews-<PR番号>/context.md` にまとめる:
   - PR タイトル、description の要約
   - 各レビューコメントとその対象コード
   - diff の関連部分

## Step 4: チーム作成

### 4-1. TeamCreate

```
TeamCreate with team_name: "address-reviews-<PR番号>"
```

### 4-2. タスク作成（TaskCreate）

以下の6タスクを作成し、依存関係を設定する:

| Task ID | Subject | blockedBy |
|---------|---------|-----------|
| 1 | Claude Round 1 評価 | — |
| 2 | Codex Round 1 評価 | — |
| 3 | クロスチェック Round 1 | 1, 2 |
| 4 | Claude Round 2 再評価 | 3 |
| 5 | Codex Round 2 再評価 | 3 |
| 6 | 最終判断統合 | 4, 5 |

各タスクの description には評価に必要な情報（context.md のパス、評価フォーマット等）を含める。

## Step 5: エージェント起動

**3エージェントを並列に** 起動する（単一メッセージで複数の Agent ツールコール）。

エージェントのプロンプトは `references/agents/` ディレクトリに定義されている。
各プロンプトファイルを Read して内容を取得し、以下のプレースホルダーを実際の値に置換してから Agent tool に渡す:

| プレースホルダー | 値 |
|---|---|
| `{{PR_NUMBER}}` | PR 番号 |
| `{{WORK_DIR}}` | `~/worktrees/$REPO_BASENAME/address-reviews-<PR番号>` |

### A. claude-evaluator

```
Agent tool:
  subagent_type: "general-purpose"
  team_name: "address-reviews-<PR番号>"
  name: "claude-evaluator"
  prompt: <references/agents/claude-evaluator.md の内容（プレースホルダー置換済み）>
```

### B. codex-evaluator

```
Agent tool:
  subagent_type: "general-purpose"
  team_name: "address-reviews-<PR番号>"
  name: "codex-evaluator"
  prompt: <references/agents/codex-evaluator.md の内容（プレースホルダー置換済み）>
```

### C. synthesizer

```
Agent tool:
  subagent_type: "general-purpose"
  team_name: "address-reviews-<PR番号>"
  name: "synthesizer"
  prompt: <references/agents/synthesizer.md の内容（プレースホルダー置換済み）>
```

## Step 6: モニター & ファシリテート

1. **待機**: エージェントからの報告メッセージは自動的に配信される
2. エージェントが他のエージェントの仮説に関連する証拠を発見した場合、直接通信していなければ中継する
3. エージェントがスタックしている場合（進捗なしでアイドル）、ガイダンスや追加コンテキストを送信する
4. TaskList で進捗を追跡する
5. Codex フォールバックが発生した場合、synthesizer が Claude 単独評価モードに切り替えたことを確認する
6. 全6タスクが completed になるまで監視を続ける

## Step 7: ユーザー確認

synthesizer が最終判断を完了したら（Task 6 completed）:

1. `~/worktrees/$REPO_BASENAME/address-reviews-<PR番号>/final-judgment.md` を読み込む
2. 最終判断をユーザーに提示し、AskUserQuestion で各コメントの対応を確認する

### 全コメントの判断サマリーを表示

```
## 最終判断サマリー

### 修正対象（N件）
1. [src/foo.ts:42] @reviewer1: <指摘要約> → 修正方針: <方針>
2. ...

### 返信対象（M件）
1. [src/bar.ts:100] @reviewer2: <指摘要約> → 返信: <返信要約>
2. ...
```

### ユーザーへの確認

AskUserQuestion で確認:
- **すべて承認**: 上記の判断に従って修正・返信を実行
- **個別に確認**: 各コメントについて個別に承認/変更
- **中断**: 実行せずに終了（最終判断ファイルは保持）

**「個別に確認」が選択された場合**:
各コメントについて AskUserQuestion で以下の選択肢を提示:
- 承認（判断通り実行）
- 修正に変更（返信→修正に変更、修正方針を入力）
- 返信に変更（修正→返信に変更、返信文を入力/編集）
- スキップ（この回は対応しない）

## Step 8: 実行

### 8-1. 修正の実行

修正対象のコメントについて:

1. PR ブランチがチェックアウトされていることを確認:
   ```bash
   gh pr checkout <PR番号>
   ```
   （すでに PR ブランチにいる場合はスキップ）

2. 各修正を適用:
   - Edit ツールでコード修正
   - 関連する修正はグループ化して1コミットにまとめる
   - コミットメッセージ形式:
     ```
     fix(<scope>): <description>

     Address review comment from @<reviewer>: <comment-summary>

     Co-Authored-By: Claude <noreply@anthropic.com>
     ```

3. 検証:
   リポジトリの検証コマンドを自動検出して実行する:
   - `package.json` の `scripts` に `typecheck`, `lint`, `check`, `test` 等があればそれを使う
   - `Makefile` に `lint`, `check` 等のターゲットがあればそれを使う
   - CI 設定（`.github/workflows/`）から検証コマンドを推定する
   - 検出できない場合はユーザーに確認する

4. 修正完了後にプッシュ:
   ```bash
   git push
   ```

### 8-2. 返信の実行

返信対象のコメントについて、PR上にコメントを投稿する。

**返信言語**: レビュアーのコメント言語に合わせる（日本語のコメントには日本語で、英語のコメントには英語で返信）

各コメントに対して、GraphQL API でスレッドに返信:

```bash
gh api graphql -f query='
  mutation($input: AddPullRequestReviewCommentInput!) {
    addPullRequestReviewComment(input: $input) {
      comment {
        id
        url
      }
    }
  }
' -f input='{"pullRequestReviewId":"...","inReplyTo":"...","body":"..."}'
```

または REST API:

```bash
gh api repos/<owner>/<repo>/pulls/<PR番号>/comments \
  -f body="<返信文>" \
  -F in_reply_to=<コメントID>
```

### 8-3. 完了サマリー

実行結果をユーザーに表示:

```
## 完了サマリー

**評価モード**: デュアル評価（Claude + Codex） / Claude 単独評価（Codex フォールバック）

### 修正済み（N件）
- [src/foo.ts:42] @reviewer1: <指摘要約> → コミット: abc1234
- ...

### 返信済み（M件）
- [src/bar.ts:100] @reviewer2: <指摘要約> → 返信投稿済み
- ...

### 実質解決済みとして除外（J件）
- [src/baz.ts:20] @reviewer3: <指摘要約> → 推定根拠: <根拠>
- ...

### スキップ（K件）
- ...

### CI & 再レビュー
- CI ステータス: Pass / Fail（修正回数: X回）
- 再レビューリクエスト: @reviewer1, @reviewer2, ... → 送信済み / 未送信
```

**Codex フォールバック時の追加表示**:
`$CODEX_FAILURE` が設定されている場合、完了サマリーの末尾に以下を表示:

```
---
Codex フォールバック通知

Codex が <失敗したラウンド> で失敗したため、Claude 単独評価にフォールバックしました。
- 失敗ラウンド: Round 1 / Round 2 / Both
- エラー概要: <codex exec のエラー出力の要約>
- 影響: デュアル評価による相互検証が <部分的に / 完全に> 欠落しています。
  判断に不安がある場合は個別のコメントを手動で再確認してください。
```

## Step 9: CI 待機 & 再レビューリクエストループ

修正をプッシュした場合（Step 8-1 で修正があった場合）のみ実行する。
返信のみの場合はこの Step をスキップして Step 10 に進む。

### 9-1. レビュワーリストの収集

最終判断で対応した（修正 or 返信）コメントのレビュワーを重複排除で収集し、`$REVIEWERS` に保持する。

### 9-2. CI チェック待機

```bash
gh pr checks <PR番号> --watch --fail-fast
```

- `--watch` で全チェックの完了を待機する
- タイムアウト（10分）を設定し、超過した場合は `gh pr checks <PR番号>` で現在の状態を確認してユーザーに報告

### 9-3. CI 結果による分岐

#### 全チェック Pass の場合

1. レビュワーに再レビューをリクエスト:
   ```bash
   gh api repos/<owner>/<repo>/pulls/<PR番号>/requested_reviewers \
     -f "reviewers[]=$REVIEWER1" -f "reviewers[]=$REVIEWER2" ...
   ```

2. ユーザーに完了を通知:
   ```
   CI 全チェック Pass
   再レビューリクエスト送信済み: @reviewer1, @reviewer2, ...
   ```

3. Step 10 に進む

#### いずれかのチェック Fail の場合

1. 失敗したチェックの詳細を取得:
   ```bash
   gh pr checks <PR番号>
   ```

2. 失敗した CI ジョブのログを取得・分析:
   ```bash
   gh run view <run-id> --log-failed
   ```

3. 失敗原因がこの PR の修正に起因するか判定:
   - **起因する場合**: 修正を実施
     - Edit ツールでコード修正
     - 検証コマンドを実行（Step 8-1 の検証と同じ方法で自動検出）
     - コミット & プッシュ:
       ```bash
       git add <修正ファイル>
       git commit -m "fix(<scope>): address CI failure

       Co-Authored-By: Claude <noreply@anthropic.com>"
       git push
       ```
     - **Step 9-2 に戻る**（CI 待機ループ再開）
   - **起因しない場合**（既存の CI 問題、flaky test 等）:
     - ユーザーに状況を報告し、AskUserQuestion で判断を仰ぐ:
       - **再レビューリクエストを送信**: CI 失敗はこの修正に無関係なため、レビューをリクエスト
       - **待機**: ユーザーが手動で対応した後、再度 CI を確認
       - **中断**: ここで終了

### 9-4. ループ上限

CI 修正ループは **最大3回** まで。3回修正してもまだ CI が失敗する場合は:
- 失敗状況をユーザーに報告
- AskUserQuestion で続行判断を仰ぐ（手動対応 / 強制的に再レビューリクエスト / 中断）

## Step 10: チームクリーンアップ

1. 全エージェントにシャットダウンリクエストを送信:
   ```
   SendMessage type: "shutdown_request" to claude-evaluator
   SendMessage type: "shutdown_request" to codex-evaluator
   SendMessage type: "shutdown_request" to synthesizer
   ```

2. 全エージェントのシャットダウン完了を確認後、チームを削除:
   ```
   TeamDelete
   ```

## 注意事項

- すべての判断は実際にコードを読んで確認した事実に基づくこと
- 推測ベースの判断（「〜の可能性がある」等）は最終判断に含めないこと
- Codex が失敗した場合はリトライ1回の後、Claude 単独評価で続行すること。**失敗時は `$CODEX_FAILURE` を記録し、最終判断ファイルと完了サマリーの両方で明示的に通知すること**
- 中間ファイルはすべて `~/worktrees/$REPO_BASENAME/address-reviews-<PR番号>/` に保存すること
- 修正コミットのプッシュ前に必ず検証コマンドを通すこと
- 実質解決済みの推定に自信がない場合は除外せず評価対象に残すこと（偽陰性より偽陽性を優先）
- CI 修正ループは最大3回まで。3回超過はユーザーに判断を仰ぐこと
- CI 失敗がこの PR の修正に起因しない場合は、ユーザーに確認の上で再レビューリクエストを送信できる
- 返信のみで修正がない場合は CI 待機ステップをスキップすること
- 返信言語はレビュアーのコメント言語に合わせること
