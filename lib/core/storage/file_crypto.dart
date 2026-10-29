import 'dart:io';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as enc;

import 'secure_storage.dart';

class FileCrypto {
  static enc.Key? _cachedKey;

  static Future<enc.Key> _getKey() async {
    if (_cachedKey != null) return _cachedKey!;
    final keyBytes = await SecureStorage.getFileKey();
    _cachedKey = enc.Key(keyBytes);
    return _cachedKey!;
  }

  static Future<Uint8List> encrypt(Uint8List plaintext) async {
    final key = await _getKey();
    final iv = enc.IV.fromSecureRandom(12);
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.gcm));
    final encrypted = encrypter.encryptBytes(plaintext, iv: iv);
    // Prepend 12-byte IV to ciphertext
    return Uint8List.fromList([...iv.bytes, ...encrypted.bytes]);
  }

  static Future<Uint8List> decrypt(Uint8List data) async {
    final key = await _getKey();
    final iv = enc.IV(data.sublist(0, 12));
    final ciphertext = data.sublist(12);
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.gcm));
    final decrypted =
        encrypter.decryptBytes(enc.Encrypted(ciphertext), iv: iv);
    return Uint8List.fromList(decrypted);
  }

  static Future<void> encryptFile(String path) async {
    final file = File(path);
    final plaintext = await file.readAsBytes();
    final encrypted = await encrypt(plaintext);
    await file.writeAsBytes(encrypted);
  }

  static Future<Uint8List> decryptFile(String path) async {
    final file = File(path);
    final data = await file.readAsBytes();
    return decrypt(data);
  }

  static void clearCache() => _cachedKey = null;
}
