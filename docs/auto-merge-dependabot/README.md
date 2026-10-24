# Auto-merge dependabot PR

開いている dependabot の PR を週次でまとめて確認し、CI が全て green なものを squash merge する。

呼び出し側の例: [sample.md](sample.md) / 本体: [`.github/workflows/auto-merge-dependabot.yml`](../../.github/workflows/auto-merge-dependabot.yml)

> **注意:** `permissions` は呼び出し側で宣言する必要がある（reusable workflow 内の `permissions` は呼び出し側の権限を超えられない）。

パラメータは無い。

## 仕組み

1. open な PR を列挙し、`author.is_bot == true` かつ login が `dependabot` / `dependabot[bot]` / `app/dependabot` に完全一致するものだけを対象にする
2. 自分自身（この workflow）のチェックを除外した上で、失敗（`FAILURE` / `ERROR` / `TIMED_OUT` / `CANCELLED` / `ACTION_REQUIRED` / `STARTUP_FAILURE`）が 1 つでもあれば PR を開いたまま残す
3. まだ実行中のチェックがあっても**待たない**。その PR は翌週の実行で再判定する
4. 全て green なら `gh pr merge --squash --delete-branch --match-head-commit <sha>` で merge する

## 設計上のポイント

- **PR 契機ではなく週次の定期実行**。PR ごとに起動しないので Actions の消費が少なく、`pull_request_target` 系の実行主体の問題も持ち込まない。checkout も行わないため PR 側のコードは一切実行されない
- **ポーリングしない**ので job は数十秒で終わる（`timeout-minutes: 1`）
- `--match-head-commit` により、判定した commit と merge 対象がずれていれば merge は失敗する
- merge に失敗した PR があれば job 全体を失敗させて気付けるようにしている
