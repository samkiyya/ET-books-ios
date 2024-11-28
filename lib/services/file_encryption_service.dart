import 'dart:io';

import 'package:encrypt/encrypt.dart' as encrypt;

class FileEncryption {
  static Future<void> encryptFile(
      String inputPath, String outputPath, String key) async {
    final keyBytes = encrypt.Key.fromBase64(key);
    final iv = encrypt.IV.fromLength(16); // Initialization Vector
    final encrypter = encrypt.Encrypter(encrypt.AES(keyBytes));

    final file = File(inputPath);
    final encrypted = encrypter.encryptBytes(await file.readAsBytes(), iv: iv);

    await File(outputPath).writeAsBytes(encrypted.bytes);
    file.deleteSync(); // Delete unencrypted file
  }

  static Future<void> decryptFile(
      String inputPath, String outputPath, String key) async {
    final keyBytes = encrypt.Key.fromBase64(key);
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(keyBytes));

    final file = File(inputPath);
    final decrypted = encrypter.decryptBytes(
      encrypt.Encrypted(await file.readAsBytes()),
      iv: iv,
    );

    await File(outputPath).writeAsBytes(decrypted);
  }
}
