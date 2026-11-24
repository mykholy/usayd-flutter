import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DecryptionException implements Exception {
  final String message;
  const DecryptionException(this.message);

  @override
  String toString() => 'DecryptionException: $message';
}

abstract class EncryptionService {
  Future<String> encrypt(String plaintext);
  Future<String> decrypt(String ciphertext);
}

class AesGcmEncryptionService implements EncryptionService {
  static const String _keyStorageKey = 'usayd_offline_aes_key';

  final FlutterSecureStorage? _secureStorage;
  enc.Key? _cachedKey;
  Future<enc.Key>? _keyInitFuture;

  AesGcmEncryptionService({
    FlutterSecureStorage? secureStorage,
    enc.Key? staticKey,
  }) : _secureStorage = secureStorage,
       _cachedKey = staticKey;

  /// Concurrency-safe key initialization
  Future<enc.Key> getOrCreateKey() async {
    final cached = _cachedKey;
    if (cached != null) {
      return cached;
    }

    if (_keyInitFuture != null) {
      return _keyInitFuture!;
    }

    _keyInitFuture = _doGetOrCreateKey();
    try {
      final key = await _keyInitFuture!;
      return key;
    } finally {
      _keyInitFuture = null;
    }
  }

  Future<enc.Key> _doGetOrCreateKey() async {
    final storage = _secureStorage ?? const FlutterSecureStorage();
    final storedBase64 = await storage.read(key: _keyStorageKey);

    if (storedBase64 != null && storedBase64.isNotEmpty) {
      final key = enc.Key.fromBase64(storedBase64);
      _cachedKey = key;
      return key;
    }

    // Generate fresh 256-bit cryptographically secure random key
    final freshKey = enc.Key.fromSecureRandom(32);
    await storage.write(key: _keyStorageKey, value: freshKey.base64);
    _cachedKey = freshKey;
    return freshKey;
  }

  @override
  Future<String> encrypt(String plaintext) async {
    final key = await getOrCreateKey();
    // 12-byte (96-bit) random IV/nonce per NIST SP 800-38D standard for AES-GCM
    final iv = enc.IV.fromSecureRandom(12);
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.gcm));

    final encrypted = encrypter.encrypt(plaintext, iv: iv);

    // Standard versioned envelope format: v1:<base64-iv>:<base64-ciphertext+tag>
    return 'v1:${iv.base64}:${encrypted.base64}';
  }

  @override
  Future<String> decrypt(String ciphertextEnvelope) async {
    final parts = ciphertextEnvelope.split(':');
    final String ivBase64;
    final String cipherBase64;

    if (parts.length == 3 && parts[0] == 'v1') {
      // Versioned envelope: v1:<iv>:<ciphertext>
      ivBase64 = parts[1];
      cipherBase64 = parts[2];
    } else if (parts.length == 2) {
      // Backwards-compatible legacy envelope: <iv>:<ciphertext>
      ivBase64 = parts[0];
      cipherBase64 = parts[1];
    } else {
      throw const DecryptionException('Malformed ciphertext envelope format.');
    }

    try {
      final key = await getOrCreateKey();
      final iv = enc.IV.fromBase64(ivBase64);
      final encrypted = enc.Encrypted.fromBase64(cipherBase64);
      final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.gcm));

      return encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      if (e is DecryptionException) rethrow;
      throw DecryptionException(
        'Decryption or integrity verification failed: $e',
      );
    }
  }
}
