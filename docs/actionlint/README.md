# actionlint

呼び出し側の `.github/workflows/` を [actionlint](https://github.com/rhysd/actionlint) で検査する。`run:` の shell は shellcheck でも検査する。

呼び出し側の例: [sample.md](sample.md) / 本体: [`.github/workflows/actionlint.yml`](../../.github/workflows/actionlint.yml)

## パラメータ

| 入力 | デフォルト | 説明 |
|------|-----------|------|
| `actionlint_version` | `1.7.12` | actionlint の版 (先頭の `v` を除く)。`go install` で入れるので、取ってきたものは sum.golang.org で照合される |
| `runs_on` | `ubuntu-latest` | runner。shellcheck が入っていないと止まる (actionlint は shellcheck が無いと `run:` の検査を黙って飛ばすため) |

## 前提と注意

- トリガー・paths の絞り込みは呼び出し側に置く。`.github/workflows/**` を変えた push / PR で回す形を勧める (sample.md)
- dependabot の PR は workflow のファイルしか変えないので、ほかの CI が起動しない repo では、この検査がその PR の唯一のチェックになる。
  [auto-merge-dependabot](../auto-merge-dependabot/README.md) は失敗したチェックが無ければマージするので、チェックが 0 本の PR は何も確かめずにマージされる
- この repo の workflow も `self-test.yml` がこの workflow を呼んで検査する
