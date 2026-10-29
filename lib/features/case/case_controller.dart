import 'package:flutter/widgets.dart';

import '../../core/storage/local_storage.dart';
import '../../core/storage/secure_storage.dart';

class CaseData {
  final String name;
  final String relation;
  final bool onBehalf;
  final DateTime deathDate;
  final String state;
  final String district;
  final String circumstance;
  final String rites;

  CaseData({
    this.name = '',
    this.relation = '',
    this.onBehalf = false,
    DateTime? deathDate,
    this.state = '',
    this.district = '',
    this.circumstance = '',
    this.rites = '',
  }) : deathDate = deathDate ?? DateTime.now();
}

class SambalController extends ChangeNotifier {
  bool isHindi = true;
  bool isDarkMode = false;
  CaseData data = CaseData();

  Future<void> loadFromStorage() async {
    isHindi = LocalStorage.isHindi;
    isDarkMode = LocalStorage.isDarkMode;
    final saved = LocalStorage.loadCaseData();
    if (saved != null) data = saved;
    await loadSecurityState();
  }

  void toggleLanguage() {
    isHindi = !isHindi;
    LocalStorage.isHindi = isHindi;
    notifyListeners();
  }

  void setLanguage(bool hindi) {
    isHindi = hindi;
    LocalStorage.isHindi = isHindi;
    notifyListeners();
  }

  void toggleTheme() {
    isDarkMode = !isDarkMode;
    LocalStorage.isDarkMode = isDarkMode;
    notifyListeners();
  }

  void saveSetup({
    String? name,
    required String relation,
    required bool onBehalf,
    required DateTime deathDate,
    required String state,
    required String district,
    required String circumstance,
    required String rites,
  }) {
    data = CaseData(
      name: name ?? data.name,
      relation: relation,
      onBehalf: onBehalf,
      deathDate: deathDate,
      state: state,
      district: district,
      circumstance: circumstance,
      rites: rites,
    );
    LocalStorage.saveCaseData(data);
    LocalStorage.hasCompletedOnboarding = true;
    notifyListeners();
  }

  bool _hasPin = false;
  bool _biometricEnabled = false;

  bool get hasPin => _hasPin;
  bool get biometricEnabled => _biometricEnabled;

  Future<void> loadSecurityState() async {
    _hasPin = await SecureStorage.hasPin();
    _biometricEnabled = await SecureStorage.isBiometricEnabled();
  }

  Future<void> setPin(String pin) async {
    await SecureStorage.setPin(pin);
    _hasPin = true;
    notifyListeners();
  }

  Future<bool> verifyPin(String pin) => SecureStorage.verifyPin(pin);

  Future<void> removePin() async {
    await SecureStorage.removePin();
    _hasPin = false;
    _biometricEnabled = false;
    notifyListeners();
  }

  Future<void> setBiometricEnabled(bool value) async {
    await SecureStorage.setBiometricEnabled(value);
    _biometricEnabled = value;
    notifyListeners();
  }

  Future<void> clearAllData() async {
    await LocalStorage.clearAll();
    await SecureStorage.clearAll();
    isHindi = true;
    isDarkMode = false;
    _hasPin = false;
    _biometricEnabled = false;
    data = CaseData();
    notifyListeners();
  }
}

class SambalScope extends InheritedNotifier<SambalController> {
  const SambalScope({
    required SambalController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static SambalController of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<SambalScope>();
    assert(scope != null, 'SambalScope was not found.');
    return scope!.notifier!;
  }
}
