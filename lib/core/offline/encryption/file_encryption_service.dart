import 'dart:io';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as enc;
import 'encryption_service.dart';

class FileEncryptionService {
  final AesGcmEncryptionService _encryptionService;

  FileEncryptionService({AesGcmEncryptionService? encryptionService})
    : _encryptionService = encryptionService ?? AesGcmEncryptionService();

  /// Encrypts raw binary/audio file bytes using NIST SP 800-38D AES-GCM (12-byte IV)
  Future<Uint8List> encryptBytes(Uint8List rawBytes) async {
    final iv = enc.IV.fromSecureRandom(12);
    final key = await _encryptionService.getOrCreateKey();
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.gcm));

    final encrypted = encrypter.encryptBytes(rawBytes, iv: iv);

    final builder = BytesBuilder();
    // Magic header 'USYD' (0x55, 0x53, 0x59, 0x44)
    builder.add([0x55, 0x53, 0x59, 0x44]);
    builder.addByte(1); // Version 1
    builder.addByte(iv.bytes.length); // 12 bytes
    builder.add(iv.bytes);
    builder.add(encrypted.bytes);
    return builder.toBytes();
  }

  /// Decrypts binary/audio file bytes back to original plaintext bytes
  Future<Uint8List> decryptBytes(Uint8List encryptedData) async {
    if (encryptedData.length < 18) {
      throw const DecryptionException('Encrypted file payload too short.');
    }

    if (encryptedData[0] != 0x55 ||
        encryptedData[1] != 0x53 ||
        encryptedData[2] != 0x59 ||
        encryptedData[3] != 0x44) {
      throw const DecryptionException('Invalid encrypted file magic header.');
    }

    final version = encryptedData[4];
    if (version != 1) {
      throw DecryptionException(
        'Unsupported file encryption version: $version',
      );
    }

    final ivLength = encryptedData[5];
    final ivBytes = encryptedData.sublist(6, 6 + ivLength);
    final cipherBytes = encryptedData.sublist(6 + ivLength);

    final key = await _encryptionService.getOrCreateKey();
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.gcm));

    try {
      final decrypted = encrypter.decryptBytes(
        enc.Encrypted(cipherBytes),
        iv: enc.IV(ivBytes),
      );
      return Uint8List.fromList(decrypted);
    } catch (e) {
      throw DecryptionException(
        'File decryption or integrity check failed: $e',
      );
    }
  }

  Future<File> encryptFile(File source, File destination) async {
    final raw = await source.readAsBytes();
    final encrypted = await encryptBytes(raw);
    return destination.writeAsBytes(encrypted, flush: true);
  }

  Future<File> decryptFile(File source, File destination) async {
    final encrypted = await source.readAsBytes();
    final decrypted = await decryptBytes(encrypted);
    return destination.writeAsBytes(decrypted, flush: true);
  }
}
