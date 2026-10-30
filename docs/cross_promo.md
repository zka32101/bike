# うかラボ 相互紹介（クロスプロモ）

うかラボ各アプリの設定画面に「他のアプリもチェック！」を表示する。実装は `cross_promo_kit`
（`ukalab_core` の薄いラッパー経由）を使い、このアプリ独自の実装は持たない。

## 使い方（このアプリ）

| 項目 | 場所 |
|---|---|
| 初期化 | `lib/main.dart` の `ensureFirebaseInitialized()` の後で `unawaited(UkalabCrossPromo.init())` |
| 表示 | `lib/views/settings_view.dart` の末尾に `UkalabCrossPromoSection(currentAppId: kBikeApplicationId)` |
| appId | `lib/core/constants/app_ids.dart` の `kBikeApplicationId`（`com.yourwish.ukalab.bike_license`） |
| テスト | `test/cross_promo_test.dart` |

- `UkalabCrossPromo.init()` は Firebase が未初期化のときだけ初期化し、失敗しても例外を投げない。
  二重初期化にはならない。
- 掲載が0件のときは何も表示しない。
- 対象年齢は 16 歳以上中心（`docs/store/data_safety.md`）。大人向けのため `isChildDirected` は既定の false で、
  保護者ゲート（`beforeOpenStore`）は付けない。子ども向けに方針変更する場合は
  `isChildDirected: true` と `beforeOpenStore` が必須（kit の assert）。
- `currentAppId` は `ukalab_core` の `kUkalabAppIds` に含まれる本番 applicationId を渡す。

## Remote Config（運営作業）

掲載リストの中身は Firebase Remote Config の `cross_promo_apps`（JSON 配列）で配信する。コードでは変更できない。
未投入または `[]` の間は何も表示されない。

```json
[
  {
    "id": "<applicationId>",
    "name": "<アプリ名>",
    "tagline": "<ひとこと説明>",
    "iconUrl": "<アイコン画像のURL>",
    "storeUrl": "<ストアのURL>",
    "category": "うかラボ"
  }
]
```

- 項目・検証・投入手順の詳細は `cross_promo_kit` の `README.md` と `docs/ROLLOUT.md`（掲載リストの正は kit の `docs/cross_promo_apps.json`）を参照。
- 公開済みのアプリだけを載せる。投入先の Firebase プロジェクトは運営が判断する。
- 実際のストア URL・キーはこのリポジトリに書かない。
