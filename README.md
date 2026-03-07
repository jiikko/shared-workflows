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

jobs:
  loc:
    uses: jiikko/shared-workflows/.github/workflows/loc-badge.yml@main
```

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
