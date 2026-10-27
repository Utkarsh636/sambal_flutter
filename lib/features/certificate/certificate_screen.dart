import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../core/config/api_config.dart';
import '../case/case_controller.dart';
import '../case/location_setup_screen.dart';

class CertificateScreen extends StatefulWidget {
  const CertificateScreen({super.key});

  @override
  State<CertificateScreen> createState() => _CertificateScreenState();
}

class _CertificateScreenState extends State<CertificateScreen> {
  final PageController _pageController = PageController();
  int _step = 0;
  bool _loaded = false;
  bool _isLoading = true;
  String? _error;
  _GuideInfo? _guide;

  String _text(String hindi, String english) {
    return SambalScope.of(context).isHindi ? hindi : english;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_loaded) {
      _loaded = true;
      _loadGuide();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadGuide() async {
    final caseData = SambalScope.of(context).data;

    if (caseData.state.trim().isEmpty) {
      setState(() {
        _isLoading = false;
        _error = 'पहले अपना राज्य और जिला चुनें।';
      });
      return;
    }

    final uri = Uri.http(
      ApiConfig.host,
      '/certificate/guide',
      {
        'state': caseData.state,
        'district': caseData.district,
        'circumstance': caseData.circumstance,
        'deathDate': caseData.deathDate.toIso8601String(),
      },
    );

    try {
      final result = await http.get(uri).timeout(const Duration(seconds: 10));

      if (result.statusCode != 200) {
        throw Exception('Guide service unavailable');
      }

      final json = jsonDecode(result.body) as Map<String, dynamic>;

      if (!mounted) return;

      setState(() {
        _guide = _GuideInfo.fromJson(json);
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _error = 'गाइड लोड नहीं हो सका। इंटरनेट और Sambal API जाँचें।';
      });
    }
  }

  void _goToStep(int step) {
    setState(() => _step = step);

    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _openUrl(String url) async {
    if (url.isEmpty) return;

    final opened = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );

    if (!mounted || opened) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Link could not be opened.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_text('प्रमाणपत्र गाइड', 'Certificate guide')),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: (_step + 1) / 5,
                  minHeight: 7,
                  borderRadius: BorderRadius.circular(20),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    _StepLabel(number: '1', hindi: 'शुरू', english: 'Start'),
                    _StepLabel(
                      number: '2',
                      hindi: 'दस्तावेज़',
                      english: 'Documents',
                    ),
                    _StepLabel(number: '3', hindi: 'फीस', english: 'Fees'),
                    _StepLabel(number: '4', hindi: 'कहाँ', english: 'Where'),
                    _StepLabel(number: '5', hindi: 'पोर्टल', english: 'Portal'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildStartPage(colors),
                      _buildDocumentsPage(colors),
                      _buildFeesPage(colors),
                      _buildWherePage(colors),
                      _buildPortalPage(colors),
                    ],
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        if (_step == 0) {
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          }
                        } else {
                          _goToStep(_step - 1);
                        }
                      },
                      child: Text(
                        _step == 0
                            ? _text('वापस', 'Back')
                            : _text('पिछला', 'Previous'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        if (_step == 4) {
                          _openUrl(_guide?.portalUrl ?? '');
                        } else {
                          _goToStep(_step + 1);
                        }
                      },
                      child: Text(
                        _step == 4
                            ? _text(
                                'ऑफिशियल पोर्टल खोलें', 'Open official portal')
                            : _text('अगला', 'Next'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartPage(ColorScheme colors) {
    final caseData = SambalScope.of(context).data;

    return _GuideCard(
      icon: Icons.volunteer_activism_rounded,
      title: _text('हम आपके साथ हैं', 'We are with you'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _text(
              'यह गाइड आपके चुने हुए स्थान के अनुसार अगला सही कदम बताता है।',
              'This guide shows the next right step for your selected location.',
            ),
          ),
          const SizedBox(height: 24),
          _InfoRow(
            icon: Icons.location_on_outlined,
            label: _text('राज्य', 'State'),
            value: caseData.state.isEmpty
                ? _text('चुना नहीं गया', 'Not selected')
                : caseData.state,
          ),
          _InfoRow(
            icon: Icons.location_city_outlined,
            label: _text('जिला', 'District'),
            value: caseData.district.isEmpty
                ? _text('चुना नहीं गया', 'Not selected')
                : caseData.district,
          ),
          _InfoRow(
            icon: Icons.home_work_outlined,
            label: _text('परिस्थिति', 'Circumstance'),
            value: caseData.circumstance.isEmpty
                ? _text('चुनी नहीं गई', 'Not selected')
                : caseData.circumstance,
          ),
          if (_guide?.daysElapsed != null)
            _InfoRow(
              icon: Icons.calendar_today_outlined,
              label: _text('बीते दिन', 'Days elapsed'),
              value: '${_guide!.daysElapsed}',
            ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () async {
              final saved = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (_) => const LocationSetupScreen(),
                ),
              );

              if (saved == true && mounted) {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                await _loadGuide();
              }
            },
            icon: const Icon(Icons.location_searching_rounded),
            label: Text(
              _text(
                'आधिकारिक स्थान सूची से चुनें',
                'Choose from official location list',
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 20),
            Text(
              _error!,
              style: TextStyle(
                color: colors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDocumentsPage(ColorScheme colors) {
    final guide = _guide;
    final checklist = guide?.checklist ?? [];
    final isHindi = SambalScope.of(context).isHindi;

    return _GuideCard(
      icon: Icons.folder_copy_outlined,
      title: _text('दस्तावेज़ तैयार करें', 'Prepare documents'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StatusBox(
            icon: checklist.isNotEmpty
                ? Icons.check_circle_outline_rounded
                : Icons.info_outline_rounded,
            text: guide?.documentsMessage ??
                _text(
                  'दस्तावेज़ों की जानकारी अभी सत्यापित नहीं है।',
                  'Document information is not yet verified.',
                ),
            color: checklist.isNotEmpty ? colors.primary : colors.secondary,
          ),
          if (checklist.isNotEmpty) ...[
            const SizedBox(height: 20),
            ...checklist.map(
              (doc) => _DocumentTile(
                name: isHindi ? doc.name : doc.nameEn,
                required: doc.required,
                verified: doc.verified,
                note: doc.note,
                colors: colors,
                isHindi: isHindi,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Text(
            _text(
              'अभी किसी दस्तावेज़ को अपने-आप "स्वीकृत" नहीं माना जाएगा। आप हर सुझाव की पुष्टि करेंगे।',
              'No document will be auto-accepted. You will confirm every suggestion.',
            ),
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeesPage(ColorScheme colors) {
    final guide = _guide;
    final tiers = guide?.feeTiers ?? [];
    final isHindi = SambalScope.of(context).isHindi;

    return _GuideCard(
      icon: Icons.currency_rupee_rounded,
      title: _text('फीस और समय', 'Fees and timing'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StatusBox(
            icon: guide?.feeStatus == 'verified'
                ? Icons.verified_outlined
                : Icons.warning_amber_rounded,
            text: guide?.feeDisplay ??
                _text(
                  'फीस की जानकारी अभी सत्यापित नहीं है।',
                  'Fee information is not yet verified.',
                ),
            color: guide?.feeStatus == 'verified'
                ? colors.primary
                : colors.tertiary,
          ),
          if (tiers.isNotEmpty) ...[
            const SizedBox(height: 20),
            ...tiers.map(
              (tier) => _FeeTierTile(
                label: isHindi ? tier.label : tier.labelEn,
                amount: isHindi
                    ? (tier.amount ?? _text('सत्यापित नहीं', 'Not verified'))
                    : (tier.amountEn ??
                        _text('सत्यापित नहीं', 'Not verified')),
                authority: isHindi
                    ? (tier.authorityHi ?? tier.authority)
                    : tier.authority,
                applicable: tier.applicable,
                verified: tier.status == 'verified',
                colors: colors,
              ),
            ),
          ],
          const SizedBox(height: 18),
          Text(
            _text(
              'अंतिम भुगतान से पहले आधिकारिक पोर्टल या स्थानीय पंजीकरण कार्यालय पर राशि अवश्य जाँचें।',
              'Always confirm the fee amount on the official portal or at the local registration office before paying.',
            ),
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWherePage(ColorScheme colors) {
    final route = _guide?.routeLabel ??
        _text(
          'चुने हुए स्थान के लिए सत्यापित मार्ग उपलब्ध नहीं है।',
          'No verified route available for the selected location.',
        );

    return _GuideCard(
      icon: Icons.account_balance_outlined,
      title: _text('कहाँ आवेदन करें', 'Where to apply'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StatusBox(
            icon: Icons.location_on_outlined,
            text: route,
            color: colors.primary,
          ),
          const SizedBox(height: 18),
          Text(
            _text(
              'स्थान और मृत्यु की परिस्थिति के अनुसार स्थानीय निकाय, अस्पताल, ग्राम पंचायत या नगर निकाय की भूमिका बदल सकती है।',
              'The responsible local body may vary based on the location and circumstances of death.',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortalPage(ColorScheme colors) {
    final guide = _guide;
    final sources = guide?.sources ?? [];

    return _GuideCard(
      icon: Icons.open_in_new_rounded,
      title: _text('ऑफिशियल पोर्टल', 'Official portal'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (guide?.portalUrl != null && guide!.portalUrl.isNotEmpty)
            GestureDetector(
              onTap: () => _openUrl(guide.portalUrl),
              child: Text(
                guide.portalUrl,
                style: TextStyle(
                  color: colors.primary,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.underline,
                  decorationColor: colors.primary,
                ),
              ),
            )
          else
            Text(
              _text('पोर्टल उपलब्ध नहीं है।', 'Portal not available.'),
            ),
          const SizedBox(height: 20),
          Text(
            _text(
              'हम केवल आधिकारिक स्रोतों की ओर भेजते हैं। आवेदन भरने से पहले सही जिला और स्थानीय निकाय जाँचें।',
              'We only link to official sources. Confirm your district and local body before applying.',
            ),
          ),
          if (sources.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              _text('स्रोत', 'Sources'),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            ...sources.map(
              (source) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  onTap: source.url.isNotEmpty
                      ? () => _openUrl(source.url)
                      : null,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          source.url.isNotEmpty
                              ? Icons.link_rounded
                              : Icons.article_outlined,
                          size: 18,
                          color: source.url.isNotEmpty
                              ? colors.primary
                              : colors.outline,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            source.title,
                            style: TextStyle(
                              color: source.url.isNotEmpty
                                  ? colors.primary
                                  : colors.onSurface,
                              decoration: source.url.isNotEmpty
                                  ? TextDecoration.underline
                                  : null,
                              decorationColor: colors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StepLabel extends StatelessWidget {
  final String number;
  final String hindi;
  final String english;

  const _StepLabel({
    required this.number,
    required this.hindi,
    required this.english,
  });

  @override
  Widget build(BuildContext context) {
    final isHindi = SambalScope.of(context).isHindi;

    return Column(
      children: [
        Text(
          number,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        Text(
          isHindi ? hindi : english,
          style: const TextStyle(fontSize: 10),
        ),
      ],
    );
  }
}

class _GuideCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _GuideCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 42, color: colors.primary),
              const SizedBox(height: 20),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$label: $value',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBox extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _StatusBox({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _DocumentTile extends StatelessWidget {
  final String name;
  final bool required;
  final bool verified;
  final String? note;
  final ColorScheme colors;
  final bool isHindi;

  const _DocumentTile({
    required this.name,
    required this.required,
    required this.verified,
    this.note,
    required this.colors,
    required this.isHindi,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              verified
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked,
              size: 22,
              color: verified ? colors.primary : colors.outline,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  if (note != null && note!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      note!,
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (required)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: colors.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isHindi ? 'ज़रूरी' : 'Required',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: colors.error,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FeeTierTile extends StatelessWidget {
  final String label;
  final String amount;
  final String authority;
  final bool applicable;
  final bool verified;
  final ColorScheme colors;

  const _FeeTierTile({
    required this.label,
    required this.amount,
    required this.authority,
    required this.applicable,
    required this.verified,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: applicable
              ? colors.primary.withValues(alpha: 0.12)
              : colors.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(14),
          border: applicable
              ? Border.all(color: colors.primary.withValues(alpha: 0.4))
              : null,
        ),
        child: Row(
          children: [
            Icon(
              applicable
                  ? Icons.arrow_forward_rounded
                  : Icons.circle_outlined,
              size: 20,
              color: applicable ? colors.primary : colors.outline,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight:
                          applicable ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    authority,
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amount,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: applicable ? colors.primary : colors.onSurface,
                  ),
                ),
                if (verified)
                  Icon(
                    Icons.verified_outlined,
                    size: 14,
                    color: colors.primary,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GuideInfo {
  final String routeLabel;
  final String portalUrl;
  final String feeDisplay;
  final String feeStatus;
  final String documentsMessage;
  final List<_GuideSource> sources;
  final List<_DocumentItem> checklist;
  final List<_FeeTier> feeTiers;
  final int? daysElapsed;

  const _GuideInfo({
    required this.routeLabel,
    required this.portalUrl,
    required this.feeDisplay,
    required this.feeStatus,
    required this.documentsMessage,
    required this.sources,
    required this.checklist,
    required this.feeTiers,
    this.daysElapsed,
  });

  factory _GuideInfo.fromJson(Map<String, dynamic> json) {
    final route = Map<String, dynamic>.from(json['route'] as Map? ?? {});
    final fee = Map<String, dynamic>.from(json['fee'] as Map? ?? {});
    final documents =
        Map<String, dynamic>.from(json['documents'] as Map? ?? {});
    final rawSources = json['sources'] as List? ?? const [];
    final rawChecklist = documents['checklist'] as List? ?? const [];
    final rawTiers = fee['tiers'] as List? ?? const [];

    return _GuideInfo(
      routeLabel: route['label']?.toString() ?? '',
      portalUrl: route['officialPortalUrl']?.toString() ?? '',
      feeDisplay: fee['display']?.toString() ?? '',
      feeStatus: fee['status']?.toString() ?? '',
      documentsMessage: documents['message']?.toString() ?? '',
      daysElapsed: json['daysElapsed'] as int?,
      sources: rawSources
          .whereType<Map>()
          .map(
            (source) => _GuideSource(
              title: source['title']?.toString() ?? 'Official source',
              url: source['url']?.toString() ?? '',
            ),
          )
          .toList(),
      checklist: rawChecklist
          .whereType<Map>()
          .map(
            (doc) => _DocumentItem(
              name: doc['name']?.toString() ?? '',
              nameEn: doc['nameEn']?.toString() ?? '',
              required: doc['required'] == true,
              verified: doc['verified'] == true,
              note: doc['note']?.toString(),
            ),
          )
          .toList(),
      feeTiers: rawTiers
          .whereType<Map>()
          .map(
            (tier) => _FeeTier(
              label: tier['label']?.toString() ?? '',
              labelEn: tier['labelEn']?.toString() ?? '',
              amount: tier['amount']?.toString(),
              amountEn: tier['amountEn']?.toString(),
              status: tier['status']?.toString() ?? '',
              applicable: tier['applicable'] == true,
              authority: tier['authority']?.toString() ?? '',
              authorityHi: tier['authorityHi']?.toString(),
            ),
          )
          .toList(),
    );
  }
}

class _GuideSource {
  final String title;
  final String url;

  const _GuideSource({required this.title, required this.url});
}

class _DocumentItem {
  final String name;
  final String nameEn;
  final bool required;
  final bool verified;
  final String? note;

  const _DocumentItem({
    required this.name,
    required this.nameEn,
    required this.required,
    required this.verified,
    this.note,
  });
}

class _FeeTier {
  final String label;
  final String labelEn;
  final String? amount;
  final String? amountEn;
  final String status;
  final bool applicable;
  final String authority;
  final String? authorityHi;

  const _FeeTier({
    required this.label,
    required this.labelEn,
    this.amount,
    this.amountEn,
    required this.status,
    required this.applicable,
    required this.authority,
    this.authorityHi,
  });
}
