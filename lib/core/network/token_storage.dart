import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'models/auth_tokens.dart';

abstract class AuthTokenStorage {
  Future<void> saveTokens(AuthTokens tokens);
  Future<AuthTokens?> getTokens();
  Future<void> clearTokens();
  Future<bool> hasAccessToken();
}

class SecureAuthTokenStorage implements AuthTokenStorage {
  static const String _storageKey = 'usayd_auth_tokens_v1';
  final FlutterSecureStorage _storage;

  const SecureAuthTokenStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<void> saveTokens(AuthTokens tokens) async {
    final jsonString = jsonEncode(tokens.toJson());
    await _storage.write(key: _storageKey, value: jsonString);
  }

  @override
  Future<AuthTokens?> getTokens() async {
    final jsonString = await _storage.read(key: _storageKey);
    if (jsonString == null || jsonString.isEmpty) return null;
    try {
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      return AuthTokens.fromJson(map);
    } catch (_) {
      await clearTokens();
      return null;
    }
  }

  @override
  Future<void> clearTokens() async {
    await _storage.delete(key: _storageKey);
  }

  @override
  Future<bool> hasAccessToken() async {
    final tokens = await getTokens();
    return tokens != null && tokens.accessToken.isNotEmpty;
  }
}

class InMemoryAuthTokenStorage implements AuthTokenStorage {
  AuthTokens? _tokens;

  @override
  Future<void> saveTokens(AuthTokens tokens) async {
    _tokens = tokens;
  }

  @override
  Future<AuthTokens?> getTokens() async {
    return _tokens;
  }

  @override
  Future<void> clearTokens() async {
    _tokens = null;
  }

  @override
  Future<bool> hasAccessToken() async {
    return _tokens != null && _tokens!.accessToken.isNotEmpty;
  }
}
