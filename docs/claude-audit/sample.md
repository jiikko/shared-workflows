# Claude audit の呼び出し例

```yaml
# .github/workflows/claude-audit.yml
name: Claude audit

on:
  schedule:
    - cron: '17 18 * * 0'  # 毎週月曜 03:17 JST
  workflow_dispatch:
    inputs:
      cost:
        description: '実行コスト (API の予算の上限。light-10usd は workflow の動作確認用)'
        type: choice
        default: standard-30usd
        options: [light-10usd, standard-30usd, heavy-50usd]
      # 監査タイプの checkbox は下の「監査タイプの checkbox」から写す

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
      cost: ${{ inputs.cost || 'standard-30usd' }}
      audits: test-cleanup test-helpers              # schedule (checkbox が無い起動) の監査タイプ
      selected_audits_json: ${{ toJSON(inputs) }}  # 手動起動で checkbox の選択を使う
      # Claude が触りうるコードの置き場所と、skill の実行ログ (issues/audit-log)・起こした issue の置き場所
      pr_paths: src,Tests,issues/**
      instructions: |
        - (repo 固有の制約。生成物を作り直せない場所・issue の起こし方など)
```

## 監査タイプの checkbox

呼び出し側の `on.workflow_dispatch.inputs` に写す。理由と規則は [README.md](README.md) の「監査タイプの checkbox」。

```yaml
      design:
        description: '設計: 設計改善'
        type: boolean
        default: false
      responsibility:
        description: '設計: 責務集中'
        type: boolean
        default: false
      duplication:
        description: '設計: コード重複'
        type: boolean
        default: false
      polymorphism:
        description: '設計: ポリモーフィズム置換'
        type: boolean
        default: false
      leaky-abstraction:
        description: '設計: 抽象境界の具象漏れ'
        type: boolean
        default: false
      encapsulation:
        description: '設計: 知識の帰属'
        type: boolean
        default: false
      ui-components:
        description: '設計: UIコンポーネント共通化'
        type: boolean
        default: false
      ux:
        description: 'UX: UX改善'
        type: boolean
        default: false
      security:
        description: '品質: セキュリティ'
        type: boolean
        default: false
      resource-leaks:
        description: '品質: リソースリーク'
        type: boolean
        default: false
      broken-code:
        description: '品質: 壊れたコード'
        type: boolean
        default: false
      dead-code:
        description: '品質: デッドコード'
        type: boolean
        default: false
      error-handling:
        description: '品質: エラーハンドリング'
        type: boolean
        default: false
      false-green:
        description: '品質: 偽の緑'
        type: boolean
        default: false
      performance:
        description: '品質: パフォーマンス'
        type: boolean
        default: false
      concurrency:
        description: '品質: 並行・排他'
        type: boolean
        default: false
      test-cleanup:
        description: 'テスト: 無意味テスト削除'
        type: boolean
        default: false
      test-helpers:
        description: 'テスト: テストヘルパー共通化'
        type: boolean
        default: false
      dependency:
        description: '管理: 依存関係'
        type: boolean
        default: false
      ci:
        description: '管理: CI の構成'
        type: boolean
        default: false
      lint-from-done:
        description: '改善: lint転用調査'
        type: boolean
        default: false
      general:
        description: '総合: 総合課題発見'
        type: boolean
        default: false
```
