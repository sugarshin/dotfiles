---
name: pr-summary
description: >
  PR を「課題 / 背景 / 実現したいこと / ソリューション」の 4 点で手軽にシンプルに要約する。
  レビュー指摘も筋の良さ評価もせず、PR の中身を短時間で把握することだけに絞る。
  「この PR の概要を教えて」「この PR 何やってるの」「この PR をシンプルに説明して」、
  PR URL を渡されて内容の説明を求められたとき、または /pr-summary で起動。
user-invocable: true
disable-model-invocation: true
argument-hint: "<PR URL | PR番号 [owner/repo]>"
allowed-tools: Bash, Read, Grep, Glob
---

# pr-summary スキル

PR の中身を **課題 / 背景 / 実現したいこと / ソリューション** の 4 点で日本語要約する。目的は「読む前に何をしている PR か分かる」こと、それだけ。

**このスキルはレビューではない。** 行単位の指摘・nit・筋の良さ判定・レビュー観点リストはすべてスコープ外。
レビュー前の事前評価が欲しいときは `/pr-briefing`、本格レビューは `/review-pr` を使う。

## 引数の処理

`$ARGUMENTS` を解析する:

- **PR URL**（`https://github.com/{owner}/{repo}/pull/{number}`）→ owner/repo と PR 番号を抽出
- **番号のみ** → カレントディレクトリの `git remote get-url origin` から owner/repo を推定。git リポジトリ外なら質問する
- **番号 + owner/repo** → そのまま使用
- **複数 PR** → 1 件ずつ順に、それぞれ独立した要約を出力
- **引数なし** → カレントブランチの PR（`gh pr view --json ...` を引数なしで実行）。無ければ PR を質問する

## Step 1: 情報収集（まず 1 コマンド）

```bash
gh pr view <number> --repo <owner>/<repo> --json \
  title,body,author,url,state,additions,deletions,changedFiles,baseRefName,commits
```

- **`author.login`（PR 作成者の GitHub アカウント名）は必ず取り出す**。`--json author` が返すのはオブジェクト（`login` / `name` / `is_bot`）なので、`--jq '.author.login'` などで `login` を取得すること。表示名（`name`）ではなくアカウント名（`login`）を使う。これは Step 3 の出力必須要素である
- **body（description）が第一情報源**。ここに背景・課題が書かれていれば、それを土台にする
- body が英語でも、出力は日本語に再構成する（直訳ではなく、同僚に口頭で説明するトーン）
- **commits のメッセージ body** は次点の情報源。「なぜそうしたか」が書かれていることが多い

## Step 2: 足りない分だけ diff を見る

「手軽」が最優先。**必要な分だけ読む。**

- body + commits で 4 点が埋まる → `gh pr diff <number> --repo <owner>/<repo> --name-only` で変更範囲だけ確認して終了
- 情報が薄い / 主張と変更内容の対応が掴めない → diff を読む
  - `additions + deletions` が **〜2,000 行程度**: `gh pr diff` で全量
  - それ以上: `--name-only` でファイル一覧 → `gh api "repos/{owner}/{repo}/pulls/{number}/files" --paginate` で中核ファイルの patch だけ。lockfile / snapshot / codegen 出力は読み飛ばす
- リンクされたチケットや `#NNNN` 参照は、**背景がそこにしかない場合のみ** `gh issue view` で取得する
- 周辺コードの調査は原則しない。「変更前がどうだったか」が分からないと要約が書けない箇所だけ、対象ファイルを 1〜2 本読む

深追いを始めそうになったら止める。網羅調査は `/pr-briefing` の役割。

## Step 3: 出力

チャットに直接、以下のフォーマットで出力する（ファイル保存は求められたときだけ）:

```markdown
## PR #{number}: {title}

**作成者**: @{author.login}
{URL} | +{additions} / -{deletions}（{changedFiles} files）→ {baseRefName}

**ひとことで言うと**: （1〜2 行）

### 課題

（何が問題なのか。壊れ方・failure mode が分かっているなら具体的に）

### 背景

（なぜその問題が今ここにあるのか。既存の仕組み・経緯）

### 実現したいこと

（この PR が達成したいゴール。1〜3 行）

### ソリューション

（どう実現しているか。核心の技術判断を箇条書きで 3〜5 個）
```

## 書き方のルール

- **`**作成者**: @{author.login}` の行は必須**。省略・他の行への統合・表示名（`author.name`）での代替は禁止。bot の場合も login をそのまま書く（例: `@dependabot[bot]`）。値が取れなかった場合は `gh pr view <number> --repo <owner>/<repo> --json author --jq '.author.login'` で 1 回だけ再取得し、それでも取れないときに限り `**作成者**: @不明（取得失敗）` と明記する。**推測で埋めない**
- **各セクション 3〜5 行**。ソリューションの箇条書きも 1 項目 1〜2 行に収める。長くなったら削る
- **コード引用は核心 1 箇所まで**。「サイレントに捨てている」等、地の文より引用の方が速く伝わるときだけ使う
- **事実と推測を区別する**。description・コミットに明記されたことは断定、diff から読み取った推測は文末に「（推測）」
- **4 点のうち書けないものがあれば、そのセクションに「description に記載なし（diff からの推測）」と正直に書く**。埋めるために創作しない
- description の主張と diff が明らかに食い違う場合だけ、1 行で指摘する（それ以上掘らない）
- 技術用語・コード識別子・ファイル名は原語のまま。説明文は日本語

## 出力前チェック（必須）

出力（またはファイル保存）の直前に、以下を確認する。1 つでも満たさない場合は出力せず、修正してから出す:

1. `**作成者**: @` で始まる行が本文に存在するか
2. その `@` の後ろが PR 作成者の GitHub **アカウント名**（`author.login`）になっているか（表示名・空・プレースホルダのままになっていないか）

## やらないこと

- コードレビュー、nit、改善提案 → `/review-pr`
- 筋の良さ評価、レビュー観点の洗い出し → `/pr-briefing`
- PR へのコメント投稿・状態変更（**読み取り専用**）
- CI・レビュー状況の確認（要約に不要）
