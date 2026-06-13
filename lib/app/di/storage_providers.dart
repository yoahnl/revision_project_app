import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/storage/kv_storage_port.dart';
import '../../core/storage/shared_preferences_kv_storage_adapter.dart';

final kvStorageProvider = Provider<KvStoragePort>((ref) {
  return SharedPreferencesKvStorageAdapter(SharedPreferencesAsync());
});
