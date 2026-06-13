import 'package:shared_preferences/shared_preferences.dart';

import 'kv_storage_port.dart';

class SharedPreferencesKvStorageAdapter implements KvStoragePort {
  SharedPreferencesKvStorageAdapter(this._preferences);

  final SharedPreferencesAsync _preferences;

  @override
  Future<String?> readString(String key) {
    return _preferences.getString(key);
  }

  @override
  Future<void> writeString(String key, String value) {
    return _preferences.setString(key, value);
  }
}
