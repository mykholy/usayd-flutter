import 'dart:convert';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter_test/flutter_test.dart';
import 'package:usayd_flutter/core/offline/encryption/encryption_service.dart';

void main() {
  group('AesGcmEncryptionService', () {
    late AesGcmEncryptionService service;
    late enc.Key staticKey;

    setUp(() {
      staticKey = enc.Key.fromSecureRandom(32);
      service = AesGcmEncryptionService(staticKey: staticKey);
    });

    test('encrypts string into versioned v1 envelope format', () async {
      const plaintext = '{"lesson_id":"lsn-42","recitation_score":98.5}';
      final encrypted = await service.encrypt(plaintext);

      expect(encrypted, startsWith('v1:'));
      final parts = encrypted.split(':');
      expect(parts.length, equals(3));

      // Verify IV is 12 bytes (96 bits) per NIST SP 800-38D
      final ivBytes = base64Decode(parts[1]);
      expect(ivBytes.length, equals(12));

      final decrypted = await service.decrypt(encrypted);
      expect(decrypted, equals(plaintext));
    });

    test(
      'decrypts legacy unversioned 2-part envelope for backwards compatibility',
      () async {
        const plaintext = 'Legacy encrypted draft data';
        // Create legacy envelope: <iv-base64>:<ciphertext-base64>
        final iv = enc.IV.fromSecureRandom(16);
        final encrypter = enc.Encrypter(
          enc.AES(staticKey, mode: enc.AESMode.gcm),
        );
        final encrypted = encrypter.encrypt(plaintext, iv: iv);
        final legacyEnvelope = '${iv.base64}:${encrypted.base64}';

        final decrypted = await service.decrypt(legacyEnvelope);
        expect(decrypted, equals(plaintext));
      },
    );

    test(
      'produces unique ciphertext for same plaintext due to random IV',
      () async {
        const plaintext = 'Usayd Academy Secret Data';
        final c1 = await service.encrypt(plaintext);
        final c2 = await service.encrypt(plaintext);

        expect(c1, isNot(equals(c2)));
        expect(await service.decrypt(c1), equals(plaintext));
        expect(await service.decrypt(c2), equals(plaintext));
      },
    );

    test(
      'tampered ciphertext fails integrity check and throws DecryptionException',
      () async {
        const plaintext = 'Important Student Mark';
        final encrypted = await service.encrypt(plaintext);
        final parts = encrypted.split(':');

        // Tamper with the ciphertext payload in v1 envelope
        final tamperedBody =
            '${parts[2].substring(0, parts[2].length - 4)}AAAA';
        final tamperedEnvelope = 'v1:${parts[1]}:$tamperedBody';

        expect(
          () => service.decrypt(tamperedEnvelope),
          throwsA(isA<DecryptionException>()),
        );
      },
    );

    test('malformed ciphertext envelope throws DecryptionException', () async {
      expect(
        () => service.decrypt('not_a_valid_envelope'),
        throwsA(isA<DecryptionException>()),
      );
    });
  });
}
