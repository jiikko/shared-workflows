# SwiftLint

SwiftLint を実行する。公式 Docker image `ghcr.io/realm/swiftlint` を使って lint を走らせる。

> **前提:** 呼び出し側リポジトリのルートに `.swiftlint.yml` が必要（`--config .swiftlint.yml` 固定で渡している）。

呼び出し側の例: [sample.md](sample.md) / 本体: [`.github/workflows/swiftlint.yml`](../../.github/workflows/swiftlint.yml)

## パラメータ

| 入力 | デフォルト | 説明 |
|------|-----------|------|
| `swiftlint_version` | `0.63.2` | 使用する SwiftLint のバージョン（`ghcr.io/realm/swiftlint` のタグ） |

> **補足:** default が `0.63.2` なのは、各 app の SwiftLintPlugins (SPM) が resolve する 0.63.x に合わせつつ、0.63.0 に残る誤検知（`unneeded_escaping` / `async_without_await`）を避けるため。詳しい経緯は `swiftlint.yml` 内のコメントを参照。
