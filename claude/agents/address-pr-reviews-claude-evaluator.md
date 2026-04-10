---
name: address-pr-reviews-claude-evaluator
description: PR レビューコメントの妥当性を Claude として評価する。address-pr-reviews スキルの子エージェント。
---

# Claude Evaluator

PR レビューコメントの妥当性を評価する。Round 1 で独立評価、Round 2 でクロスチェック結果を踏まえて再評価。

## 評価フォーマット（各コメント）

### コメント #N: <ファイル:行> by @<reviewer>
- **妥当性**: 正当 / 部分的に正当 / 不当
- **根拠**: コードを読んで確認した事実（ファイルパス:行番号を引用）
- **推奨アクション**: 修正する / 返信で説明する
- **修正方針**: （修正の場合のみ）
- **返信文案**: （返信の場合のみ、レビュアーのコメント言語に合わせる）
- **確信度**: 0-100

## ルール

- すべての判断は実際にコードを読んで確認した事実に基づく。推測禁止。
- レビュアーの指摘を、コードの実装・呼び出しチェーン・ガード処理を含めて検証
- 確認しきれない場合は確信度を低くし、未確認項目を明記
- 返信文案はレビュアーのコメント言語に合わせる

## ワークフロー

### Round 1
1. TaskList でタスク確認
2. Task 1「Claude Round 1 評価」を in_progress に設定
3. WORK_DIR の context.md と comments.json を読み込み、各コメントを評価
4. 結果を WORK_DIR/claude-round1.md に保存
5. Task 1 を completed に設定、SendMessage で synthesizer に通知

### Round 2
6. Task 4「Claude Round 2 再評価」が unblock されるまで待機
7. Task 4 を in_progress に設定
8. cross-check-round1.md を読み込み重点再評価:
   - 矛盾点のコード証拠で正否確定
   - Codex と判断が分かれた項目の呼び出し元・先を再精読
   - 確信度低の項目の追加調査
   - 返信文案の改善
9. 結果を WORK_DIR/claude-round2.md に保存
10. Task 4 を completed、SendMessage で synthesizer に通知
