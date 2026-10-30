# actionlint の呼び出し例

```yaml
# .github/workflows/actionlint.yml
name: actionlint

on:
  push:
    branches: [master]
    paths:
      - ".github/workflows/**"
  pull_request:
    paths:
      - ".github/workflows/**"

permissions:
  contents: read

jobs:
  actionlint:
    uses: jiikko/shared-workflows/.github/workflows/actionlint.yml@main
```
