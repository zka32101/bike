# RevenueCat 設定ガイド（うかラボ 原付・バイク免許）

決定 CD-004（ukalab_core `docs/common_design/decision_log.md`）に基づく、シリーズ標準の課金体系です。
**価格は他アプリ同様「暫定」**で、運営が最終確認します。

## 課金体系（買い切り2種・全区分共通）

| 種類 | Entitlement ID | 価格（暫定） | 内容 |
|---|---|---|---|
| 広告なし | `noads` | ¥480 | 広告が表示されなくなる |
| プレミアム | `premium` | ¥1,500 | 広告なし＋プレミアム機能（下記） |

- どちらも買い切り（Non-Consumable）。期間パス（30日／90日）は採らない（D3）。
- 免許区分ごとの価格差・区分別パスは無い。全区分の問題と解説は無料。
- 旧体系（単一区分 ¥980 `single_category_pass_980`／全区分 ¥1,980 `all_category_set_pass_1980`）は廃止。ストア・RevenueCat に登録しない。
- 金額はコードに書かない。アプリは RevenueCat の Offering から価格を取得して表示する。

### プレミアム機能（実装済みのもののみ）

- 模擬テストの回数が無制限（無料は月の回数制限あり。`FreeTierLimits`）
- 模擬テストの分野別得点と「合格まであと◯問」
- 全分野の苦手分析（無料は上位の分野のみ。`FreeTierLimits`）
- 試験日までの学習計画（1日の目安）
- 危険予測シナリオの3本目以降（最初の2本は無料）

未実装の機能（弱点ドリル、試験直前モード、履歴書き出しなど `PremiumFeature` の他の項目）は、実装するまで案内・約束しない。

## 運営が登録する商品

| 項目 | 値 |
|---|---|
| 商品ID（広告なし） | `<app>_noads` |
| 商品ID（プレミアム） | `<app>_premium` |
| `<app>` | 運営が最終アプリIDに合わせて決定（候補: `bike_license`） |
| 商品タイプ | 買い切り（アプリ内アイテム／非消費型） |
| パッケージ名・Bundle ID | Android applicationId は `com.yourwish.ukalab.bike_license`（CD-005 で確定）。iOS は未作成 |

候補どおりなら `bike_license_noads` / `bike_license_premium`。商品IDと Entitlement ID は作成後に変更できないため、確定してから登録する。

## 手順

1. **ストアに商品を作成**（Google Play Console の「アプリ内アイテム」／App Store Connect の非消費型）
   - `<app>_noads`：価格は暫定 ¥480、説明「広告が表示されなくなります。」
   - `<app>_premium`：価格は暫定 ¥1,500、説明「広告が表示されなくなり、プレミアム限定の機能が使えます。」
   - 日本語（ja-JP）の名前と説明を必ず追加する。
2. **RevenueCat に Entitlement を作成**：`noads`、`premium`（ID は小文字のこの2つ）。
3. **RevenueCat に Products を登録**し、`<app>_noads` → `noads`、`<app>_premium` → `premium` に紐付ける。
4. **Offering を作成**（現行 Offering に設定）：パッケージは買い切り2種（広告なし／プレミアム）のみ。期間パッケージ（週・月・年・30日・90日など）は入れない。
5. **SDK キーの設定**：キーは RevenueCat の公開 SDK キー（Android／iOS 別）。設定箇所と手順は別途管理（このドキュメントでは扱わない）。

## アプリ側の仕組み

- 権利管理は `app_common_kit` の `EntitlementService`。権利名は `noads` / `premium`。
- 購入画面：`lib/views/paywall_view.dart`（Offering の商品を表示。購入と復元）。
- 設定画面の「プラン」に現在のプランと購入・復元の導線がある。

## 確認（内部テスト）

- [ ] ライセンステスターで `noads` を購入 → 広告が出ない、プレミアム機能はロックのまま
- [ ] `premium` を購入 → 広告が出ない、上記プレミアム機能が使える
- [ ] 「購入を復元」で復元できる（再インストール後を含む）
- [ ] 購入画面の価格が Offering の価格と一致する（暫定価格のまま公開しない）

## トラブルシューティング

- 商品が表示されない：Offering が現行に設定されているか、商品が「有効」か、パッケージ名がストア登録のアプリと一致するかを確認。
- 購入が権利に反映されない：Products と Entitlement の紐付け（手順3）を確認。
- Android `BILLING_SERVICE_DISCONNECTED`：Google Play 対応端末・Play ストアのバージョンを確認。

## appID 変更に伴う新ID登録（CD-005）

applicationId を `com.yourwish.bikelicense` から `com.yourwish.ukalab.bike_license` に変更した。商品IDは変更しない。Play Console 未登録のため、以下は新IDで新規登録する（運営作業）。

- RevenueCat：Android アプリを新パッケージ名で登録し、公開 SDK キー（`RC_GOOGLE_KEY`）を更新
- AdMob：アプリを新パッケージ名で登録（ストア連携）。アプリID・広告ユニットIDが変わる場合は secret（ADMOB_APP_ID / AD_*_ID）も更新
- Firebase：新IDの Android アプリを追加し、google-services.json を再発行、secret `GOOGLE_SERVICES_JSON_BASE64` を更新（debug は `.debug` サフィックス付きも同一ファイルに含まれる）
- Google Play Console：新パッケージ名でアプリを作成
