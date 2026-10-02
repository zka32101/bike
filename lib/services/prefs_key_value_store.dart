import 'package:shared_preferences/shared_preferences.dart';
import 'package:yourwish_kentei/yourwish_kentei.dart' show KeyValueStore;

/// 無料枠の使用回数（yourwish_kentei の `UsageQuota`）を SharedPreferences に保存する。
class PrefsKeyValueStore implements KeyValueStore {
  PrefsKeyValueStore(this._prefs);

  final SharedPreferences _prefs;

  @override
  String? read(String key) => _prefs.getString(key);

  @override
  Future<void> write(String key, String value) async {
    await _prefs.setString(key, value);
  }
}
