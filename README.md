# shared-workflows

GitHub Actions の Reusable Workflow 集。複数リポジトリで共通の CI を使い回す。

## LOC Badge

ソースコードの行数をカウントし、SVG バッジを生成してリポジトリにコミットする。

### 使い方

各リポジトリに以下の yml を置く:

```yaml
# .github/workflows/code-stats.yml
name: Update LOC Badge

on:
  schedule:
    - cron: '0 0 * * 1'  # 毎週月曜
  workflow_dispatch:       # 手動実行

permissions:
  contents: write  # バッジをコミット & push するために必要

jobs:
  loc:
    uses: jiikko/shared-workflows/.github/workflows/loc-badge.yml@main
```

> **注意:** `permissions: contents: write` は呼び出し側で宣言する必要がある。reusable workflow 内の `permissions` は呼び出し側の権限を超えられない GitHub の仕様。

README にバッジを追加:

```markdown
![Lines of Code](docs/loc-badge.svg)
```

### パラメータ

| 入力 | デフォルト | 説明 |
|------|-----------|------|
| `source_dir` | `src` | カウント対象ディレクトリ |
| `badge_path` | `docs/loc-badge.svg` | SVG の出力先 |

```yaml
jobs:
  loc:
    uses: jiikko/shared-workflows/.github/workflows/loc-badge.yml@main
    with:
      source_dir: lib
      badge_path: docs/loc-badge.svg
```

### 仕組み

1. `cloc` でコード行数をカウント（コメント・空行は除外）
2. shields.io 風の SVG バッジを生成
3. 変更があればコミット & push

---

## SwiftLint

SwiftLint を実行する。Linux バイナリをダウンロードして lint を走らせる。

### 使い方

各リポジトリに以下の yml を置く:

```yaml
# .github/workflows/swiftlint.yml
name: SwiftLint

on:
  pull_request:
    paths:
      - '**/*.swift'
      - '.swiftlint.yml'
      - '.github/workflows/swiftlint.yml'

jobs:
  swiftlint:
    uses: jiikko/shared-workflows/.github/workflows/swiftlint.yml@main
```

### パラメータ

| 入力 | デフォルト | 説明 |
|------|-----------|------|
| `swiftlint_version` | `0.63.0` | 使用する SwiftLint のバージョン |

```yaml
jobs:
  swiftlint:
    uses: jiikko/shared-workflows/.github/workflows/swiftlint.yml@main
    with:
      swiftlint_version: '0.57.0'
```

---

## Auto-merge dependabot PR

開いている dependabot の PR を週次でまとめて確認し、CI が全て green なものを squash merge する。

### 使い方

各リポジトリに以下の yml を置く:

```yaml
# .github/workflows/dependabot-auto-merge.yml
name: Auto-merge dependabot PR

on:
  schedule:
    - cron: '0 0 * * 1'  # 毎週月曜 09:00 JST
  workflow_dispatch:       # 手動実行

jobs:
  automerge:
    permissions:
      contents: write        # merge & ブランチ削除
      pull-requests: write   # PR の merge
      checks: read           # check run の状態取得
      statuses: read         # commit status の状態取得
      actions: read
    uses: jiikko/shared-workflows/.github/workflows/auto-merge-dependabot.yml@main
```

> **注意:** `permissions` は呼び出し側で宣言する必要がある（LOC Badge と同じ理由）。

パラメータは無い。

### 仕組み

1. open な PR を列挙し、`author.is_bot == true` かつ login が `dependabot` / `dependabot[bot]` / `app/dependabot` に完全一致するものだけを対象にする
2. 自分自身（この workflow）のチェックを除外した上で、失敗（`FAILURE` / `ERROR` / `TIMED_OUT` / `CANCELLED` / `ACTION_REQUIRED` / `STARTUP_FAILURE`）が 1 つでもあれば PR を開いたまま残す
3. まだ実行中のチェックがあっても**待たない**。その PR は翌週の実行で再判定する
4. 全て green なら `gh pr merge --squash --delete-branch --match-head-commit <sha>` で merge する

### 設計上のポイント

- **PR 契機ではなく週次の定期実行**。PR ごとに起動しないので Actions の消費が少なく、`pull_request_target` 系の実行主体の問題も持ち込まない。checkout も行わないため PR 側のコードは一切実行されない
- **ポーリングしない**ので job は数十秒で終わる（`timeout-minutes: 1`）
- `--match-head-commit` により、判定した commit と merge 対象がずれていれば merge は失敗する
- merge に失敗した PR があれば job 全体を失敗させて気付けるようにしている
