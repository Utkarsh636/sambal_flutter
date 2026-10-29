import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _keyPinHash = 'pin_hash';
  static const _keySalt = 'pin_salt';
  static const _keyBiometric = 'biometric_enabled';
  static const _keyAttempts = 'pin_attempts';
  static const _keyLockoutUntil = 'lockout_until';
  static const _keyFileKey = 'file_encryption_key';

  static const _pbkdf2Iterations = 100000;

  // --- PBKDF2-HMAC-SHA256 ---

  static Uint8List _generateSaltBytes() {
    final rng = Random.secure();
    return Uint8List.fromList(
        List<int>.generate(32, (_) => rng.nextInt(256)));
  }

  static Uint8List _intToBytes(int i) =>
      Uint8List(4)..buffer.asByteData().setUint32(0, i, Endian.big);

  static Uint8List _pbkdf2(String password, Uint8List salt) {
    final hmacKey = utf8.encode(password);
    final blockInput = Uint8List.fromList([...salt, ..._intToBytes(1)]);
    var u = Hmac(sha256, hmacKey).convert(blockInput).bytes;
    final result = List<int>.from(u);

    for (var i = 1; i < _pbkdf2Iterations; i++) {
      u = Hmac(sha256, hmacKey).convert(u).bytes;
      for (var k = 0; k < result.length; k++) {
        result[k] ^= u[k];
      }
    }
    return Uint8List.fromList(result);
  }

  // --- PIN ---

  static Future<void> setPin(String pin) async {
    final salt = _generateSaltBytes();
    final hash = _pbkdf2(pin, salt);
    await _storage.write(key: _keySalt, value: base64Encode(salt));
    await _storage.write(key: _keyPinHash, value: base64Encode(hash));
    await resetAttempts();
  }

  static Future<bool> verifyPin(String pin) async {
    final saltB64 = await _storage.read(key: _keySalt);
    final storedB64 = await _storage.read(key: _keyPinHash);
    if (saltB64 == null || storedB64 == null) return false;

    final salt = base64Decode(saltB64);
    final stored = base64Decode(storedB64);
    final computed = _pbkdf2(pin, Uint8List.fromList(salt));

    if (computed.length != stored.length) return false;
    var equal = 0;
    for (var i = 0; i < computed.length; i++) {
      equal |= computed[i] ^ stored[i];
    }
    return equal == 0;
  }

  static Future<bool> hasPin() async {
    final hash = await _storage.read(key: _keyPinHash);
    return hash != null;
  }

  static Future<void> removePin() async {
    await _storage.delete(key: _keyPinHash);
    await _storage.delete(key: _keySalt);
    await _storage.delete(key: _keyBiometric);
    await resetAttempts();
  }

  // --- Lockout ---

  static Future<int> getAttempts() async {
    final val = await _storage.read(key: _keyAttempts);
    return val != null ? int.tryParse(val) ?? 0 : 0;
  }

  static Future<void> incrementAttempts() async {
    final current = await getAttempts();
    final next = current + 1;
    await _storage.write(key: _keyAttempts, value: next.toString());

    if (next >= 5) {
      final delays = [30, 60, 300, 900, 1800];
      final idx = (next - 5).clamp(0, delays.length - 1);
      final lockoutEnd = DateTime.now()
          .add(Duration(seconds: delays[idx]))
          .millisecondsSinceEpoch;
      await _storage.write(
          key: _keyLockoutUntil, value: lockoutEnd.toString());
    }
  }

  static Future<void> resetAttempts() async {
    await _storage.delete(key: _keyAttempts);
    await _storage.delete(key: _keyLockoutUntil);
  }

  static Future<Duration?> getLockoutRemaining() async {
    final val = await _storage.read(key: _keyLockoutUntil);
    if (val == null) return null;
    final until =
        DateTime.fromMillisecondsSinceEpoch(int.tryParse(val) ?? 0);
    final remaining = until.difference(DateTime.now());
    if (remaining.isNegative) {
      await _storage.delete(key: _keyLockoutUntil);
      return null;
    }
    return remaining;
  }

  // --- Biometric ---

  static Future<bool> isBiometricEnabled() async {
    final val = await _storage.read(key: _keyBiometric);
    return val == 'true';
  }

  static Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(key: _keyBiometric, value: enabled.toString());
  }

  // --- File encryption key ---

  static Future<Uint8List> getFileKey() async {
    final existing = await _storage.read(key: _keyFileKey);
    if (existing != null) return Uint8List.fromList(base64Decode(existing));

    final key = _generateSaltBytes(); // 32 bytes = AES-256
    await _storage.write(key: _keyFileKey, value: base64Encode(key));
    return key;
  }

  // --- Clear ---

  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
