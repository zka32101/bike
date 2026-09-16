# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
