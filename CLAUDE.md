# Bike License Kore - プロジェクト運用ガイド

原付・バイク免許特化の学科試験対策アプリ

## プロジェクト概要

- **アプリ名**: 原付・バイク免許コレ！
- **プラットフォーム**: Flutter (iOS/Android)
- **主要機能**: 二輪免許学科試験対策、問題集、進捗管理
- **ステータス**: ビルド・デプロイ準備完了

## 環境セットアップ

### 前提条件
- Flutter 3.44.4+
- Java 17+
- Android SDK (API Level 31+)
- Git

### ローカルセットアップ

```bash
# リポジトリクローン
git clone https://github.com/zka32101/bike.git
cd bike

# 依存関係インストール
flutter pub get

# コード生成
flutter pub run build_runner build

# 分析・テスト
flutter analyze
flutter test
```

## ビルドプロセス

### デバッグビルド（ローカル）

```bash
# APK ビルド
flutter build apk --debug

# インストール＆実行
flutter run
```

### リリースビルド（本番環境）

**前提条件:**
- 本番キーストア: `android/keystore/release_prod.jks`
- 環境変数設定:
  ```bash
  export KEYSTORE_PASSWORD="<password>"
  export KEY_PASSWORD="<password>"
  ```

**コマンド:**

```bash
# APK ビルド
flutter build apk --release

# AAB ビルド (Google Play Store用)
flutter build appbundle --release
```

**出力場所:**
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- AAB: `build/app/outputs/bundle/release/app-release.aab`

## CI/CD パイプライン

### GitHub Actions ワークフロー

**トリガー:**
- `push` to main/master
- `pull_request` to main/master
- Manual trigger (`workflow_dispatch`)

**ジョブ:**

1. **Prepare Build**
   - Dart 分析
   - テスト実行
   - コード生成 (build_runner)

2. **Build Android APK** (デバッグ)
   - Firebase 設定検証
   - Google Services JSON 生成
   - デバッグ APK ビルド
   - Artifact アップロード

3. **Build Release APK** (本番)
   - 本番キーストア署名
   - リリース APK ビルド
   - リリース AAB ビルド
   - Artifact アップロード

### GitHub Secrets (必須)

```
KEYSTORE_PASSWORD=<本番キーストアパスワード>
KEY_PASSWORD=<本番キー対応パスワード>
GOOGLE_SERVICES_JSON_BASE64=<Firebase config (Base64)>
```

## セキュリティ設定

### キーストア管理

**本番キーストア:**
- ファイル: `android/keystore/release_prod.jks`
- .gitignore に登録（リポジトリには含めない）
- パスワードは GitHub Secrets で管理

**署名設定:**
```
build.gradle.kts で自動選択:
1. KEYSTORE_PASSWORD 環境変数が設定かつ本番キーストア存在 → 本番署名
2. それ以外 → デバッグ署名（フォールバック）
```

### Firebase 設定

**google-services.json:**
- CI 環境では GOOGLE_SERVICES_JSON_BASE64 secret から自動生成
- ローカル環境では scripts/generate_google_services_json.py で生成（デバッグ用）

**生成スクリプト:**
```bash
python3 scripts/generate_google_services_json.py
```

## Google Play Store デプロイ

### 事前準備

1. **Google Play Console 登録**
   - Developer Account 作成 ($25 USD)
   - https://play.google.com/console

2. **App Signing 設定**
   - Google Play が署名キーを管理
   - Upload Key (開発者が保有) で署名する AAB をアップロード

3. **App 情報設定**
   - App Name, Description
   - Category, Content Rating
   - Privacy Policy URL
   - Screenshots (5枚以上推奨)
   - App Icon (512x512px PNG)

### デプロイ手順

1. **AAB ファイル取得**
   ```
   GitHub Actions → Latest Build → Artifacts
   → aab-release-test → app-release.aab ダウンロード
   ```

2. **Play Console へアップロード**
   ```
   Google Play Console
   → アプリを作成 → リリース管理 → 本番環境
   → AAB をアップロード
   ```

