import 'package:flutter/material.dart';

import '../../core/storage/local_storage.dart';
import '../../core/theme/app_theme.dart';
import '../case/case_controller.dart';
import '../common/theme_toggle.dart';
import '../help/about_screen.dart';
import '../help/faq_screen.dart';
import '../help/helpline_screen.dart';
import '../roadmap/roadmap_screen.dart';
import '../settings/privacy_screen.dart';
import '../certificate/form_helper_screen.dart';
import '../settings/coverage_screen.dart';
import '../settings/settings_screen.dart';
import '../shell/shell_screen.dart';
import 'preparation_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = SambalScope.of(context);
    final data = controller.data;
    final hindi = controller.isHindi;
    final days = DateTime.now().difference(data.deathDate).inDays;
    final colors = Theme.of(context).colorScheme;

    String t(String hi, String en) => hindi ? hi : en;

    final scannedDocs = LocalStorage.loadScannedDocs();
    final roadmapDone = LocalStorage.roadmapDoneIds;
    final certReceived = LocalStorage.certificateReceived;
    final guideStep = LocalStorage.certificateGuideStep;

    int idx = 0;
    Widget stagger(Widget child) {
      final i = idx++;
      final start = (i * 0.08).clamp(0.0, 0.6);
      final end = (start + 0.4).clamp(0.0, 1.0);
      return _FadeSlideIn(
        animation: CurvedAnimation(
          parent: _animController,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
        child: child,
      );
    }

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
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: hindi ? 'सेटिंग' : 'Settings',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          stagger(Text(
            data.name.isNotEmpty
                ? t('${data.name}, आज एक ही कदम लें',
                    '${data.name}, take one step today')
                : t('आज एक ही कदम लें', 'Take one step today'),
            style: Theme.of(context).textTheme.headlineSmall,
          )),
          const SizedBox(height: 14),

          stagger(Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    days <= 21
                        ? t('मृत्यु पंजीकरण की निःशुल्क अवधि',
                            'Free death-registration period')
                        : t('देर से पंजीकरण', 'Late registration'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    days <= 21
                        ? t('दिन $days / 21 — समय पर आवेदन करें।',
                            'Day $days / 21 — apply on time.')
                        : t('चिंता न करें, हम अगले कदम बताएँगे।',
                            'Do not worry; we will guide the next step.'),
                  ),
                  if (days <= 21) ...[
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: days / 21,
                        minHeight: 6,
                        backgroundColor: colors.surfaceContainerHighest,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  if (data.state.isNotEmpty)
                    Text(
                      '${data.state} / ${data.district}',
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                ],
              ),
            ),
          )),

          const SizedBox(height: 12),

          stagger(_DeadlineCards(data: data, t: t, colors: colors)),

          const SizedBox(height: 18),

          stagger(Text(
            t('आपकी यात्रा', 'Your journey'),
            style: Theme.of(context).textTheme.titleMedium,
          )),
          const SizedBox(height: 10),

          stagger(_JourneyTracker(
            steps: [
              _JourneyStep(
                icon: Icons.location_on_outlined,
                label: t('स्थान', 'Location'),
                done: data.state.isNotEmpty,
              ),
              _JourneyStep(
                icon: Icons.description_outlined,
                label: t('प्रमाणपत्र', 'Certificate'),
                done: certReceived,
                badge: guideStep > 0 ? '${guideStep + 1}/6' : null,
              ),
              _JourneyStep(
                icon: Icons.document_scanner_outlined,
                label: t('स्कैन', 'Scan'),
                done: scannedDocs.isNotEmpty,
                badge: scannedDocs.isNotEmpty ? '${scannedDocs.length}' : null,
              ),
              _JourneyStep(
                icon: Icons.route_outlined,
                label: t('दावे', 'Claims'),
                done: roadmapDone.length >= 3,
                badge: roadmapDone.isNotEmpty
                    ? '${roadmapDone.length}/6'
                    : null,
              ),
            ],
            colors: colors,
          )),

          const SizedBox(height: 18),

          stagger(Card(
            color: colors.primaryContainer,
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () {
                final shell =
                    context.findAncestorStateOfType<ShellScreenState>();
                shell?.switchTab(1);
              },
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(Icons.description_rounded,
                        size: 36, color: colors.onPrimaryContainer),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t('मृत्यु प्रमाणपत्र गाइड शुरू करें',
                                'Start certificate guide'),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: colors.onPrimaryContainer),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            t('दस्तावेज़, फीस, और आवेदन — सब एक जगह',
                                'Documents, fees, and application — all in one place'),
                            style: TextStyle(
                              color: colors.onPrimaryContainer
                                  .withValues(alpha: 0.8),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_rounded,
                        color: colors.onPrimaryContainer),
                  ],
                ),
              ),
            ),
          )),

          const SizedBox(height: 10),
          stagger(Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const FormHelperScreen()),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(Icons.edit_document,
                        size: 32, color: colors.primary),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t('फॉर्म हेल्पर', 'Form helper'),
                            style:
                                Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            t('अपने डेटा से भरे फ़ील्ड — कॉपी और पेस्ट करें',
                                'Pre-filled fields from your data — copy & paste'),
                            style: TextStyle(
                                color: colors.onSurfaceVariant,
                                fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right,
                        color: colors.onSurfaceVariant),
                  ],
                ),
              ),
            ),
          )),

          // Scan documents CTA
          if (scannedDocs.isEmpty) ...[
            const SizedBox(height: 10),
            stagger(Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () {
                  final shell =
                      context.findAncestorStateOfType<ShellScreenState>();
                  shell?.switchTab(2);
                },
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Icon(Icons.document_scanner_outlined,
                          size: 32, color: colors.primary),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t('दस्तावेज़ स्कैन करें',
                                  'Scan your documents'),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              t('कैमरे से फ़ोटो लें, OCR से पहचानें, PDF बनाएँ',
                                  'Capture with camera, OCR text, generate PDF'),
                              style: TextStyle(
                                  color: colors.onSurfaceVariant,
                                  fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
                    ],
                  ),
                ),
              ),
            )),
          ],

          const SizedBox(height: 12),
          stagger(ListTile(
            leading: const Icon(Icons.assignment_outlined),
            title: Text(t('तैयारी पैक', 'Preparation pack')),
            subtitle: Text(t(
              'चेकलिस्ट, PDF, और प्रिंट',
              'Checklist, PDF, and print',
            )),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PreparationScreen()),
              );
            },
          )),
          stagger(ListTile(
            leading: const Icon(Icons.route_outlined),
            title: Text(t('आगे का रास्ता', 'Your roadmap')),
            subtitle: Text(t(
              'बैंक, बीमा, EPF और अन्य दावे',
              'Bank, insurance, EPF, and other claims',
            )),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RoadmapScreen()),
              );
            },
          )),
          stagger(ListTile(
            leading: const Icon(Icons.phone_in_talk_outlined),
            title: Text(t('हेल्पलाइन नंबर', 'Helpline numbers')),
            subtitle: Text(t('आपातकालीन और सरकारी हेल्पलाइन',
                'Emergency & government helplines')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const HelplineScreen()),
              );
            },
          )),
          stagger(ListTile(
            leading: const Icon(Icons.help_outline_rounded),
            title: Text(t('अक्सर पूछे जाने वाले प्रश्न', 'FAQ')),
            subtitle: Text(t('सामान्य प्रश्न और उत्तर',
                'Common questions & answers')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const FaqScreen()),
              );
            },
          )),
          stagger(ListTile(
            leading: const Icon(Icons.shield_outlined),
            title: Text(t('गोपनीयता और डेटा', 'Privacy & Data')),
            subtitle:
                Text(t('अपना डेटा देखें या मिटाएँ', 'View or delete your data')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PrivacyScreen()),
              );
            },
          )),
          stagger(ListTile(
            leading: const Icon(Icons.verified_outlined),
            title: Text(t('सत्यापित कवरेज', 'Verified coverage')),
            subtitle: Text(t('कौन से राज्य सत्यापित हैं',
                'Which states are verified')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const CoverageScreen()),
              );
            },
          )),
          stagger(ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: Text(t('Sambal के बारे में', 'About Sambal')),
            subtitle: Text(t('ऐप जानकारी और अस्वीकरण',
                'App info & disclaimer')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AboutScreen()),
              );
            },
          )),
        ],
      ),
    );
  }
}

