# shared-workflows

GitHub Actions の Reusable Workflow 集。複数リポジトリで共通の CI を使い回す。workflow ごとの説明は `docs/<workflow 名>/README.md`、呼び出し側に置く例は同じディレクトリの `sample.md`。

| workflow | 内容 |
|---|---|
| [LOC Badge](docs/loc-badge/README.md) | ソースコードの行数をカウントし、SVG バッジを生成してリポジトリにコミットする。 |
| [SwiftLint](docs/swiftlint/README.md) | SwiftLint を実行する。公式 Docker image `ghcr.io/realm/swiftlint` を使って lint を走らせる。 |
| [Auto-merge dependabot PR](docs/auto-merge-dependabot/README.md) | 開いている dependabot の PR を週次でまとめて確認し、CI が全て green なものを squash merge する。 |
| [Claude audit](docs/claude-audit/README.md) | Claude Code に audit skill（[jiikko/dotfiles](https://github.com/jiikko/dotfiles) の `_claude/skills/audit`）の監査タイプを回させ、変更を PR で出す。 |
| [dupscan gate](docs/dupscan-gate/README.md) | base から増えた重複 (既にある関数の写し) を jiikko/dotfiles の dupscan で止める。dupscan は呼び出し側が固定した commit で build する。 |

呼び出し側は `uses: jiikko/shared-workflows/.github/workflows/<workflow 名>.yml@main` で呼ぶ。`permissions` は呼び出し側で宣言する（reusable workflow 内の `permissions` は呼び出し側の権限を超えられない）。
