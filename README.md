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
| `badge_path` | `docs/loc-badge.svg` | SVG の出力先（親ディレクトリは自動生成される） |
| `exclude_dirs` | `''`（除外なし） | cloc から除外するディレクトリ名のカンマ区切りリスト（例: `docs,issues,vendor`） |

```yaml
jobs:
  loc:
    uses: jiikko/shared-workflows/.github/workflows/loc-badge.yml@main
    with:
      source_dir: lib
      badge_path: docs/loc-badge.svg
      exclude_dirs: 'docs,vendor'
```

このワークフローは `workflow_dispatch` でも同じ入力を受け取るので、この repo 上から直接手動実行することもできる。

### 仕組み

1. `cloc` でコード行数をカウント（コメント・空行は除外）
2. shields.io 風の SVG バッジを生成
3. 変更があればコミット & push

---

## SwiftLint

SwiftLint を実行する。公式 Docker image `ghcr.io/realm/swiftlint` を使って lint を走らせる。

> **前提:** 呼び出し側リポジトリのルートに `.swiftlint.yml` が必要（`--config .swiftlint.yml` 固定で渡している）。

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
| `swiftlint_version` | `0.63.2` | 使用する SwiftLint のバージョン（`ghcr.io/realm/swiftlint` のタグ） |

```yaml
jobs:
  swiftlint:
    uses: jiikko/shared-workflows/.github/workflows/swiftlint.yml@main
    with:
      swiftlint_version: '0.63.2'
```

> **補足:** default が `0.63.2` なのは、各 app の SwiftLintPlugins (SPM) が resolve する 0.63.x に合わせつつ、0.63.0 に残る誤検知（`unneeded_escaping` / `async_without_await`）を避けるため。詳しい経緯は `swiftlint.yml` 内のコメントを参照。

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

---

## Claude audit

Claude Code に audit skill（[jiikko/dotfiles](https://github.com/jiikko/dotfiles) の `_claude/skills/audit`）の監査タイプを回させ、変更を PR で出す。merge は人がレビューしてから行う。Claude はファイルを読んで書くだけで、テストもビルドも実行しない。

### 使い方

```yaml
# .github/workflows/claude-audit.yml
name: Claude audit

on:
  schedule:
    - cron: '17 18 * * 0'  # 毎週月曜 03:17 JST
  workflow_dispatch:
    inputs:
      cost:
        type: choice
        default: standard-10usd
        options: [light-3usd, standard-10usd, heavy-25usd]

jobs:
  audit:
    permissions:
      contents: write        # PR のブランチを push
      pull-requests: write   # PR を作る
      id-token: write        # Claude の Workload Identity Federation
    uses: jiikko/shared-workflows/.github/workflows/claude-audit.yml@main
    with:
      anthropic_organization_id: <組織 ID>
      anthropic_federation_rule_id: fdrl_...
      anthropic_service_account_id: svac_...
      audits: test-cleanup test-helpers
      cost: ${{ inputs.cost || 'standard-10usd' }}
      targets: |
        Tests
```

> **前提:**
> - 呼び出し側の repo の Settings > Actions > General で「Allow GitHub Actions to create and approve pull requests」を有効にする（無効だと PR の作成が 403）
> - Claude Console に federation rule を作る。rule は呼び出し側の workflow と、この reusable workflow の両方で絞る（`claims.workflow_ref` は呼び出し側のファイル、`claims.job_workflow_ref` はこのファイルを指す）:
>   ```
>   claims.repository == "<owner>/<repo>" && claims.ref == "refs/heads/<branch>"
>   && claims.event_name in ["schedule", "workflow_dispatch"]
>   && claims.workflow_ref == "<owner>/<repo>/.github/workflows/claude-audit.yml@refs/heads/<branch>"
>   && claims.job_workflow_ref == "jiikko/shared-workflows/.github/workflows/claude-audit.yml@refs/heads/main"
>   ```
>   呼び出し側のファイル名・`on:` のイベント・`uses:` の `@main` を変えたら rule も合わせる（合わないと 401。理由は Console の認証イベントに出る）

### パラメータ

| 入力 | デフォルト | 説明 |
|------|-----------|------|
| `anthropic_organization_id` | （必須） | Claude Console の組織 ID |
| `anthropic_federation_rule_id` | （必須） | federation rule の ID |
| `anthropic_service_account_id` | （必須） | service account の ID |
| `anthropic_workspace_id` | `''` | workspace の ID。rule が 1 つの workspace だけを対象にするなら省略できる |
| `audits` | （必須） | 監査タイプ ID の空白区切り（`test-cleanup test-helpers` / `dead-code` など。一覧は audit skill の SKILL.md） |
| `cost` | `standard-10usd` | 下表 |
| `targets` | `''`（repo 全体） | 監査の対象パス（空白・カンマ・改行区切り。空白を含むパスは渡せない） |
| `exclude` | `''` | 対象から外すパス（空白・カンマ・改行区切り。空白を含むパスは渡せない） |
| `instructions` | `''` | repo 固有の追加の指示（生成物の制約・issue の起こし方など） |
| `allowed_tools` | `''` | Read / Glob / Grep / Edit / Write に加えて許すツール（カンマ区切り。例: `Bash(bin/next-issue-number)`） |
| `pr_paths` | `''`（= `targets`） | PR に含めるパス（空白・カンマ・改行区切り。空白を含むパスは渡せない）。`targets` が空なら必須（空だと作業ツリーの変更が全部 commit されるため、plan job で止める） |
| `skills_repo` | `jiikko/dotfiles` | audit skill と rules を取る public repo |
| `claude_code_version` | `2.1.309` | Claude Code CLI の版（WIF の環境変数を読むことを確かめた版） |

| cost | 用途 | モデル / effort | 予算の上限 | runner（job の打ち切り） |
|------|------|----------------|-----------|------------------------|
| `light-3usd` | workflow を変えたときの動作確認 | Sonnet 5.5 / medium | 3 USD | ubuntu-slim（15 分） |
| `standard-10usd` | 定期実行 | Fable 5.1 / high | 10 USD | ubuntu-slim（15 分） |
| `heavy-25usd` | 多めに回すとき | Fable 5.1 / xhigh | 25 USD | ubuntu-latest（30 分） |

予算は CLI の `--max-budget-usd` で、ターンを終えてから判定するので最後のターンの分だけ超えうる。上限・ターン数・時間で打ち切られても、それまでの変更で PR を作り、本文に「途中までの可能性がある」と書き足す。run の消費額・ターン数・所要時間・使ったモデルは Step Summary に出る。
