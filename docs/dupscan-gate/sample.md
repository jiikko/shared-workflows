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

手で起動もしたい (除外を足した commit が赤のまま残ったとき、先端を検査し直す) なら、呼び出し側に `workflow_dispatch` を足して `base` を渡す:

```yaml
on:
  workflow_dispatch:
    inputs:
      base:
        description: "比べる base の commit (空なら先端の 1 つ前)"
        required: false
        default: ""

jobs:
  gate:
    uses: jiikko/shared-workflows/.github/workflows/dupscan-gate.yml@main
    with:
      dotfiles_sha: <jiikko/dotfiles の完全な SHA>
      base: ${{ inputs.base }}
```
