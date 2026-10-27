import 'package:flutter/material.dart';
import '../assistant/assistant_screen.dart';
import '../case/case_controller.dart';
import '../certificate/certificate_screen.dart';
import '../common/theme_toggle.dart';
import '../documents/documents_screen.dart';
import '../roadmap/roadmap_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = SambalScope.of(context);
    final data = controller.data;
    final hindi = controller.isHindi;
    final days = DateTime.now().difference(data.deathDate).inDays;

    String t(String hi, String en) => hindi ? hi : en;

    void openCertificate() {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const CertificateScreen()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(t('संबल', 'Sambal')),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
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
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: openCertificate,
                    child: Text(
                      t(
                        'मृत्यु प्रमाणपत्र शुरू करें',
                        'Start death certificate',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
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
            leading: const Icon(Icons.chat_bubble_outline),
            title: Text(t('सहायक', 'Assistant')),
            subtitle: Text(t('सवाल पूछें', 'Ask a question')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AssistantScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.folder_outlined),
            title: Text(t('दस्तावेज़', 'Documents')),
            subtitle: Text(
              t(
                'ज़रूरी कागज़ एक जगह रखें',
                'Keep important papers in one place',
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DocumentsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}