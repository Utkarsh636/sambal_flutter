import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/verified_rules.dart';
import '../case/case_controller.dart';

class CoverageScreen extends StatelessWidget {
  const CoverageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final hindi = SambalScope.of(context).isHindi;
    final colors = Theme.of(context).colorScheme;
    String t(String hi, String en) => hindi ? hi : en;

    final userState = SambalScope.of(context).data.state;

    return Scaffold(
      appBar: AppBar(
        title: Text(t('सत्यापित कवरेज', 'Verified coverage')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.verified_outlined,
                          color: colors.primary, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          t('सत्यापित राज्य', 'Verified states'),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t('इन राज्यों के लिए आधिकारिक स्रोतों से नियम सत्यापित किए गए हैं। जिला-विशिष्ट शुल्क अभी तक आयात नहीं हुए हैं।',
                        'Rules for these states have been verified from official sources. District-specific fees have not yet been imported.'),
                    style: TextStyle(
                        color: colors.onSurfaceVariant, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...VerifiedStateData.rules.entries.map((entry) {
            final rules = entry.value;
            final isUserState = entry.key == userState;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _StateCard(
                rules: rules,
                isUserState: isUserState,
                t: t,
                colors: colors,
              ),
            );
          }),
          const SizedBox(height: 8),
          Card(
            color: colors.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t('अन्य राज्य', 'Other states'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t('राजस्थान और मध्य प्रदेश जल्द जोड़े जाएँगे। अन्य राज्यों के लिए राष्ट्रीय RBD Act 1969 के नियम दिखाए जाते हैं — ये सत्यापित नहीं हैं।',
                        'Rajasthan and Madhya Pradesh will be added soon. For other states, national RBD Act 1969 rules are shown — these are not verified.'),
                    style: TextStyle(
                        color: colors.onSurfaceVariant, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            t('गलत जानकारी मिली? नीचे बटन से रिपोर्ट करें।',
                'Found wrong information? Report it below.'),
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {
              final subject = Uri.encodeComponent('Sambal — wrong info report');
              launchUrl(
                Uri.parse('mailto:sambal.app.feedback@gmail.com?subject=$subject'),
                mode: LaunchMode.externalApplication,
              );
            },
            icon: const Icon(Icons.flag_outlined),
            label: Text(t('गलत जानकारी की रिपोर्ट करें', 'Report wrong info')),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _StateCard extends StatelessWidget {
  final StateRules rules;
  final bool isUserState;
  final String Function(String, String) t;
  final ColorScheme colors;

  const _StateCard({
    required this.rules,
    required this.isUserState,
    required this.t,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: isUserState
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: colors.primary, width: 2),
            )
          : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.verified, color: colors.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    rules.state,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                if (isUserState)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      t('आपका राज्य', 'Your state'),
                      style: TextStyle(
                        color: colors.onPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _FactRow(
              label: t('निःशुल्क अवधि', 'Free period'),
              fact: rules.freeRegistrationDays,
              colors: colors,
            ),
            _FactRow(
              label: t('विलंबित प्राधिकारी', 'Delayed authority'),
              fact: rules.delayedAuthority,
              colors: colors,
            ),
            _FactRow(
              label: t('पंजीकरण कार्यालय', 'Registration office'),
              fact: rules.registrationOffice,
              colors: colors,
            ),
            const SizedBox(height: 8),
            Text(
              t('आवश्यक दस्तावेज़:', 'Required documents:'),
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 4),
            ...rules.requiredDocuments.map((doc) => Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontSize: 13)),
                      Expanded(
                        child: Text(doc.value,
                            style: const TextStyle(fontSize: 13)),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.open_in_new, size: 14, color: colors.primary),
                const SizedBox(width: 4),
                Expanded(
                  child: GestureDetector(
                    onTap: () => launchUrl(Uri.parse(rules.portalUrl),
                        mode: LaunchMode.externalApplication),
                    child: Text(
                      rules.portalName,
                      style: TextStyle(
                        color: colors.primary,
                        fontSize: 12,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                Text(
                  t('सत्यापित: ${rules.lastVerified}',
                      'Verified: ${rules.lastVerified}'),
                  style: TextStyle(
                    fontSize: 10,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            if (!rules.districtDataImported) ...[
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  t('जिला-विशिष्ट शुल्क: सत्यापन लंबित',
                      'District-specific fees: not verified yet'),
                  style: TextStyle(
                    fontSize: 11,
                    color: colors.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FactRow extends StatelessWidget {
  final String label;
  final VerifiedFact fact;
  final ColorScheme colors;

  const _FactRow({
    required this.label,
    required this.fact,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(fact.value, style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
