import 'package:flutter/material.dart';
import '../case/case_controller.dart';

enum StepMode { online, partial, office }

class RoadmapItem {
  const RoadmapItem({
    required this.id,
    required this.titleHi,
    required this.titleEn,
    required this.mode,
    required this.mine,
    required this.documentsHi,
    required this.documentsEn,
  });

  final String id;
  final String titleHi;
  final String titleEn;
  final StepMode mode;
  final bool mine;
  final List<String> documentsHi;
  final List<String> documentsEn;
}

class RoadmapScreen extends StatefulWidget {
  const RoadmapScreen({super.key});

  @override
  State<RoadmapScreen> createState() => _RoadmapScreenState();
}

class _RoadmapScreenState extends State<RoadmapScreen> {
  bool certificateReceived = false;
  bool onlyMine = true;
  String filter = 'all';
  final doneIds = <String>{};

  final steps = const [
    RoadmapItem(
      id: 'copies',
      titleHi: 'अतिरिक्त प्रमाणित प्रतियाँ',
      titleEn: 'Extra certified copies',
      mode: StepMode.partial,
      mine: true,
      documentsHi: ['मृत्यु प्रमाणपत्र', 'पहचान पत्र'],
      documentsEn: ['Death certificate', 'Identity document'],
    ),
    RoadmapItem(
      id: 'bank',
      titleHi: 'बैंक नामांकित दावा',
      titleEn: 'Bank nominee claim',
      mode: StepMode.partial,
      mine: true,
      documentsHi: ['मृत्यु प्रमाणपत्र', 'पासबुक', 'नामांकन प्रमाण', 'पहचान पत्र'],
      documentsEn: ['Death certificate', 'Passbook', 'Nominee proof', 'Identity document'],
    ),
    RoadmapItem(
      id: 'insurance',
      titleHi: 'जीवन बीमा दावा',
      titleEn: 'Life insurance claim',
      mode: StepMode.online,
      mine: true,
      documentsHi: ['मृत्यु प्रमाणपत्र', 'पॉलिसी दस्तावेज़', 'पहचान पत्र'],
      documentsEn: ['Death certificate', 'Policy document', 'Identity document'],
    ),
    RoadmapItem(
      id: 'epf',
      titleHi: 'EPF और पेंशन',
      titleEn: 'EPF and pension',
      mode: StepMode.online,
      mine: true,
      documentsHi: ['मृत्यु प्रमाणपत्र', 'UAN', 'बैंक विवरण', 'पहचान पत्र'],
      documentsEn: ['Death certificate', 'UAN', 'Bank details', 'Identity document'],
    ),
    RoadmapItem(
      id: 'property',
      titleHi: 'संपत्ति दाखिल-खारिज',
      titleEn: 'Property mutation',
      mode: StepMode.office,
      mine: true,
      documentsHi: ['मृत्यु प्रमाणपत्र', 'संपत्ति दस्तावेज़', 'वारिस प्रमाणपत्र'],
      documentsEn: ['Death certificate', 'Property documents', 'Legal-heir certificate'],
    ),
    RoadmapItem(
      id: 'vehicle',
      titleHi: 'वाहन और उपयोगिता ट्रांसफर',
      titleEn: 'Vehicle and utility transfers',
      mode: StepMode.partial,
      mine: false,
      documentsHi: ['मृत्यु प्रमाणपत्र', 'RC / बिल', 'पहचान पत्र'],
      documentsEn: ['Death certificate', 'RC / bill', 'Identity document'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final controller = SambalScope.of(context);
    final hindi = controller.isHindi;
    String t(String hi, String en) => hindi ? hi : en;

    final visibleSteps = steps.where((step) {
      if (onlyMine && !step.mine) return false;
      if (filter == 'online' && step.mode == StepMode.office) return false;
      if (filter == 'office' && step.mode != StepMode.office) return false;
      if (filter == 'done' && !doneIds.contains(step.id)) return false;
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: Text(t('आगे का रास्ता', 'Your roadmap'))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            t('एक-एक कदम पूरा करें', 'Complete one step at a time'),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            t(
              '${doneIds.length} / ${steps.length} कदम पूरे',
              '${doneIds.length} / ${steps.length} steps complete',
            ),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(value: doneIds.length / steps.length),
          const SizedBox(height: 16),

          if (!certificateReceived)
            Card(
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t(
                        'पहले मृत्यु प्रमाणपत्र लें',
                        'Get the death certificate first',
                      ),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      t(
                        'ज़्यादातर दावों के लिए प्रमाणपत्र की प्रति ज़रूरी होती है।',
                        'Most claims require a copy of the death certificate.',
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () {
                        setState(() => certificateReceived = true);
                      },
                      child: Text(
                        t(
                          'मुझे प्रमाणपत्र मिल गया',
                          'I received the certificate',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: onlyMine,
            onChanged: (value) => setState(() => onlyMine = value),
            title: Text(t('मेरे लिए ज़रूरी', 'Needed for me')),
            subtitle: Text(
              t(
                'हर परिवार के लिए सभी कदम लागू नहीं होते।',
                'Not every step applies to every family.',
              ),
            ),
          ),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _filterChip('all', t('सभी', 'All')),
              _filterChip('online', t('ऑनलाइन', 'Online')),
              _filterChip('office', t('कार्यालय', 'Office')),
              _filterChip('done', t('पूरा', 'Done')),
            ],
          ),

          const SizedBox(height: 16),

          if (visibleSteps.isEmpty)
            Padding(
              padding: const EdgeInsets.all(30),
              child: Center(
                child: Text(t('कोई कदम नहीं मिला।', 'No steps found.')),
              ),
            ),

          ...visibleSteps.map(
            (step) => _stepCard(context, step, hindi),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String value, String label) {
    return ChoiceChip(
      label: Text(label),
      selected: filter == value,
      onSelected: (_) => setState(() => filter = value),
    );
  }

  Widget _stepCard(BuildContext context, RoadmapItem step, bool hindi) {
    String t(String hi, String en) => hindi ? hi : en;
    final locked = !certificateReceived;
    final complete = doneIds.contains(step.id);

    final modeLabel = switch (step.mode) {
      StepMode.online => t('ऑनलाइन', 'Online'),
      StepMode.partial => t('आंशिक ऑनलाइन', 'Partial'),
      StepMode.office => t('कार्यालय जाएँ', 'Office visit'),
    };

    final statusLabel = locked
        ? t('लॉक', 'Locked')
        : complete
            ? t('पूरा', 'Done')
            : t('तैयार', 'Ready');

    final colors = Theme.of(context).colorScheme;
    final statusColor = locked
        ? colors.outline
        : complete
            ? const Color(0xFF2E7D32)
            : colors.primary;

    return Card(
      child: ListTile(
        enabled: !locked,
        leading: CircleAvatar(
          backgroundColor: statusColor.withValues(alpha: 0.14),
          child: Icon(
            locked
                ? Icons.lock_outline
                : complete
                    ? Icons.check_circle
                    : Icons.arrow_forward,
            color: statusColor,
          ),
        ),
        title: Text(hindi ? step.titleHi : step.titleEn),
        subtitle: Text('$modeLabel · $statusLabel'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          if (locked) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  t(
                    'पहले मृत्यु प्रमाणपत्र मिलने की पुष्टि करें।',
                    'Confirm that you received the death certificate first.',
                  ),
                ),
              ),
            );
            return;
          }
          _openStepDetails(context, step, hindi);
        },
      ),
    );
  }

  void _openStepDetails(
    BuildContext context,
    RoadmapItem step,
    bool hindi,
  ) {
    String t(String hi, String en) => hindi ? hi : en;
    final documents = hindi ? step.documentsHi : step.documentsEn;
    final complete = doneIds.contains(step.id);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Wrap(
              children: [
                Text(
                  hindi ? step.titleHi : step.titleEn,
                  style: Theme.of(sheetContext).textTheme.titleLarge,
                ),
                const SizedBox(height: 14),
                Text(
                  t('ज़रूरी दस्तावेज़', 'Documents needed'),
                  style: Theme.of(sheetContext).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ...documents.map(
                  (document) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.description_outlined),
                    title: Text(document),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: complete
                      ? null
                      : () {
                          setState(() => doneIds.add(step.id));
                          Navigator.pop(sheetContext);
                        },
                  child: Text(
                    complete
                        ? t('यह कदम पूरा है', 'This step is complete')
                        : t('यह कदम पूरा हुआ', 'Mark step as done'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}