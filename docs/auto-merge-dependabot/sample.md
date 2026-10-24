# Auto-merge dependabot PR の呼び出し例

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
