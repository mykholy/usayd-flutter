import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class OfflineStorage {
  Future<void> write(String key, String value);
  Future<String?> read(String key);
  Future<void> delete(String key);
  Future<Map<String, String>> readAll();
  Future<void> clear();
}

class SecureOfflineStorage implements OfflineStorage {
  final FlutterSecureStorage _storage;

  const SecureOfflineStorage([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);

  @override
  Future<Map<String, String>> readAll() => _storage.readAll();

  @override
  Future<void> clear() => _storage.deleteAll();
}

class InMemoryOfflineStorage implements OfflineStorage {
  final Map<String, String> _data = {};

  @override
  Future<void> write(String key, String value) async {
    _data[key] = value;
  }

  @override
  Future<String?> read(String key) async {
    return _data[key];
  }

  @override
  Future<void> delete(String key) async {
    _data.remove(key);
  }

  @override
  Future<Map<String, String>> readAll() async {
    return Map<String, String>.from(_data);
  }

  @override
  Future<void> clear() async {
    _data.clear();
  }
}
