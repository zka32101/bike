# 起動時クラッシュ調査 — ローカル確認用引き継ぎ

**作成日**: 2026-09-20
**関連コミット**: `952ae9f` (Build #94, CI で本番署名 AAB/APK 生成成功)

## 最有力の原因: Firebase 設定の不一致

`lib/firebase_options.dart` が **プレースホルダー（ダミー）のまま** になっています。

```dart
// lib/firebase_options.dart
apiKey: 'AIzaSyDummy_Firebase_API_Key_For_Development',
appId: '1:123456789:android:abc123def456ghi',
projectId: 'bike-license-project',
iosBundleId: 'com.example.bike',   // 実際のパッケージ名は com.yourwish.bikelicense
```

`lib/main.dart` はこの値を明示的に Firebase 初期化に渡している:

```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

一方、Android ネイティブ側 (`com.google.gms.google-services` Gradle プラグイン) は
CI の `GOOGLE_SERVICES_JSON_BASE64` Secret から生成された **本物の** `android/app/google-services.json`
を使って Firebase を初期化しようとします。

→ **Flutter 側 (ダミー) と Android 側 (本物) で Firebase の projectId / appId が食い違う**ため、
`Firebase.initializeApp()` 呼び出し時に設定不一致で例外が発生し、起動直後にクラッシュしている可能性が非常に高いです。
(典型的には `[core/duplicate-app]` やオプション不一致の例外)

## ローカルでの再現手順

```bash
git clone https://github.com/zka32101/bike.git
cd bike
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs

# 実機/エミュレータを接続した状態で
flutter run --release
```

クラッシュ発生時のログ:
```bash
adb logcat | grep -i "firebase\|FATAL\|AndroidRuntime"
```

`FirebaseApiNotAvailableException` や `IllegalStateException` 系のメッセージ、
または `[core/duplicate-app]` が出ていれば、上記の原因で確定です。

デバッグビルド (`flutter build apk --debug`) は `scripts/generate_google_services_json.py` が
生成するダミー `google-services.json` を使うため、Android 側も Flutter 側も両方ダミーで**一致してしまい**、
クラッシュが再現しない可能性があります。**リリースビルドまたは本物の `google-services.json` を使った検証が必要です。**

## 修正方法: flutterfire configure をローカルで実行する

**注意**: `flutterfire configure` はブラウザでの Google アカウント認証 (`firebase login`) が必須のため、
クラウド実行環境（このセッション）では自動実行できません。**ユーザーのローカル PC で実行してください。**

### 前提条件
- Flutter SDK インストール済み（`flutter --version` で確認）
- Node.js インストール済み（Firebase CLI 用）
- 対象の Firebase プロジェクトへのオーナー/編集者アクセス権を持つ Google アカウント

### 手順

```bash
# 1. リポジトリを最新化
cd bike
git pull origin main

# 2. Firebase CLI インストール（未導入の場合）
npm install -g firebase-tools

# 3. ブラウザが開き Google アカウントでログインを求められる
firebase login

# 4. FlutterFire CLI インストール（未導入の場合）
dart pub global activate flutterfire_cli

# 5. 対話形式でプロジェクト設定を生成
#    -> Firebase プロジェクトの選択肢が表示されるので、実際のプロジェクトを選ぶ
#    -> プラットフォームは Android にチェック（iOS/Web を後で使う予定があれば併せて選択）
flutterfire configure
```

`flutterfire configure` を実行すると:
- `lib/firebase_options.dart` が実際のプロジェクト値で **上書き** される
- `android/app/google-services.json` も実際の値に更新される（CI の Secret と内容が一致するか要確認）

### 実行後の確認

```bash
# ダミー値が残っていないか確認
grep -n "Dummy\|123456789\|bike-license-project" lib/firebase_options.dart
# → 何も出力されなければ正常に置き換わっている

# 実機/エミュレータで起動確認
flutter run --release
```

問題なければコミット & プッシュ:

```bash
git add lib/firebase_options.dart android/app/google-services.json
git commit -m "Configure real Firebase project via flutterfire configure"
git push origin main
```

**注意**: `android/app/google-services.json` は通常 `.gitignore` されているか確認すること。
CI では `GOOGLE_SERVICES_JSON_BASE64` Secret から生成される運用なので、
ローカル生成物をそのままコミットするかは既存の運用ルール（CLAUDE.md 参照）と要相談。
少なくとも `lib/firebase_options.dart` はコミットが必要（Flutter 側の初期化に必須のため）。

### 代替: ネイティブ設定のみで初期化する方法（Android 限定）
Android のみサポートすればよい場合、`Firebase.initializeApp()` を `options` なしで呼び出し、
`google-services.json` の値だけで初期化する方法もあるが、iOS/Web 対応時に同じ問題が再発するため非推奨。

## その他、起動時クラッシュの副次的な候補（優先度は低いが記録）

- `android/app/proguard-rules.pro` は Firebase / AdMob / RevenueCat の keep ルールがあり、
  難読化由来のクラッシュの可能性は低い
- AdMob App ID は環境変数未設定時 Google 公式テスト ID にフォールバックするため、通常はクラッシュ要因にならない
- RevenueCat (`purchases_flutter`) の初期化コードは `lib/main.dart` で **コメントアウトされている** ため対象外

## 次回アップデート時の TODO: アプリアイコン変更

ユーザーから新しいアイコン画像を受領済み。次回更新時に差し替える。

- 画像: `docs/handoff/assets/next_app_icon_1000x1000.png` (1000x1000px, PNG)
- 元ファイル: 「Friendly Motorcycle and License Booklet Icon.png」(Google Drive)
- 差し替え対象: `android/app/src/main/res/mipmap-*/ic_launcher.png` 各解像度
  (推奨: `flutter_launcher_icons` パッケージ導入で自動生成、またはAndroid Studio の
  Image Asset Studio で mipmap 各解像度を再生成)
