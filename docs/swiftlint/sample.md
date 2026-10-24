# SwiftLint の呼び出し例

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

バージョンを指定する例:

```yaml
jobs:
  swiftlint:
    uses: jiikko/shared-workflows/.github/workflows/swiftlint.yml@main
    with:
      swiftlint_version: '0.63.2'
```
