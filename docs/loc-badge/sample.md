# LOC Badge の呼び出し例

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

README にバッジを追加:

```markdown
![Lines of Code](docs/loc-badge.svg)
```

パラメータを渡す例:

```yaml
jobs:
  loc:
    uses: jiikko/shared-workflows/.github/workflows/loc-badge.yml@main
    with:
      source_dir: lib
      badge_path: docs/loc-badge.svg
      exclude_dirs: 'docs,vendor'
```