class _JourneyStep {
  final IconData icon;
  final String label;
  final bool done;
  final String? badge;

  const _JourneyStep({
    required this.icon,
    required this.label,
    required this.done,
    this.badge,
  });
}

class _JourneyTracker extends StatelessWidget {
  final List<_JourneyStep> steps;
  final ColorScheme colors;

  const _JourneyTracker({required this.steps, required this.colors});

  @override
  Widget build(BuildContext context) {
    final doneCount = steps.where((s) => s.done).length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                for (int i = 0; i < steps.length; i++) ...[
                  Expanded(child: _buildStep(context, steps[i])),
                  if (i < steps.length - 1)
                    SizedBox(
                      width: 20,
                      child: Divider(
                        color: steps[i].done
                            ? AppTheme.success(Theme.of(context).brightness)
                            : colors.outlineVariant,
                        thickness: 2,
                      ),
                    ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: doneCount / steps.length,
                minHeight: 4,
                backgroundColor: colors.surfaceContainerHighest,
                color: AppTheme.success(Theme.of(context).brightness),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(BuildContext context, _JourneyStep step) {
    final successColor = AppTheme.success(Theme.of(context).brightness);

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: step.done
                  ? successColor.withValues(alpha: 0.15)
                  : colors.surfaceContainerHighest,
              child: Icon(
                step.done ? Icons.check_rounded : step.icon,
                size: 18,
                color: step.done ? successColor : colors.onSurfaceVariant,
              ),
            ),
            if (step.badge != null)
              Positioned(
                top: -4,
                right: -8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    step.badge!,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: colors.onPrimary,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          step.label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: step.done ? FontWeight.w700 : FontWeight.w500,
            color: step.done ? successColor : colors.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _Deadline {
  final String label;
  final int totalDays;
  final int remaining;
  final String source;

  _Deadline({
    required this.label,
    required this.totalDays,
    required this.remaining,
    required this.source,
  });

  bool get overdue => remaining < 0;
  bool get urgent => remaining >= 0 && remaining <= 3;
}

class _DeadlineCards extends StatelessWidget {
  final CaseData data;
  final String Function(String, String) t;
  final ColorScheme colors;

  const _DeadlineCards({
    required this.data,
    required this.t,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final daysSinceDeath = now.difference(data.deathDate).inDays;

    final deadlines = <_Deadline>[
      _Deadline(
        label: t('निःशुल्क पंजीकरण अवधि', 'Free registration period'),
        totalDays: 21,
        remaining: 21 - daysSinceDeath,
        source: 'RBD Act 1969, §13(1)',
      ),
      if (daysSinceDeath > 21)
        _Deadline(
          label: t('विलंबित पंजीकरण — शुल्क लग सकता है',
              'Delayed registration — fee may apply'),
          totalDays: 365,
          remaining: 365 - daysSinceDeath,
          source: 'RBD Act 1969, §13(2)–(3)',
        ),
    ];

    final relevant =
        deadlines.where((d) => d.remaining > -30).toList();

    if (relevant.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t('आने वाली समय सीमाएँ', 'Upcoming deadlines'),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        ...relevant.map((d) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _DeadlineTile(deadline: d, t: t, colors: colors),
            )),
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            t('राष्ट्रीय नियम — राज्य-विशिष्ट अवधि भिन्न हो सकती है। सत्यापन लंबित।',
                'National rules — state-specific periods may differ. Not verified.'),
            style: TextStyle(
              fontSize: 11,
              color: colors.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }
}

class _DeadlineTile extends StatelessWidget {
  final _Deadline deadline;
  final String Function(String, String) t;
  final ColorScheme colors;

  const _DeadlineTile({
    required this.deadline,
    required this.t,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor;
    final Color fgColor;
    final IconData icon;

    if (deadline.overdue) {
      bgColor = colors.errorContainer;
      fgColor = colors.onErrorContainer;
      icon = Icons.warning_amber_rounded;
    } else if (deadline.urgent) {
      bgColor = colors.errorContainer.withValues(alpha: 0.6);
      fgColor = colors.onErrorContainer;
      icon = Icons.schedule_rounded;
    } else {
      bgColor = colors.surfaceContainerHighest;
      fgColor = colors.onSurface;
      icon = Icons.event_outlined;
    }

    final daysText = deadline.overdue
        ? t('${-deadline.remaining} दिन पहले बीत गया',
            '${-deadline.remaining} days overdue')
        : t('${deadline.remaining} दिन बाकी',
            '${deadline.remaining} days left');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: fgColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  deadline.label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: fgColor,
                    fontSize: 13,
                  ),
                ),
                Text(
                  daysText,
                  style: TextStyle(fontSize: 12, color: fgColor),
                ),
              ],
            ),
          ),
          Flexible(
            flex: 0,
            child: Text(
              deadline.source,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 10,
                color: fgColor.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FadeSlideIn extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const _FadeSlideIn({required this.animation, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(0, 16 * (1 - animation.value)),
            child: child,
          ),
        );
      },
    );
  }
}
