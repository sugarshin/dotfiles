---
name: address-pr-reviews
description: PRレビューコメントを Claude + Codex デュアル評価で精査し、修正 or 返信を実行する
disable-model-invocation: true
user-invocable: true
argument-hint: "<PR URL>"
---

# Address PR Reviews (Dual Evaluation)

PR 上の未解決レビューコメントを Claude + Codex で並列評価し、クロスチェックで統合された最終判断に基づき修正または返信を実行する。

修正を push すると Bugbot 等の自動レビュアーが新しい diff を再解析して追撃コメントを出すため、**1 回の実行で対応を完了できるよう Step 2〜9 を「ドレインループ」で繰り返す**。push 後は Bugbot を含む check の完了を待ってからコメントを再収集し、新規の指摘が尽きるまでループする。

## Input

PR URL: $ARGUMENTS

## Step 1: PR 情報取得（ループ前に 1 回）

1. URL から `$OWNER`, `$REPO_NAME`, `$PR_NUMBER` を解析
2. `gh pr view "$PR_NUMBER" --repo "$OWNER/$REPO_NAME" --json title,body,state,headRefName,baseRefName,url`
3. `git remote get-url origin` と比較しカレントリポジトリか検証。不一致なら終了
4. `state` が `OPEN` でなければ終了
5. 作業ディレクトリ準備とループ状態の初期化:
   ```bash
   REPO_ROOT=$(git rev-parse --show-toplevel)
   REPO_BASENAME=$(basename "$REPO_ROOT")
   WORK_DIR=~/worktrees/$REPO_BASENAME/address-reviews-$PR_NUMBER
   mkdir -p "$WORK_DIR"
   ROUND=1
   MAX_ROUNDS=3
   # 評価/対応済みコメントの databaseId を永続化（ラウンド間の重複排除キー）
   [ -f "$WORK_DIR/processed-comments.json" ] || echo '[]' > "$WORK_DIR/processed-comments.json"
   ```
6. 既知の bot レビュアー check 名を設定（リポジトリにより異なる。push 後の完了待ちに使う）:
   ```bash
   # 既定。リポジトリの実際の check 名に合わせて調整（`gh pr checks $PR_NUMBER` で確認可）
   BOT_CHECKS="Cursor Bugbot|bugbot"
   ```

---

# ドレインループ（Step 2〜9 を繰り返す）

各ラウンドで `収集 → 評価 → 確認 → 実行 → push後の check 完了待ち → 再収集判定` を行う。
**新規の対応すべきコメントが無くなったら**、または **MAX_ROUNDS に達したら** ループを抜けて Step 10 へ。

## Step 2: レビューコメント収集

### 2-1. 未解決レビュースレッド取得

```bash
gh api graphql -f query='
  query($owner: String!, $repo: String!, $number: Int!) {
    repository(owner: $owner, name: $repo) {
      pullRequest(number: $number) {
        reviewThreads(first: 100) {
          nodes {
            isResolved isOutdated id
            comments(first: 20) {
              nodes { id databaseId path line body author { login } createdAt }
            }
          }
        }
      }
    }
  }
' -f owner="$OWNER" -f repo="$REPO_NAME" -F number="$PR_NUMBER"
```

### 2-2. フィルタリング

除外条件:
- `isResolved == true` / `isOutdated == true`
- **処理済み**: `databaseId` が `$WORK_DIR/processed-comments.json` に含まれる（前ラウンドで修正/返信/スキップ判断済み）。これがラウンド間ループの重複排除キー
- **実質解決済み推定**: スレッド内で「修正しました/Fixed/Done」等の返信、指摘箇所が後続コミットで変更済み、指摘内容が現コードに反映済み。推定に自信がない場合は除外しない。

### 2-3. レビューレベルコメント取得

