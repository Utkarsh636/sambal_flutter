import 'package:flutter/material.dart';

import '../case/case_controller.dart';
import '../common/theme_toggle.dart';
import '../roadmap/roadmap_screen.dart';
import '../settings/privacy_screen.dart';
import '../shell/shell_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = SambalScope.of(context);
    final data = controller.data;
    final hindi = controller.isHindi;
    final days = DateTime.now().difference(data.deathDate).inDays;

    String t(String hi, String en) => hindi ? hi : en;

    return Scaffold(
      appBar: AppBar(
        title: Text(t('संबल', 'Sambal')),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            tooltip: hindi ? 'Switch to English' : 'हिन्दी में बदलें',
            onPressed: controller.toggleLanguage,
          ),
          const ThemeToggleButton(),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            t('आज एक ही कदम लें', 'Take one step today'),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    days <= 21
                        ? t(
                            'मृत्यु पंजीकरण की निःशुल्क अवधि',
                            'Free death-registration period',
                          )
                        : t('देर से पंजीकरण', 'Late registration'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    days <= 21
                        ? t(
                            'दिन $days / 21 — समय पर आवेदन करें।',
                            'Day $days / 21 — apply on time.',
                          )
                        : t(
                            'चिंता न करें, हम अगले कदम बताएँगे।',
                            'Do not worry; we will guide the next step.',
                          ),
                  ),
                  const SizedBox(height: 8),
                  if (data.state.isNotEmpty)
                    Text(
                      '${data.state} / ${data.district}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () {
                final shell = context.findAncestorStateOfType<ShellScreenState>();
                shell?.switchTab(1);
              },
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(
                      Icons.description_rounded,
                      size: 36,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t('मृत्यु प्रमाणपत्र गाइड शुरू करें', 'Start certificate guide'),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            t(
                              'दस्तावेज़, फीस, और आवेदन — सब एक जगह',
                              'Documents, fees, and application — all in one place',
                            ),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.route_outlined),
            title: Text(t('आगे का रास्ता', 'Your roadmap')),
            subtitle: Text(
              t(
                'बैंक, बीमा, EPF और अन्य दावे',
                'Bank, insurance, EPF, and other claims',
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RoadmapScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.shield_outlined),
            title: Text(t('गोपनीयता और डेटा', 'Privacy & Data')),
            subtitle: Text(
              t('अपना डेटा देखें या मिटाएँ', 'View or delete your data'),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PrivacyScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
