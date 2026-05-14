---
name: address-pr-reviews
description: PRレビューコメントを Claude + Codex デュアル評価で精査し、修正 or 返信を実行する
disable-model-invocation: true
user-invocable: true
argument-hint: "<PR URL>"
---

# Address PR Reviews (Dual Evaluation)

PR 上の未解決レビューコメントを Claude + Codex で並列評価し、修正または返信を実行する。

## Input

PR URL: $ARGUMENTS

## Step 1: PR 情報取得

1. URL から `$OWNER`, `$REPO_NAME`, `$PR_NUMBER` を解析
2. `gh pr view "$PR_NUMBER" --repo "$OWNER/$REPO_NAME" --json title,body,state,headRefName,baseRefName,url`
3. `git remote get-url origin` と比較しカレントリポジトリか検証。不一致なら終了
4. `state` が `OPEN` でなければ終了
5. 作業ディレクトリ準備:
   ```bash
   REPO_ROOT=$(git rev-parse --show-toplevel)
   REPO_BASENAME=$(basename "$REPO_ROOT")
   WORK_DIR=~/worktrees/$REPO_BASENAME/address-reviews-$PR_NUMBER
   mkdir -p "$WORK_DIR"
   ```

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

`state == "PENDING"` または `body` 空は除外。

### 2-4. 結果保存・表示

- `$WORK_DIR/comments.json` に保存。ゼロ件なら終了
- サマリー表示: 評価対象N件、除外件数（resolved/outdated/推定解決済み）、推定除外の根拠

## Step 3: コンテキスト準備

1. `gh pr diff $PR_NUMBER` で diff 取得
2. 各コメント対象ファイルを Read
3. `$WORK_DIR/context.md` に PR概要・各コメントと対象コード・diff関連部分をまとめる

## Step 4: チーム・タスク作成

TeamCreate: `address-reviews-$PR_NUMBER`

| Task | Subject | blockedBy |
|------|---------|-----------|
| 1 | Claude Round 1 評価 | — |
| 2 | Codex Round 1 評価 | — |
| 3 | クロスチェック Round 1 | 1, 2 |
| 4 | Claude Round 2 再評価 | 3 |
| 5 | Codex Round 2 再評価 | 3 |
| 6 | 最終判断統合 | 4, 5 |

## Step 5: エージェント起動

3エージェントを **単一メッセージで並列に** 起動。エージェントは `claude/agents/` に定義済み。
prompt には動的パラメータのみ渡す:

| name | subagent_type | prompt |
|------|--------------|--------|
| claude-evaluator | address-pr-reviews-claude-evaluator | 下記テンプレート |
| codex-evaluator | address-pr-reviews-codex-evaluator | 下記テンプレート |
| synthesizer | address-pr-reviews-synthesizer | 下記テンプレート |

全エージェント共通: `team_name: "address-reviews-$PR_NUMBER"`

prompt テンプレート（各エージェント共通）:
```
WORK_DIR: $WORK_DIR
teammates: <他の2エージェント名>
```

## Step 6: モニター

- エージェント間で関連証拠を中継、スタック時にガイダンス送信
- TaskList で進捗追跡。Codex フォールバック時は synthesizer の Claude 単独モード切替を確認
- 全6タスク completed まで監視

## Step 7: ユーザー確認

`$WORK_DIR/final-judgment.md` を読み込み、修正対象/返信対象のサマリーを表示。

AskUserQuestion で確認:
- **すべて承認**: 判断通り実行
- **個別に確認**: 各コメントについて承認/修正↔返信変更/スキップ
- **中断**: 終了（ファイルは保持）

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

### 8-3. 完了サマリー
評価モード・修正済み/返信済み/推定除外/スキップの件数と詳細を表示。
Codex フォールバック時は失敗ラウンド・エラー概要・影響を追記。

## Step 9: CI 待機 & 再レビューリクエスト（修正プッシュ時のみ）

1. レビュワーを重複排除で収集
2. `gh pr checks $PR_NUMBER --watch --fail-fast`（タイムアウト10分）
3. 全 Pass → `gh api repos/.../pulls/.../requested_reviewers` で再レビューリクエスト → Step 10
4. Fail → ログ取得・分析:
   - この修正起因 → 修正・検証・push → 2 に戻る
   - 既存問題 → ユーザーに確認（再レビュー送信 / 待機 / 中断）
5. CI 修正ループ最大3回。超過時はユーザーに判断を仰ぐ

## Step 10: チームクリーンアップ

全エージェントに shutdown_request を SendMessage し、完了後 TeamDelete。

## 注意事項

- 推測ベースの判断を最終判断に含めない
- 推定解決済みに自信がない場合は除外せず評価対象に残す
- 修正プッシュ前に必ず検証コマンドを通す
- 返信のみの場合は CI 待機をスキップ
- 返信言語はレビュアーのコメント言語に合わせる