3. **リリース情報入力**
   - バージョン番号 (pubspec.yaml と一致)
   - リリースノート (日本語推奨)
   - ロールアウト率 (テスト: 5-10%, 本番: 100%)

4. **審査提出**
   ```
   確認 → リリース準備完了 → リリースを確認
   ```

## バージョン管理

### バージョン番号形式

**pubspec.yaml:**
```yaml
version: <major>.<minor>.<patch>+<build>
```

例:
```yaml
version: 0.1.0+1  # 0.1.0 (version name) + build 1
version: 0.2.0+2  # 0.2.0 (version name) + build 2
```

**更新時の手順:**

```bash
# 1. pubspec.yaml でバージョン更新
# version: 0.1.0+1 → 0.2.0+2

# 2. コミット
git add pubspec.yaml
git commit -m "Bump version to 0.2.0"

# 3. push でビルドトリガー
git push origin main

# 4. GitHub Actions でビルド完了待機
# → Artifacts から AAB/APK をダウンロード

# 5. Play Store にデプロイ
```

## Firebase 統合

### 現在の設定

- **Firebase Core**: 初期化済み
- **Authentication**: 準備完了 (未実装)
- **Firestore**: 準備完了 (未実装)
- **Analytics**: 準備完了 (未実装)
- **Crashlytics**: 準備完了 (未実装)
- **Remote Config**: 準備完了 (未実装)

### 設定方法

**google-services.json:**
```bash
# ローカル開発
python3 scripts/generate_google_services_json.py

# CI 環境
# GOOGLE_SERVICES_JSON_BASE64 secret から自動生成
```

## 依存管理

### 主要パッケージ

| パッケージ | 用途 | バージョン |
|-----------|------|----------|
| flutter_riverpod | 状態管理 | ^2.5.1 |
| firebase_core | Firebase 初期化 | ^2.27.0 |
| purchases_flutter | 課金 (RevenueCat) | ^8.0.0 |
| google_mobile_ads | 広告 (Google Mobile Ads) | ^6.0.0 |
| lottie | アニメーション | ^3.1.0 |
| shared_preferences | ローカル永続化 | ^2.2.2 |
| freezed | コード生成 | ^2.5.0 |

### アップデート手順

```bash
# 依存関係確認
flutter pub outdated

# アップデート実行
flutter pub upgrade

# または特定パッケージのみ
flutter pub upgrade <package_name>

# ロック
flutter pub get
```

## トラブルシューティング

### ビルドエラー

**Java コンパイルエラー**
```
Error: @Override annotation method does not override...
```
→ `purchases_flutter` のバージョン確認 (^8.0.0+)

**Firebase 設定エラー**
```
Error: No matching client found for package name...
```
→ google-services.json で package name 確認

**Gradle ビルドエラー**
```
Error: Gradle build failed
```
→ `flutter clean` → `flutter pub get` → 再ビルド

### CI/CD エラー

**GitHub Actions ビルド失敗**
1. ワークフローログ確認: Actions → Latest Run → ジョブを選択
2. エラーログから原因特定
3. ローカルで再現テスト
4. コミット＆プッシュで再実行

## 運用チェックリスト

### 日次確認

- [ ] GitHub Actions ビルドが成功しているか
- [ ] Firebase Console に異常がないか

### リリース前チェック

- [ ] pubspec.yaml バージョン更新
- [ ] CHANGELOG.md 更新
- [ ] ローカルでテストビルド成功
- [ ] Play Console app listing 確認
- [ ] プライバシーポリシー URL 確認

### リリース後

- [ ] Play Store での表示確認
- [ ] インストール・起動テスト
- [ ] Crashlytics でエラーモニタリング
- [ ] Analytics でユーザー行動確認

## 参考リンク

- [Flutter 公式ドキュメント](https://flutter.dev/docs)
- [Google Play Console](https://play.google.com/console)
- [Firebase Console](https://console.firebase.google.com)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

## 連絡先・質問

プロジェクト関連の質問や問題があれば、GitHub Issues で報告してください。

---

**最終更新**: 2026-09-16  
**ビルドステータス**: ✓ 本番環境対応完了
