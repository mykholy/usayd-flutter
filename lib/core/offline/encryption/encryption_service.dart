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

  AesGcmEncryptionService({
    FlutterSecureStorage? secureStorage,
    enc.Key? staticKey,
  }) : _secureStorage = secureStorage,
       _cachedKey = staticKey;

  Future<enc.Key> _getOrCreateKey() async {
    final cached = _cachedKey;
    if (cached != null) {
      return cached;
    }

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
    final key = await _getOrCreateKey();
    // 16-byte random IV/nonce for GCM
    final iv = enc.IV.fromSecureRandom(16);
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.gcm));

    final encrypted = encrypter.encrypt(plaintext, iv: iv);

    // Envelope format: base64(iv):base64(ciphertext+tag)
    return '${iv.base64}:${encrypted.base64}';
  }

  @override
  Future<String> decrypt(String ciphertextEnvelope) async {
    final parts = ciphertextEnvelope.split(':');
    if (parts.length != 2) {
      throw const DecryptionException('Malformed ciphertext envelope format.');
    }

    try {
      final key = await _getOrCreateKey();
      final iv = enc.IV.fromBase64(parts[0]);
      final encrypted = enc.Encrypted.fromBase64(parts[1]);
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
