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

    test('encrypts and decrypts string payload accurately', () async {
      const plaintext = '{"lesson_id":"lsn-42","recitation_score":98.5}';
      final encrypted = await service.encrypt(plaintext);

      expect(encrypted, isNot(equals(plaintext)));
      expect(encrypted.contains(':'), isTrue);

      final decrypted = await service.decrypt(encrypted);
      expect(decrypted, equals(plaintext));
    });

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

        // Tamper with the ciphertext payload
        final tamperedBody =
            '${parts[1].substring(0, parts[1].length - 4)}AAAA';
        final tamperedEnvelope = '${parts[0]}:$tamperedBody';

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
