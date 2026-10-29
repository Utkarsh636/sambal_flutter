import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../features/case/case_controller.dart';
import '../../features/documents/scanned_document.dart';

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

  static Set<String> get roadmapDoneIds =>
      (_prefs.getStringList('roadmapDoneIds') ?? []).toSet();

  static set roadmapDoneIds(Set<String> value) =>
      _prefs.setStringList('roadmapDoneIds', value.toList());

  static bool get certificateReceived =>
      _prefs.getBool('certificateReceived') ?? false;

  static set certificateReceived(bool value) =>
      _prefs.setBool('certificateReceived', value);

  static Map<String, List<String>> loadDocuments() {
    final raw = _prefs.getString('documents');
    if (raw == null) return {};
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return json.map((key, value) =>
        MapEntry(key, (value as List).cast<String>()));
  }

  static void saveDocuments(Map<String, List<String>> docs) {
    _prefs.setString('documents', jsonEncode(docs));
  }

  static List<ScannedDocument> loadScannedDocs() {
    final raw = _prefs.getString('scannedDocs');
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list
        .map((e) => ScannedDocument.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static void saveScannedDocs(List<ScannedDocument> docs) {
    _prefs.setString(
      'scannedDocs',
      jsonEncode(docs.map((d) => d.toJson()).toList()),
    );
  }

  static int get certificateGuideStep =>
      _prefs.getInt('certificateGuideStep') ?? 0;

  static set certificateGuideStep(int value) =>
      _prefs.setInt('certificateGuideStep', value);

  static Future<void> clearAll() async {
    await _prefs.clear();
  }
}
