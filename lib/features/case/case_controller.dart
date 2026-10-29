import 'package:flutter/widgets.dart';

import '../../core/storage/local_storage.dart';

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

  void loadFromStorage() {
    isHindi = LocalStorage.isHindi;
    isDarkMode = LocalStorage.isDarkMode;
    final saved = LocalStorage.loadCaseData();
    if (saved != null) data = saved;
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

  bool get hasPin => LocalStorage.hasPin;

  void setPin(String pin) => LocalStorage.pin = pin;

  bool verifyPin(String pin) => LocalStorage.pin == pin;

  void removePin() => LocalStorage.removePin();

  Future<void> clearAllData() async {
    await LocalStorage.clearAll();
    isHindi = true;
    isDarkMode = false;
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
