# dupscan gate の呼び出し例

```yaml
# .github/workflows/dupscan.yml
name: dupscan gate

on:
  push:
    branches: [master]
    paths-ignore:
      - "**/*.md"
  pull_request:
    paths-ignore:
      - "**/*.md"

# 取り消された run はその commit を検証していないので、master の push は取り消さない
concurrency:
  group: dupscan-${{ github.ref }}
  cancel-in-progress: ${{ github.event_name == 'pull_request' }}

permissions:
  contents: read

jobs:
  gate:
    uses: jiikko/shared-workflows/.github/workflows/dupscan-gate.yml@main
    with:
      dotfiles_sha: <jiikko/dotfiles の完全な SHA>
```
