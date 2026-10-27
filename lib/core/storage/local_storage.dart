import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../features/case/case_controller.dart';

class LocalStorage {
  static late final SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static bool get hasCompletedOnboarding =>
      _prefs.getBool('hasCompletedOnboarding') ?? false;

  static set hasCompletedOnboarding(bool value) =>
      _prefs.setBool('hasCompletedOnboarding', value);

  static bool get isDarkMode => _prefs.getBool('isDarkMode') ?? false;

  static set isDarkMode(bool value) => _prefs.setBool('isDarkMode', value);

  static bool get isHindi => _prefs.getBool('isHindi') ?? true;

  static set isHindi(bool value) => _prefs.setBool('isHindi', value);

  static void saveCaseData(CaseData data) {
    _prefs.setString('caseData', jsonEncode({
      'relation': data.relation,
      'onBehalf': data.onBehalf,
      'deathDate': data.deathDate.toIso8601String(),
      'state': data.state,
      'district': data.district,
      'circumstance': data.circumstance,
      'rites': data.rites,
    }));
  }

  static CaseData? loadCaseData() {
    final raw = _prefs.getString('caseData');
    if (raw == null) return null;

    final json = jsonDecode(raw) as Map<String, dynamic>;
    return CaseData(
      relation: json['relation'] as String? ?? '',
      onBehalf: json['onBehalf'] as bool? ?? false,
      deathDate: DateTime.tryParse(json['deathDate'] as String? ?? ''),
      state: json['state'] as String? ?? '',
      district: json['district'] as String? ?? '',
      circumstance: json['circumstance'] as String? ?? '',
      rites: json['rites'] as String? ?? '',
    );
  }

  static void cacheApiResponse(String key, String jsonBody) {
    _prefs.setString('cache_$key', jsonBody);
    _prefs.setInt('cache_ts_$key', DateTime.now().millisecondsSinceEpoch);
  }

  static String? getCachedResponse(String key) => _prefs.getString('cache_$key');

  static DateTime? getCacheTime(String key) {
    final ms = _prefs.getInt('cache_ts_$key');
    return ms != null ? DateTime.fromMillisecondsSinceEpoch(ms) : null;
  }

  static Future<void> clearAll() async {
    await _prefs.clear();
  }
}