```bash
gh api graphql -f query='
  query($owner: String!, $repo: String!, $number: Int!) {
    repository(owner: $owner, name: $repo) {
      pullRequest(number: $number) {
        reviews(first: 100) {
          nodes { author { login } body state }
        }
      }
    }
  }
' -f owner="$OWNER" -f repo="$REPO_NAME" -F number="$PR_NUMBER"
```

`state == "PENDING"` または `body` 空は除外。レビューレベルコメントも処理済み判定（本文ハッシュ等）で重複排除する。

### 2-4. 結果保存・ループ脱出判定

- `$WORK_DIR/comments.json`（ラウンド上書き）に保存
- **新規の対応対象がゼロ件 → ループを抜けて Step 10**（初回ゼロ件も同様に終了）
- サマリー表示: ラウンド `$ROUND`、評価対象N件、除外件数（resolved/outdated/処理済み/推定解決済み）、推定除外の根拠

## Step 3: コンテキスト準備

1. `gh pr diff $PR_NUMBER` で diff 取得（最新の push を反映した diff）
2. 各コメント対象ファイルを Read
3. `$WORK_DIR/context.md` に PR概要・各コメントと対象コード・diff関連部分をまとめる（ラウンド上書き）

## Step 4: チーム・タスク作成

TeamCreate: `address-reviews-$PR_NUMBER-r$ROUND`（ラウンドごとに別チーム名で衝突回避）

| Task | Subject | blockedBy |
|------|---------|-----------|
| 1 | Claude 評価 | — |
| 2 | Codex 評価 | — |
| 3 | クロスチェック & 最終判断統合 | 1, 2 |

## Step 5: エージェント起動

3エージェントを **単一メッセージで並列に** 起動。エージェントは `claude/agents/` に定義済み。
prompt には動的パラメータのみ渡す:

| name | subagent_type | prompt |
|------|--------------|--------|
| claude-evaluator | address-pr-reviews-claude-evaluator | 下記テンプレート |
| codex-evaluator | address-pr-reviews-codex-evaluator | 下記テンプレート |
| synthesizer | address-pr-reviews-synthesizer | 下記テンプレート |

全エージェント共通: `team_name: "address-reviews-$PR_NUMBER-r$ROUND"`

prompt テンプレート（各エージェント共通）:
```
WORK_DIR: $WORK_DIR
teammates: <他の2エージェント名>
```

## Step 6: モニター

- エージェント間で関連証拠を中継、スタック時にガイダンス送信
- TaskList で進捗追跡。Codex フォールバック時は synthesizer の Claude 単独モード切替を確認
- 全3タスク completed まで監視
- 完了後、このラウンドのチームは shutdown_request → TeamDelete でクリーンアップ（評価フェーズ終了。Step 8/9 にエージェントは不要）

## Step 7: ユーザー確認（毎ラウンド）

`$WORK_DIR/final-judgment.md` を読み込み、修正対象/返信対象のサマリーを表示。

AskUserQuestion で確認:
- **すべて承認**: 判断通り実行
- **個別に確認**: 各コメントについて承認/修正↔返信変更/スキップ
- **中断**: 終了（ファイルは保持。`processed-comments.json` も残るので再開時に重複評価しない）

## Step 8: 実行

### 8-1. 修正
1. `gh pr checkout $PR_NUMBER`（未チェックアウト時）
2. Edit で修正、関連修正をグループ化して1コミット（`fix(<scope>): <desc>` + `Co-Authored-By: Claude <noreply@anthropic.com>`）
3. 検証コマンド自動検出・実行（package.json scripts / Makefile / CI設定）
4. `git push`

### 8-2. 返信
レビュアーのコメント言語に合わせて返信:
```bash
gh api repos/$OWNER/$REPO_NAME/pulls/$PR_NUMBER/comments \
  -f body="<返信文>" -F in_reply_to=<コメントID>
```

### 8-3. 処理済みマーク
このラウンドで **修正/返信/スキップのいずれかを判断した全コメントの `databaseId`** を `$WORK_DIR/processed-comments.json` に追記する（スキップも記録。次ラウンドで再提示しないため）。

