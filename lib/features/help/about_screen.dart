import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../case/case_controller.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final hindi = SambalScope.of(context).isHindi;
    final colors = Theme.of(context).colorScheme;

    String t(String hi, String en) => hindi ? hi : en;

    return Scaffold(
      appBar: AppBar(
        title: Text(t('Sambal के बारे में', 'About Sambal')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 20),
          Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: const Color(0xFF3B6B5E),
              child: Icon(
                Icons.eco_rounded,
                size: 40,
                color: colors.surface,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'संबल — Sambal',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              t('हर कदम पर साथ', 'With you at every step'),
              style: TextStyle(
                fontSize: 16,
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
          Center(
            child: Text(
              t('संस्करण 1.0.0', 'Version 1.0.0'),
              style: TextStyle(
                fontSize: 13,
                color: colors.outline,
              ),
            ),
          ),
          const SizedBox(height: 32),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t('Sambal क्या है?', 'What is Sambal?'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    t('Sambal एक प्राइवेसी-केंद्रित सहायता ऐप है जो शोकग्रस्त भारतीय परिवारों को मृत्यु प्रमाणपत्र पंजीकरण, दस्तावेज़ तैयारी, फीस, कार्यालय, और आधिकारिक पोर्टल में मार्गदर्शन करता है।',
                        'Sambal is a privacy-conscious support app that guides bereaved Indian families through death-certificate registration, document preparation, fees, offices, and official portals.'),
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.verified_user_outlined,
                          color: colors.primary, size: 22),
                      const SizedBox(width: 10),
                      Text(
                        t('आपकी प्राइवेसी', 'Your privacy'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _BulletPoint(
                    text: t('सभी स्कैन सिर्फ़ आपके फ़ोन पर रहते हैं',
                        'All scans stay only on your phone'),
                    colors: colors,
                  ),
                  _BulletPoint(
                    text: t('OCR (टेक्स्ट पहचान) फ़ोन पर होता है',
                        'OCR runs on-device'),
                    colors: colors,
                  ),
                  _BulletPoint(
                    text: t(
                        'AI सहायक को कोई निजी जानकारी नहीं भेजी जाती',
                        'No personal information is sent to the AI assistant'),
                    colors: colors,
                  ),
                  _BulletPoint(
                    text: t('क्लाउड बैकअप बंद है',
                        'Cloud backup is disabled'),
                    colors: colors,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          Card(
            color: colors.tertiaryContainer.withValues(alpha: 0.4),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.gavel_rounded,
                          color: colors.onTertiaryContainer, size: 22),
                      const SizedBox(width: 10),
                      Text(
                        t('महत्वपूर्ण अस्वीकरण', 'Important disclaimer'),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: colors.onTertiaryContainer,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    t('Sambal एक सूचना सहायता ऐप है। यह वकील, सरकारी प्राधिकारी, या आपातकालीन सेवा नहीं है।\n\n'
                        'कानूनी विरासत, संपत्ति बँटवारे, या विवाद से जुड़े प्रश्नों के लिए कृपया वकील या संबंधित प्राधिकारी से संपर्क करें।\n\n'
                        'ऐप में दिखाई गई सरकारी जानकारी आधिकारिक स्रोतों से ली गई है, लेकिन स्थानीय नियम बदल सकते हैं। अंतिम निर्णय से पहले हमेशा अपने स्थानीय कार्यालय से पुष्टि करें।',
                        'Sambal is an informational support app. It is not a lawyer, government authority, or emergency service.\n\n'
                            'For legal inheritance, property share, or dispute questions, please consult a lawyer or the relevant authority.\n\n'
                            'Government information shown is sourced from official portals, but local rules may change. Always confirm at your local office before making final decisions.'),
                    style: TextStyle(
                      color: colors.onTertiaryContainer,
                      height: 1.5,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t('कवरेज', 'Coverage'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    t('वर्तमान में 5 राज्य सत्यापित:', 'Currently 5 states verified:'),
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _StateChip(label: t('उत्तर प्रदेश', 'Uttar Pradesh'), colors: colors),
                      _StateChip(label: t('बिहार', 'Bihar'), colors: colors),
                      _StateChip(label: t('मध्य प्रदेश', 'Madhya Pradesh'), colors: colors),
                      _StateChip(label: t('राजस्थान', 'Rajasthan'), colors: colors),
                      _StateChip(label: t('महाराष्ट्र', 'Maharashtra'), colors: colors),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Developer & contact
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.code_rounded,
                          color: colors.primary, size: 22),
                      const SizedBox(width: 10),
                      Text(
                        t('डेवलपर', 'Developer'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Utkarsh',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => launchUrl(
                      Uri.parse('mailto:sambal.support@gmail.com?subject=Sambal Bug Report'),
                      mode: LaunchMode.externalApplication,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.bug_report_outlined,
                              size: 20, color: colors.primary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t('बग रिपोर्ट करें', 'Report a bug'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  'sambal.support@gmail.com',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.open_in_new_rounded,
                              size: 16, color: colors.outline),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Copyright
          Center(
            child: Text(
              '© 2026 Utkarsh. All rights reserved.',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              t('Sambal (संबल) एक मौलिक अवधारणा है।',
                  'Sambal (संबल) is an original concept.'),
              style: TextStyle(
                fontSize: 12,
                color: colors.outline,
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _BulletPoint extends StatelessWidget {
  final String text;
  final ColorScheme colors;

  const _BulletPoint({required this.text, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Icon(Icons.check_circle_rounded,
                size: 16, color: colors.primary),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

class _StateChip extends StatelessWidget {
  final String label;
  final ColorScheme colors;

  const _StateChip({required this.label, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      backgroundColor: colors.primaryContainer.withValues(alpha: 0.5),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
