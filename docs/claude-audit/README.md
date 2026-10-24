# Claude audit

Claude Code に audit skill（[jiikko/dotfiles](https://github.com/jiikko/dotfiles) の `_claude/skills/audit`）の監査タイプを回させ、変更を PR で出す。merge は人がレビューしてから行う。Claude はファイルを読んで書くだけで、テストもビルドも実行しない。

監査の対象は既定で Claude が監査タイプに合わせて選ぶ（`targets` を渡さない）。呼び出し側に書くのは、実行頻度・WIF の ID・PR に含める範囲・repo 固有の指示だけにする。

呼び出し側の例と監査タイプの checkbox の一覧: [sample.md](sample.md) / 本体: [`.github/workflows/claude-audit.yml`](../../.github/workflows/claude-audit.yml)

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

## 監査タイプの checkbox

workflow_dispatch に複数選択の入力が無く、入力は呼び出し側の workflow にしか定義できないので、監査タイプを 1 つずつ boolean の入力にして呼び出し側の `inputs:` に写す。名前は監査タイプ ID のままにする（`selected_audits_json` が true の入力の名前を ID として読む。監査タイプ以外の boolean の入力を置かない）。一覧は audit skill の SKILL.md「監査タイプ一覧」の写しで、skill に無い ID は Claude を起動する前（予算を使う前）に止まる。skill に監査タイプが増えたら、sample.md と呼び出し側に足す。入力は 25 個まで（`cost` と合わせていま 23 個）。既定でオンにしたいものは `default: true` にする。

## パラメータ

| 入力 | デフォルト | 説明 |
|------|-----------|------|
| `anthropic_organization_id` | （必須） | Claude Console の組織 ID |
| `anthropic_federation_rule_id` | （必須） | federation rule の ID |
| `anthropic_service_account_id` | （必須） | service account の ID |
| `anthropic_workspace_id` | `''` | workspace の ID。rule が 1 つの workspace だけを対象にするなら省略できる |
| `audits` | `''` | 監査タイプ ID の空白区切り（`test-cleanup test-helpers` / `dead-code` など）。`selected_audits_json` で 1 つも選ばれていない起動（schedule）で使う |
| `selected_audits_json` | `''` | 呼び出し側の `toJSON(inputs)`。監査タイプの checkbox のうち true のものを `audits` にする。checkbox があるのに 1 つも選ばれていなければ止める |
| `cost` | `standard-10usd` | 下表 |
| `targets` | `''`（監査タイプに合わせて Claude が選ぶ） | 監査の対象パス（空白・カンマ・改行区切り。空白を含むパスは渡せない） |
| `exclude` | `''` | 対象から外すパス（空白・カンマ・改行区切り。空白を含むパスは渡せない） |
| `instructions` | `''` | repo 固有の追加の指示（生成物の制約・issue の起こし方など） |
| `allowed_tools` | `''` | Read / Glob / Grep / Edit / Write に加えて許すツール（カンマ区切り。例: `Bash(bin/next-issue-number)`） |
| `pr_paths` | `''`（= `targets`） | PR に含めるパス（空白・カンマ・改行区切り。空白を含むパスは渡せない）。`targets` が空なら必須（空だと作業ツリーの変更が全部 commit されるため、plan job で止める）。skill の実行ログ（`issues/audit-log`）と起こした issue の置き場所も含める。外に変更が残ると、PR は作ったうえで job を失敗にする |
| `skills_repo` | `jiikko/dotfiles` | audit skill と rules を取る public repo |
| `claude_code_version` | `2.1.309` | Claude Code CLI の版（WIF の環境変数を読むことを確かめた版） |

| cost | 用途 | モデル / effort | 予算の上限 | runner（job の打ち切り） |
|------|------|----------------|-----------|------------------------|
| `light-3usd` | workflow を変えたときの動作確認 | Sonnet 5.5 / medium | 3 USD | ubuntu-slim（15 分） |
| `standard-10usd` | 定期実行 | Fable 5.1 / high | 10 USD | ubuntu-slim（15 分） |
| `heavy-25usd` | 多めに回すとき | Fable 5.1 / xhigh | 25 USD | ubuntu-latest（30 分） |

予算は CLI の `--max-budget-usd` で、ターンを終えてから判定するので最後のターンの分だけ超えうる。上限・ターン数・時間で打ち切られても、それまでの変更で PR を作り、本文に「途中までの可能性がある」と書き足す。run の消費額・ターン数・所要時間・使ったモデルは Step Summary に出る。
