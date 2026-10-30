# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- 読み物「交差点での右左折と優先関係」(bike_reading-0001)を追加(`assets/experience/chapter_readings_bike.jsonl`、ukalab_core の `ChapterReading` 形式)。手順(steps)と表(table)で整理。「役立つ情報」の先頭に入口、読み物一覧→詳細、末尾に確認問題リンク(`ReadingQuestionLinks`)と危険予測への導線。出典は「自作（AI下書き由来。体験コンテンツのため専門家確認は不要と判断）」で、「専門家確認済み」とは書かない。
- 危険予測への参照は、アプリ側の対応表ではなく core の `ChapterReading.relatedLinks`(`kind: hazard`、id は `scenarioId`)で表す。読み込み時に参照先の実在を検査する。
- 毎日の練習で誤答したとき、関連する読み物があれば core の `RelatedReadingsCard`(誤答原因の選択欄なしの単体カード)で「読み物でおさらい」を出す(`AnswerResultOverlay.wrongAnswerExtra`)。関連が無ければ何も出ず、正解時も出ない。
- 読み物の確認問題リンクは「まず確認する5問」だけ先に出し、「すべて見る」で全件に広げる。表は3列(場面・先に確かめること・基本の動き)にし、「つまずきやすい点」は表の下の箇条書きへ移した(内容は変更なし)。
- 読み物の画面・誤答導線には広告を置かない(静的ガードのテストあり)。

### Changed

- 読み物の試作フラグ(`READING_PROTOTYPE` / `showReadingPrototype`)は廃止(#195 の試作の位置づけを本番化)。入口は常に表示。
- ukalab_core を v0.86.0 から v0.87.0 に更新(読み物の表現拡張等は追加のみ・後方互換。このPRでは新機能は未使用)。pubspec.lock は一時 workflow で再生成。
- 危険予測シナリオ14本の sourceRef を事実に合う表記へ訂正(2026-10-28)。「専門家確認済み」→「AI下書き由来。体験コンテンツのため専門家確認は不要と判断」。専門家確認は実施していなかったため(#192の記述の訂正)。contentVer "2"→"3"。`validateHazardScenarios` のコメント・メッセージの「空=専門家確認済み」も「空=通常扱い」へ修正(検証ロジックは不変)。本文は変更なし。
- 専門家確認済みの AI 下書きデータ(問題 x570〜x609 を5区分、危険予測シナリオ14本)から `contentStatus: ai-draft` を外し、sourceRef を「専門家確認済み」に更新(2026-10-28)。内容は変更なし。
- 危険予測シナリオの画面注記を「学習用の架空シナリオ(AI下書き・専門確認前)」から「体験用の架空シナリオです」へ変更(`kHazardDraftNotice` を `kHazardExperienceNotice` に置換、一覧・プレイ画面とも常時表示)。体験コンテンツのため専門家確認は不要との判断による。「専門家確認済み」とは表示しない。シナリオ本文は変更なし。憧れバイク図鑑・技能試験のコツの注記は未決のため据え置き(2026-10-28)。

## [0.1.0] - 2026-09-16

### Added

**Core Features**
- 二輪免許学科試験対策機能（原付～大型二輪）
- 問題集機能（複数問題タイプ対応）
- 進捗管理・統計機能
- オフラインモード対応

**Infrastructure**
- Firebase Core 統合（初期化済み）
- Google Mobile Ads 統合（AdMob）
- RevenueCat 課金機能（サブスクリプション対応）
- Lottie アニメーション統合
- 音声効果機能（just_audio）

**CI/CD & Deployment**
- GitHub Actions ワークフロー構築
  - Dart 分析・テスト自動実行
  - Debug APK 自動ビルド
  - Release APK/AAB 自動ビルド
- 本番キーストア署名設定
- Firebase Google Services 自動生成
- Artifact 自動アップロード

**Code Quality**
- Flutter Lints 設定
- build_runner コード生成設定
- Freezed データクラス生成

### Technical Details

**Dependencies**
- flutter_riverpod: ^2.5.1 (状態管理)
- firebase_core: ^2.27.0 (Firebase初期化)
- firebase_auth: ^4.17.4 (認証・準備完了)
- cloud_firestore: ^4.15.4 (データベース・準備完了)
- firebase_analytics: ^10.8.5 (分析・準備完了)
- firebase_crashlytics: ^3.4.13 (クラッシュ報告・準備完了)
- firebase_remote_config: ^4.3.14 (リモート設定・準備完了)
- purchases_flutter: ^8.0.0 (RevenueCat課金)
- google_mobile_ads: ^6.0.0 (Google Mobile Ads)
- lottie: ^3.1.0 (アニメーション)
- shared_preferences: ^2.2.2 (ローカル永続化)
- freezed: ^2.5.0 (コード生成)
- json_serializable: ^6.7.1 (JSON シリアライズ)
- flutter_local_notifications: ^17.1.0 (通知)
- connectivity_plus: ^6.0.0 (ネットワーク状態監視)
- intl: ^0.19.0 (国際化)

**Build Configuration**
- Flutter 3.44.4
- Java 17
- Android SDK API Level 31+
- NDK 27.0.12077973
- Multi-dex 有効化
- ProGuard 最適化有効化

### Known Issues & Limitations

- Firebase Authentication: 実装は未開始（設定のみ）
- Firestore: 実装は未開始（設定のみ）
- Analytics: 実装は未開始（設定のみ）
- Crashlytics: 実装は未開始（設定のみ）
- Remote Config: 実装は未開始（設定のみ）

### Documentation

- CLAUDE.md: プロジェクト運用ガイド完成
- セットアップ・ビルド手順完備
- CI/CD パイプライン詳細ドキュメント
- Play Store デプロイ手順完全ガイド

---

## Future Releases

### [0.2.0] - Planned

- Firebase Authentication 実装
- Firestore データベース統合
- Analytics イベント追跡
- Crashlytics エラーレポート
- Remote Config 機能フラグ
- ユーザープロフィール機能
- 学習記録の同期機能

### [0.3.0] - Planned

- iOS リリース準備
- App Store Connect 統合
- クラウドバックアップ機能
- ユーザー間スコアリング
- 学習ガイド AI 統合

---

**Latest Update**: 2026-09-16
**Status**: ✓ Production Ready (Build #78)
