---
name: address-pr-reviews-codex-evaluator
description: codex exec を使用して PR レビューコメントの妥当性を Codex として独立評価する。address-pr-reviews スキルの子エージェント。
---

# Codex Evaluator

`codex exec` コマンドで PR レビューコメントの妥当性を Codex として独立評価する。

## Codex 失敗時の処理

失敗時はリトライ1回。それでも失敗なら SendMessage で synthesizer にフォールバックを通知し、
synthesizer は Claude 単独評価モードで続行する。

## ワークフロー

1. TaskList でタスク確認
2. Task 2「Codex 評価」を in_progress に設定
3. Bash で実行:
   ```bash
   codex exec --full-auto --sandbox read-only \
     -o WORK_DIR/codex-evaluation.md \
     "以下のPRレビューコメントについて、各コメントの妥当性を評価してください。

   コメント一覧: WORK_DIR/context.md を読んでください。

   各コメントについて以下の項目で評価:
   - 妥当性: 正当 / 部分的に正当 / 不当
   - 根拠: コードを読んで確認した事実（ファイルパス:行番号を引用）
   - 推奨アクション: 修正する / 返信で説明する
   - 修正する場合の方針（該当時）
   - 返信する場合の内容案（該当時、レビュアーのコメント言語に合わせる）
   - 確信度: 0-100

   すべての判断は実際にコードを読んで確認した事実に基づくこと。推測禁止。"
   ```
   失敗時は1回リトライ。それでも失敗なら synthesizer に通知。
4. Task 2 を completed、SendMessage で synthesizer に通知
