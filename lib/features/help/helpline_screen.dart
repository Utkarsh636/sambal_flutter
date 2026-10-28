import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../case/case_controller.dart';

class HelplineScreen extends StatelessWidget {
  const HelplineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final hindi = SambalScope.of(context).isHindi;
    final colors = Theme.of(context).colorScheme;

    String t(String hi, String en) => hindi ? hi : en;

    final helplines = [
      _Helpline(
        number: '112',
        hi: 'आपातकालीन सेवा',
        en: 'Emergency Services',
        descHi: 'पुलिस, एम्बुलेंस, फ़ायर — सभी आपातकालीन सेवाएँ',
        descEn: 'Police, ambulance, fire — all emergencies',
        icon: Icons.emergency_rounded,
        color: colors.error,
      ),
      _Helpline(
        number: '108',
        hi: 'एम्बुलेंस सेवा',
        en: 'Ambulance Service',
        descHi: 'निःशुल्क एम्बुलेंस सेवा (अधिकतर राज्यों में)',
        descEn: 'Free ambulance service (most states)',
        icon: Icons.local_hospital_rounded,
        color: colors.error,
      ),
      _Helpline(
        number: '1800-180-5145',
        hi: 'जन सुनवाई (UP)',
        en: 'Jan Sunwai (UP)',
        descHi: 'उत्तर प्रदेश ऑनलाइन शिकायत और सहायता',
        descEn: 'Uttar Pradesh online grievance and assistance',
        icon: Icons.support_agent_rounded,
        color: colors.primary,
      ),
      _Helpline(
        number: '181',
        hi: 'महिला हेल्पलाइन',
        en: 'Women Helpline',
        descHi: 'महिलाओं के लिए 24/7 सहायता',
        descEn: '24/7 assistance for women',
        icon: Icons.woman_rounded,
        color: colors.tertiary,
      ),
      _Helpline(
        number: '1098',
        hi: 'चाइल्डलाइन',
        en: 'Childline',
        descHi: 'बच्चों के अधिकार और सुरक्षा',
        descEn: 'Child rights and protection',
        icon: Icons.child_care_rounded,
        color: colors.tertiary,
      ),
      _Helpline(
        number: '14461',
        hi: 'किसान कॉल सेंटर',
        en: 'Kisan Call Centre',
        descHi: 'कृषि संबंधी सहायता',
        descEn: 'Agriculture-related assistance',
        icon: Icons.agriculture_rounded,
        color: colors.secondary,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(t('हेल्पलाइन नंबर', 'Helpline Numbers')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            color: colors.errorContainer.withValues(alpha: 0.4),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: colors.onErrorContainer),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      t('ये सरकारी हेल्पलाइन नंबर हैं। Sambal कोई कानूनी या आपातकालीन सेवा नहीं है।',
                          'These are government helpline numbers. Sambal is not a legal or emergency service.'),
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...helplines.map((h) => _HelplineCard(
                helpline: h,
                hindi: hindi,
                colors: colors,
              )),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _Helpline {
  final String number;
  final String hi;
  final String en;
  final String descHi;
  final String descEn;
  final IconData icon;
  final Color color;

  const _Helpline({
    required this.number,
    required this.hi,
    required this.en,
    required this.descHi,
    required this.descEn,
    required this.icon,
    required this.color,
  });
}

class _HelplineCard extends StatelessWidget {
  final _Helpline helpline;
  final bool hindi;
  final ColorScheme colors;

  const _HelplineCard({
    required this.helpline,
    required this.hindi,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: helpline.color.withValues(alpha: 0.12),
                child: Icon(helpline.icon, color: helpline.color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hindi ? helpline.hi : helpline.en,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hindi ? helpline.descHi : helpline.descEn,
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
                    helpline.number,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: helpline.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    height: 32,
                    width: 32,
                    child: IconButton.filled(
                      onPressed: () => _call(helpline.number),
                      icon: const Icon(Icons.call_rounded, size: 16),
                      style: IconButton.styleFrom(
                        backgroundColor: helpline.color,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
      ),
    );
  }

  Future<void> _call(String number) async {
    final cleanNumber = number.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('tel:$cleanNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
