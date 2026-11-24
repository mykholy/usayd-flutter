import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter_test/flutter_test.dart';
import 'package:usayd_flutter/core/offline/encryption/encryption_service.dart';
import 'package:usayd_flutter/core/offline/encryption/file_encryption_service.dart';

void main() {
  group('FileEncryptionService', () {
    late AesGcmEncryptionService aesService;
    late FileEncryptionService fileService;

    setUp(() {
      final staticKey = enc.Key.fromSecureRandom(32);
      aesService = AesGcmEncryptionService(staticKey: staticKey);
      fileService = FileEncryptionService(encryptionService: aesService);
    });

    test('encrypts and decrypts binary audio bytes accurately', () async {
      // Simulate raw Quran audio recitation bytes (e.g., MP3/M4A fragment)
      final rawAudio = Uint8List.fromList(
        List<int>.generate(256, (i) => (i * 7 + 13) % 256),
      );

      final encrypted = await fileService.encryptBytes(rawAudio);

      // Verify format
      expect(encrypted.length, greaterThan(rawAudio.length));
      // Magic header 'USYD'
      expect(encrypted.sublist(0, 4), equals([0x55, 0x53, 0x59, 0x44]));
      // Version 1
      expect(encrypted[4], equals(1));
      // 12-byte IV length
      expect(encrypted[5], equals(12));

      final decrypted = await fileService.decryptBytes(encrypted);
      expect(decrypted, equals(rawAudio));
    });

    test('rejects corrupted or tampered file data', () async {
      final raw = Uint8List.fromList(
        utf8.encode('Surah Al-Fatihah audio data'),
      );
      final encrypted = await fileService.encryptBytes(raw);

      // Tamper with payload byte
      final tampered = Uint8List.fromList(encrypted);
      tampered[tampered.length - 1] ^= 0xFF;

      expect(
        () => fileService.decryptBytes(tampered),
        throwsA(isA<DecryptionException>()),
      );
    });

    test('rejects payload with invalid magic bytes', () async {
      final invalidHeader = Uint8List.fromList([
        0x00, 0x00, 0x00, 0x00, 1, 12, // Bad magic
        ...List.filled(30, 1),
      ]);

      expect(
        () => fileService.decryptBytes(invalidHeader),
        throwsA(isA<DecryptionException>()),
      );
    });
  });
}
