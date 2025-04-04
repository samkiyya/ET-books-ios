import 'dart:convert';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EncryptionService {
  static const _secureStorage = FlutterSecureStorage();
  static const _keyName = 'AbyssiniaSoftwareSolutionsEncryptionKey';

  static Future<String> getOrCreateEncryptionKey() async {
    var encryptionKey = await _secureStorage.read(key: _keyName);

    if (encryptionKey == null) {
      encryptionKey = _generateSecureKey(length: 32);
      await _secureStorage.write(key: _keyName, value: encryptionKey);
    }

    return encryptionKey;
  }

  static String _generateSecureKey({int length = 32}) {
    final random = Random.secure();
    final keyBytes = List<int>.generate(length, (_) => random.nextInt(256));
    return base64Url.encode(keyBytes);
  }
}
