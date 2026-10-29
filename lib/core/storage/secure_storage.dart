import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _keyPinHash = 'pin_hash';
  static const _keySalt = 'pin_salt';
  static const _keyBiometric = 'biometric_enabled';

  static String _generateSalt() {
    final rng = Random.secure();
    final bytes = List<int>.generate(32, (_) => rng.nextInt(256));
    return base64Encode(bytes);
  }

  static String _hashPin(String pin, String salt) {
    final bytes = utf8.encode('$salt:$pin');
    // Two rounds of SHA-256 with salt
    final first = sha256.convert(bytes);
    final second = sha256.convert(utf8.encode('$salt:$first'));
    return second.toString();
  }

  static Future<void> setPin(String pin) async {
    final salt = _generateSalt();
    final hash = _hashPin(pin, salt);
    await _storage.write(key: _keySalt, value: salt);
    await _storage.write(key: _keyPinHash, value: hash);
  }

  static Future<bool> verifyPin(String pin) async {
    final salt = await _storage.read(key: _keySalt);
    final storedHash = await _storage.read(key: _keyPinHash);
    if (salt == null || storedHash == null) return false;
    return _hashPin(pin, salt) == storedHash;
  }

  static Future<bool> hasPin() async {
    final hash = await _storage.read(key: _keyPinHash);
    return hash != null;
  }

  static Future<void> removePin() async {
    await _storage.delete(key: _keyPinHash);
    await _storage.delete(key: _keySalt);
    await _storage.delete(key: _keyBiometric);
  }

  static Future<bool> isBiometricEnabled() async {
    final val = await _storage.read(key: _keyBiometric);
    return val == 'true';
  }

  static Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(key: _keyBiometric, value: enabled.toString());
  }

  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
