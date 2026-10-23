import 'package:shared_preferences/shared_preferences.dart';
import 'package:ukalab_core/ukalab_core.dart' show KeyValueStore;

/// 無料枠の使用回数（ukalab_core の `UsageQuota`）を SharedPreferences に保存する。
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
