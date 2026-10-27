import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../core/config/api_config.dart';
import '../../core/storage/local_storage.dart';
import '../case/case_controller.dart';
import '../shell/shell_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final pageController = PageController();
  final _otherRelationController = TextEditingController();
  final _otherCircumstanceController = TextEditingController();

  int step = 0;
  String relation = '';
  bool onBehalf = false;
  DateTime deathDate = DateTime.now().subtract(const Duration(days: 9));
  String stateName = '';
  String district = '';
  String circumstance = '';
  String rites = '';

  List<_StateOption> _states = [];
  List<_DistrictOption> _districts = [];
  bool _loadingStates = true;
  bool _loadingDistricts = false;
  bool _districtError = false;

  bool get isHindi => SambalScope.of(context).isHindi;

  String t(String hi, String en) => isHindi ? hi : en;

  @override
  void initState() {
    super.initState();
    _loadStates();
  }

  @override
  void dispose() {
    pageController.dispose();
    _otherRelationController.dispose();
    _otherCircumstanceController.dispose();
    super.dispose();
  }

  List<_StateOption> _parseStates(String body) {
    final json = jsonDecode(body) as Map<String, dynamic>;
    final rawStates = json["states"] as List? ?? const [];
    return rawStates
        .whereType<Map>()
        .map((item) => _StateOption(
              id: item["id"]?.toString() ?? "",
              name: item["name"]?.toString() ?? "",
            ))
        .where((s) => s.id.isNotEmpty && s.name.isNotEmpty)
        .toList();
  }

  Future<void> _loadStates() async {
    try {
      final uri = Uri.http(ApiConfig.host, "/certificate/coverage");
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) throw Exception("Failed");

      LocalStorage.cacheApiResponse('coverage', response.body);

      if (!mounted) return;
      setState(() {
        _states = _parseStates(response.body);
        _loadingStates = false;
      });
    } catch (_) {
      if (!mounted) return;

      final cached = LocalStorage.getCachedResponse('coverage');
      if (cached != null) {
        setState(() {
          _states = _parseStates(cached);
          _loadingStates = false;
        });
        return;
      }

      setState(() {
        _states = const [
          _StateOption(id: "uttar-pradesh", name: "Uttar Pradesh"),
          _StateOption(id: "bihar", name: "Bihar"),
          _StateOption(id: "madhya-pradesh", name: "Madhya Pradesh"),
          _StateOption(id: "rajasthan", name: "Rajasthan"),
          _StateOption(id: "maharashtra", name: "Maharashtra"),
        ];
        _loadingStates = false;
      });
    }
  }

  List<_DistrictOption> _parseDistricts(String body) {
    final json = jsonDecode(body) as Map<String, dynamic>;
    final rawDistricts = json["districts"] as List? ?? const [];
    return rawDistricts
        .whereType<Map>()
        .map((item) => _DistrictOption(
              name: item["name"]?.toString() ?? "",
            ))
        .where((d) => d.name.isNotEmpty)
        .toList();
  }

  Future<void> _loadDistricts(String state) async {
    setState(() {
      _districts = [];
      _loadingDistricts = true;
      _districtError = false;
      district = '';
    });

    final cacheKey = 'districts_$state';

    try {
      final uri = Uri.http(
        ApiConfig.host,
        "/certificate/districts",
        {"state": state},
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) throw Exception("Failed");

      LocalStorage.cacheApiResponse(cacheKey, response.body);

      if (!mounted) return;
      setState(() {
        _districts = _parseDistricts(response.body);
        _loadingDistricts = false;
      });
    } catch (_) {
      if (!mounted) return;

      final cached = LocalStorage.getCachedResponse(cacheKey);
      if (cached != null) {
        setState(() {
          _districts = _parseDistricts(cached);
          _loadingDistricts = false;
        });
        return;
      }

      setState(() {
        _loadingDistricts = false;
        _districtError = true;
      });
    }
  }

  bool get _canContinue {
    switch (step) {
      case 1:
        if (relation == 'other') {
          return _otherRelationController.text.trim().isNotEmpty;
        }
        return relation.isNotEmpty;
      case 3:
        return stateName.isNotEmpty && district.isNotEmpty;
      case 4:
        if (circumstance == 'other') {
          return _otherCircumstanceController.text.trim().isNotEmpty &&
              rites.isNotEmpty;
        }
        return circumstance.isNotEmpty && rites.isNotEmpty;
      default:
        return true;
    }
  }

  String get _finalRelation {
    if (relation == 'other') {
      return _otherRelationController.text.trim();
    }
    return relation;
  }

  String get _finalCircumstance {
    if (circumstance == 'other') {
      return _otherCircumstanceController.text.trim();
    }
    return circumstance;
  }

  void next() {
    if (step == 5) {
      SambalScope.of(context).saveSetup(
        relation: _finalRelation,
        onBehalf: onBehalf,
        deathDate: deathDate,
        state: stateName,
        district: district,
        circumstance: _finalCircumstance,
        rites: rites,
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ShellScreen()),
      );
      return;
    }

    setState(() => step++);
    pageController.nextPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void back() {
    if (step == 0) return;

    setState(() => step--);
    pageController.previousPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      welcomePage(),
      relationPage(),
      datePage(),
      placePage(),
      circumstancePage(),
      privacyPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(t('संबल', 'Sambal')),
        actions: [
          TextButton(
            onPressed: () {
              SambalScope.of(context).toggleLanguage();
              setState(() {});
            },
            child: Text(isHindi ? 'English' : 'हिन्दी'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(value: (step + 1) / pages.length),
            Expanded(
              child: PageView(
                controller: pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: pages,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  if (step > 0) ...[
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(56),
                        ),
                        onPressed: back,
                        child: Text(t('पिछला', 'Back')),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                      ),
                      onPressed: _canContinue ? next : null,
                      child: Text(
                        step == 5
                            ? t('मेरा केस बनाएँ', 'Create my case')
                            : t('आगे बढ़ें', 'Continue'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget page({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 24),
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 10),
        Text(subtitle, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 30),
        child,
      ],
    );
  }

  Widget welcomePage() {
    return page(
      title: t('हर कदम पर साथ', 'With you at every step'),
      subtitle: t(
        'मृत्यु के बाद की ज़रूरी कागज़ी कार्रवाई में Sambal आपकी मदद करेगा।',
        'Sambal will help with essential paperwork after a death.',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t('भाषा चुनें', 'Choose language'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          choice('हिन्दी', isHindi, () {
            SambalScope.of(context).setLanguage(true);
            setState(() {});
          }),
          choice('English', !isHindi, () {
            SambalScope.of(context).setLanguage(false);
            setState(() {});
          }),
          const SizedBox(height: 28),
          Text(
            t('रंग योजना', 'Appearance'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _themeCard(
                  label: t('उजला', 'Light'),
                  selected: !SambalScope.of(context).isDarkMode,
                  icon: Icons.light_mode_outlined,
                  onTap: () {
                    if (SambalScope.of(context).isDarkMode) {
                      SambalScope.of(context).toggleTheme();
                      setState(() {});
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _themeCard(
                  label: t('गहरा', 'Dark'),
                  selected: SambalScope.of(context).isDarkMode,
                  icon: Icons.dark_mode_outlined,
                  onTap: () {
                    if (!SambalScope.of(context).isDarkMode) {
                      SambalScope.of(context).toggleTheme();
                      setState(() {});
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _themeCard({
    required String label,
    required bool selected,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      color: selected ? colors.primaryContainer : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: selected ? colors.primary : null),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              if (selected) ...[
                const SizedBox(height: 4),
                Icon(Icons.check_circle, size: 18, color: colors.primary),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget relationPage() {
    return page(
      title: t('किसका निधन हुआ है?', 'Who has passed away?'),
      subtitle: t(
        'इससे हम सही जानकारी दिखा सकेंगे।',
        'This helps us show the right information.',
      ),
      child: Column(
        children: [
          choice(
            t('पिता', 'Father'),
            relation == 'father',
            () => setState(() => relation = 'father'),
          ),
          choice(
            t('माता', 'Mother'),
            relation == 'mother',
            () => setState(() => relation = 'mother'),
          ),
          choice(
            t('पति / पत्नी', 'Spouse'),
            relation == 'spouse',
            () => setState(() => relation = 'spouse'),
          ),
          choice(
            t('अन्य', 'Other'),
            relation == 'other',
            () => setState(() => relation = 'other'),
          ),
          if (relation == 'other') ...[
            const SizedBox(height: 12),
            TextFormField(
              controller: _otherRelationController,
              decoration: InputDecoration(
                labelText: t('रिश्ता बताएँ', 'Specify relation'),
                hintText: t('जैसे — भाई, बहन, दादा', 'e.g. Brother, Sister, Grandparent'),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ],
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: onBehalf,
            onChanged: (value) => setState(() => onBehalf = value),
            title: Text(
              t(
                'मैं किसी और की ओर से भर रहा हूँ',
                'I am filling this for someone else',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget datePage() {
    final days = DateTime.now().difference(deathDate).inDays;

    return page(
      title: t('निधन की तारीख क्या थी?', 'What was the date of death?'),
      subtitle: t('कृपया सही तारीख चुनें — बाद में बदल सकते हैं।', 'Please select the correct date — you can change it later.'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OutlinedButton.icon(
            icon: const Icon(Icons.calendar_today_outlined),
            label: Text('${deathDate.day}/${deathDate.month}/${deathDate.year}'),
            onPressed: () async {
              final value = await showDatePicker(
                context: context,
                initialDate: deathDate,
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (value != null) {
                setState(() => deathDate = value);
              }
            },
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                days <= 21
                    ? t(
                        'आज निःशुल्क पंजीकरण अवधि का दिन $days है।',
                        'Today is day $days of the free registration period.',
                      )
                    : t(
                        'पंजीकरण में देरी हुई है। आगे का तरीका हम बताएँगे।',
                        'Registration is late. We will guide you through the next steps.',
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget placePage() {
    return page(
      title: t('निधन किस जगह हुआ?', 'Where did the death take place?'),
      subtitle: t(
        'सही कार्यालय और नियम चुनने के लिए।',
        'To identify the correct office and rules.',
      ),
      child: Column(
        children: [
          if (_loadingStates)
            const Center(child: CircularProgressIndicator())
          else
            DropdownButtonFormField<String>(
              value: stateName.isEmpty ? null : stateName,
              decoration: InputDecoration(
                labelText: t('राज्य', 'State'),
              ),
              items: _states
                  .map(
                    (state) => DropdownMenuItem(
                      value: state.name,
                      child: Text(state.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => stateName = value);
                  _loadDistricts(value);
                }
              },
            ),
          const SizedBox(height: 16),
          if (_loadingDistricts)
            const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            )
          else if (_districtError)
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      t(
                        'जिला सूची लोड नहीं हो सकी। बैकएंड और इंटरनेट जाँचें।',
                        'Could not load districts. Check the backend and internet.',
                      ),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () => _loadDistricts(stateName),
                      icon: const Icon(Icons.refresh),
                      label: Text(t('फिर से कोशिश करें', 'Retry')),
                    ),
                  ],
                ),
              ),
            )
          else
            DropdownButtonFormField<String>(
              key: ValueKey('district-$stateName'),
              value: district.isEmpty ? null : district,
              decoration: InputDecoration(
                labelText: t('ज़िला', 'District'),
              ),
              items: _districts
                  .map(
                    (d) => DropdownMenuItem(
                      value: d.name,
                      child: Text(d.name),
                    ),
                  )
                  .toList(),
              onChanged: _districts.isEmpty
                  ? null
                  : (value) {
                      if (value != null) setState(() => district = value);
                    },
            ),
        ],
      ),
    );
  }

  Widget circumstancePage() {
    return page(
      title: t('निधन किस स्थिति में हुआ?', 'How did the death happen?'),
      subtitle: t(
        'इससे कागज़ों की सूची बदल सकती है।',
        'This may change the document checklist.',
      ),
      child: Column(
        children: [
          choice(
            t('अस्पताल', 'Hospital'),
            circumstance == 'hospital',
            () => setState(() => circumstance = 'hospital'),
          ),
          choice(
            t('घर', 'Home'),
            circumstance == 'home',
            () => setState(() => circumstance = 'home'),
          ),
          choice(
            t('दुर्घटना', 'Accident'),
            circumstance == 'accident',
            () => setState(() => circumstance = 'accident'),
          ),
          choice(
            t('अन्य', 'Other'),
            circumstance == 'other',
            () => setState(() => circumstance = 'other'),
          ),
          if (circumstance == 'other') ...[
            const SizedBox(height: 12),
            TextFormField(
              controller: _otherCircumstanceController,
              decoration: InputDecoration(
                labelText: t('स्थिति बताएँ', 'Specify circumstance'),
                hintText: t('जैसे — प्राकृतिक आपदा', 'e.g. Natural disaster'),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ],
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                t('अंतिम संस्कार', 'Last rites'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          choice(
            t('हाँ, अंतिम संस्कार हो चुका है', 'Yes, last rites are complete'),
            rites == 'yes',
            () => setState(() => rites = 'yes'),
          ),
          choice(
            t('नहीं / पक्का नहीं', 'No / not sure'),
            rites == 'no',
            () => setState(() => rites = 'no'),
          ),
        ],
      ),
    );
  }

  Widget privacyPage() {
    return page(
      title: t(
        'आपकी जानकारी सुरक्षित रहती है',
        'Your information stays private',
      ),
      subtitle: t(
        'आधार का पूरा नंबर नहीं दिखाया जाएगा और आप अपना डेटा मिटा सकते हैं।',
        'Full Aadhaar numbers are not shown, and you can delete your data.',
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            t(
              'Sambal जानकारी और प्रक्रिया में मदद करता है। यह कानूनी सलाह नहीं देता।',
              'Sambal provides information and workflow help. It is not legal advice.',
            ),
          ),
        ),
      ),
    );
  }

  Widget choice(String label, bool selected, VoidCallback onTap) {
    return Card(
      color: selected
          ? Theme.of(context).colorScheme.primaryContainer
          : null,
      child: ListTile(
        title: Text(label),
        trailing: selected ? const Icon(Icons.check_circle) : null,
        onTap: onTap,
      ),
    );
  }
}

class _StateOption {
  final String id;
  final String name;

  const _StateOption({required this.id, required this.name});
}

class _DistrictOption {
  final String name;

  const _DistrictOption({required this.name});
}
