# dupscan gate

[dupscan](https://github.com/jiikko/dotfiles/tree/master/src/dupscan) の `gate` で、base から増えた重複 (既にある関数の写し) を止める。
dupscan は jiikko/dotfiles の `src/dupscan` を、呼び出し側が固定した commit で build する。Swift / Go を構文木で読むだけなので Linux の runner で足りる。

呼び出し側の例: [sample.md](sample.md) / 本体: [`.github/workflows/dupscan-gate.yml`](../../.github/workflows/dupscan-gate.yml)

## パラメータ

| 入力 | デフォルト | 説明 |
|------|-----------|------|
| `dotfiles_sha` | (必須) | dupscan を build する jiikko/dotfiles の commit (完全な SHA)。build と記録の版を一致させるため固定する |
| `go_version` | `1.25` | build に使う Go の版 |
| `runs_on` | `ubuntu-slim` | runner。git が 2.44 未満なら `--no-lazy-fetch` を外す shim を自動で置く |
| `timeout_minutes` | `15` | job の時間の上限 |
| `fail_new_exclusions` | `true` | 新しく足された除外・パスの除外で通した単位があれば rc=1 にする |
| `extra_args` | (空) | `dupscan gate` に足す引数 (例: `-strict-analysis`) |
| `run_metadata_schema` | `dupscan-run.v1` | 補助の記録 `dupscan-run.json` の `schema` の値。読む側の集計に合わせる |
| `artifact_name` | `dupscan-record` | 記録 (`dupscan-record.jsonl` と `dupscan-run.json`) を上げる artifact の名前 |

## 前提と注意

- base は PR なら base の SHA、push なら push の前の SHA (新しいブランチは `origin/<既定のブランチ>`)。checkout は `fetch-depth: 0`
- トリガー・paths の絞り込み・concurrency は呼び出し側に置く。master の push の run を取り消すと、その commit を検証しないまま次へ進むので、
  `cancel-in-progress` は PR だけにする形を勧める (sample.md)
- 補助の記録は run の ID・試行の番号・build と gate の outcome・記録の有無を持つ (gate が書く `-record` の行には入らない情報)
