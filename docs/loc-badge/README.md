# LOC Badge

ソースコードの行数をカウントし、SVG バッジを生成してリポジトリにコミットする。

呼び出し側の例: [sample.md](sample.md) / 本体: [`.github/workflows/loc-badge.yml`](../../.github/workflows/loc-badge.yml)

> **注意:** `permissions: contents: write` は呼び出し側で宣言する必要がある。reusable workflow 内の `permissions` は呼び出し側の権限を超えられない GitHub の仕様。

## パラメータ

| 入力 | デフォルト | 説明 |
|------|-----------|------|
| `source_dir` | `src` | カウント対象ディレクトリ |
| `badge_path` | `docs/loc-badge.svg` | SVG の出力先（親ディレクトリは自動生成される） |
| `exclude_dirs` | `''`（除外なし） | cloc から除外するディレクトリ名のカンマ区切りリスト（例: `docs,issues,vendor`） |

このワークフローは `workflow_dispatch` でも同じ入力を受け取るので、この repo 上から直接手動実行することもできる。

## 仕組み

1. `cloc` でコード行数をカウント（コメント・空行は除外）
2. shields.io 風の SVG バッジを生成
3. 変更があればコミット & push