### 8-4. ラウンドサマリー
このラウンドの評価モード・修正済み/返信済み/推定除外/スキップの件数と詳細を表示。
Codex フォールバック時は失敗ラウンド・エラー概要・影響を追記。

## Step 9: push 後の check 完了待ち & 再収集判定

このラウンドで **コード変更を push したか** で分岐する。

### 9-A. 返信のみ（push なし）だった場合
コード変更が無ければ Bugbot 等は再起動しない → **ループを抜けて Step 10**。

### 9-B. 修正を push した場合
push をトリガーに Bugbot が新 diff を再解析して追撃コメントを出す。**「CI が pass したか」ではなく「push で起動した check が *完了* したか」を待つ**のがポイント。

1. push 済みコミットを記録: `HEAD_SHA=$(git rev-parse HEAD)`
2. **bot check が登録される猶予**: push 直後は Bugbot の check がまだ queue されていないことがある。最低 60〜90 秒の grace を置いてからポーリング開始
3. **全 check の完了待ち**: `gh pr checks $PR_NUMBER` をポーリングし、全 check が terminal state（success/failure/skipped 等、pending/queued/in_progress でない）になるまで待機。`$BOT_CHECKS` に一致する check は特に完了を確認する。タイムアウト 10 分
   - CI が **Fail** した場合はログを取得・分析:
     - この修正起因 → 修正・検証・push → 本 Step 9-B の 1 に戻る（CI 修正サブループは最大 3 回）
     - 既存問題 → ユーザーに確認（このまま続行 / 待機 / 中断）
4. **コメント再収集**: check 完了後、bot がインラインコメントを出し終えているので Step 2 を再実行
5. **ループ制御**:
   - 新規の対応対象がある & `ROUND < MAX_ROUNDS` → `ROUND=$((ROUND+1))` して **Step 2 の頭からループ継続**（次ラウンドの評価へ）
   - 新規の対応対象がゼロ → ループを抜けて Step 10
   - `ROUND == MAX_ROUNDS` に達したのに新規コメントが残る → ループを抜け、Step 10 で **残コメントを明示して報告**しユーザー判断に委ねる

---

## Step 10: 完了処理（ループ後 1 回）

1. 取りこぼしのチーム掃除: 残存する `address-reviews-$PR_NUMBER-r*` チームがあれば shutdown_request → TeamDelete
2. **再レビューリクエスト**（このセッションで 1 件以上修正を push した場合のみ）:
   - レビュワーを重複排除で収集
   - `gh api repos/$OWNER/$REPO_NAME/pulls/$PR_NUMBER/requested_reviewers` で人間レビュアーに再レビュー依頼
3. **総括サマリー**: 全ラウンド合算で 評価モード・修正済み / 返信済み / 推定除外 / スキップ の件数と詳細、回したラウンド数を表示
   - MAX_ROUNDS 到達で打ち切った場合: 残った未対応コメントを列挙し「手動再実行 or 個別対応が必要」と明記
   - CI が既存問題で Fail のまま続行した場合: その旨と影響を追記

## 注意事項

- 推測ベースの判断を最終判断に含めない
- 推定解決済みに自信がない場合は除外せず評価対象に残す
- 修正プッシュ前に必ず検証コマンドを通す
- **push 後は「CI の pass」ではなく「Bugbot 含む check の *完了*」を待つ**。完了前に再収集すると追撃コメントを取りこぼす
- `processed-comments.json` がラウンド間・再実行間の重複排除キー。スキップ判断も記録して再提示を防ぐ
- ドレインループは最大 3 ラウンド。fix→Bugbot→fix→… のピンポン暴走を防ぐ
- 返信のみのラウンドは check 待ちをスキップしてループを抜ける
- 返信言語はレビュアーのコメント言語に合わせる
