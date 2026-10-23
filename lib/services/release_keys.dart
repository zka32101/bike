/// RevenueCat キーを検証して返す純関数。release で空なら StateError
/// （Fake に落とすと無料で購入扱いになるため、黙って継続しない）。
/// debug/テストでは空を許し、呼び出し側が Fake を使う。
String requireRevenueCatKey(String key, {required bool isRelease}) {
  if (isRelease && key.isEmpty) {
    throw StateError(
      'release ビルドに RevenueCat キーが注入されていません。'
      '--dart-define=RC_GOOGLE_KEY（iOS は RC_APPLE_KEY）を指定してください。',
    );
  }
  return key;
}
