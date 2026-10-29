import 'package:flutter/services.dart';

class PlatformSecurity {
  static const _channel = MethodChannel('com.sambal/security');

  static Future<void> enableSecureFlag() async {
    try {
      await _channel.invokeMethod('setSecureFlag', {'secure': true});
    } on PlatformException catch (_) {}
  }

  static Future<void> disableSecureFlag() async {
    try {
      await _channel.invokeMethod('setSecureFlag', {'secure': false});
    } on PlatformException catch (_) {}
  }
}
