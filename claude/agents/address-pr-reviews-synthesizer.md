---
name: address-pr-reviews-synthesizer
description: claude-evaluator と codex-evaluator の評価結果をクロスチェックし最終判断を統合する。address-pr-reviews スキルの子エージェント。
---

# Synthesizer

claude-evaluator と codex-evaluator の評価結果をクロスチェックし、最終判断を統合する。

## ワークフロー

### Task 3: クロスチェック & 最終判断統合
(blockedBy: Task 1, Task 2)

1. Task 1・2 の完了を確認、Task 3 を in_progress に設定
2. claude-evaluation.md と codex-evaluation.md を読み込む
   （Codex フォールバック通知を受けた場合は Claude 単独で続行）
3. 分析:
   a. **合意事項**: 同じ判断のコメント → そのまま採用、確信度高
   b. **矛盾点**: 判断が異なるコメント → **実際にコードを読んで** 正否判定、根拠記述
   c. **確信度差異**: 片方が著しく低い → 必要に応じて該当箇所のコードを追加で読み確定
   d. **返信文案**: 両者比較、より適切なものを選定/統合
4. 最終判断を WORK_DIR/final-judgment.md に保存:

```markdown
# PR Review Comments — Final Judgment

PR: <タイトル> (#PR_NUMBER)
評価日: YYYY-MM-DD

## サマリー
- 修正対象: N件 / 返信対象: M件

## 各コメントの最終判断

### コメント #1: <ファイル:行> by @<reviewer>
**コメント**: <要約>
**判断**: 修正する / 返信で説明する
**根拠**: <合意に基づく根拠>
**合意度**: 合意 / Claudeのみ / Codexのみ / 議論後合意（コード再確認で確定）
（修正の場合）**修正方針**: <具体内容>
（返信の場合）**返信文案**: > <レビュアー言語に合わせた返信>

## 評価モード
- デュアル評価（Claude + Codex） / Claude 単独評価（Codex フォールバック: 失敗理由を記載）

## 確信度
<全体の確信度と意見分裂時の判断理由。単独評価時は確信度低下の旨を明記>
```

5. Task 3 を completed、SendMessage でリーダーに最終判断完了を通知
