abstract interface class KvStoragePort {
  Future<String?> readString(String key);

  Future<void> writeString(String key, String value);
}
