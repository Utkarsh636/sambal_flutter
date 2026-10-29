import 'package:flutter/material.dart';

import '../case/case_controller.dart';
import '../documents/scanner_service.dart';
import '../onboarding/splash_screen.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = SambalScope.of(context);
    final hindi = controller.isHindi;
    final colors = Theme.of(context).colorScheme;

    String t(String hi, String en) => hindi ? hi : en;

    return Scaffold(
      appBar: AppBar(
        title: Text(t('गोपनीयता और डेटा', 'Privacy & Data')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.shield_outlined, size: 36, color: colors.primary),
                  const SizedBox(height: 16),
                  Text(
                    t('आपका डेटा सुरक्षित है', 'Your data is safe'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(t(
                    'Sambal आपके फ़ोन पर ही डेटा रखता है। कोई व्यक्तिगत जानकारी सर्वर पर नहीं भेजी जाती।',
                    'Sambal keeps your data on your phone only. No personal information is sent to any server.',
                  )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t('संग्रहित जानकारी', 'Stored information'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  _DataRow(
                    icon: Icons.person_outline,
                    label: t('नाम', 'Name'),
                    value: controller.data.name.isNotEmpty
                        ? controller.data.name
                        : t('सेट नहीं', 'Not set'),
                  ),
                  _DataRow(
                    icon: Icons.location_on_outlined,
                    label: t('राज्य और जिला', 'State & district'),
                    value: controller.data.state.isNotEmpty
                        ? '${controller.data.state} / ${controller.data.district}'
                        : t('सेट नहीं', 'Not set'),
                  ),
                  _DataRow(
                    icon: Icons.home_work_outlined,
                    label: t('परिस्थिति', 'Circumstance'),
                    value: controller.data.circumstance.isNotEmpty
                        ? controller.data.circumstance
                        : t('सेट नहीं', 'Not set'),
                  ),
                  _DataRow(
                    icon: Icons.people_outlined,
                    label: t('रिश्ता', 'Relation'),
                    value: controller.data.relation.isNotEmpty
                        ? controller.data.relation
                        : t('सेट नहीं', 'Not set'),
                  ),
                  _DataRow(
                    icon: Icons.palette_outlined,
                    label: t('थीम', 'Theme'),
                    value: controller.isDarkMode
                        ? t('डार्क', 'Dark')
                        : t('लाइट', 'Light'),
                  ),
                  _DataRow(
                    icon: Icons.language,
                    label: t('भाषा', 'Language'),
                    value: controller.isHindi ? 'हिंदी' : 'English',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _confirmDelete(context, controller, t),
            style: FilledButton.styleFrom(
              backgroundColor: colors.error,
              foregroundColor: colors.onError,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            icon: const Icon(Icons.delete_forever_rounded),
            label: Text(t('सभी डेटा मिटाएँ', 'Delete all data')),
          ),
          const SizedBox(height: 8),
          Text(
            t(
              'यह सभी सेटिंग और चुनाव मिटा देगा। ऐप फिर से शुरू होगा।',
              'This will erase all settings and selections. The app will restart.',
            ),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    SambalController controller,
    String Function(String, String) t,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('पक्का मिटाएँ?', 'Are you sure?')),
        content: Text(t(
          'सभी डेटा स्थायी रूप से मिटा दिया जाएगा।',
          'All data will be permanently deleted.',
        )),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(t('रद्द', 'Cancel')),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ScannerService.deleteAllScans();
              await controller.clearAllData();
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const SplashScreen()),
                (_) => false,
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(t('मिटाएँ', 'Delete')),
          ),
        ],
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DataRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Text(
            value,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
