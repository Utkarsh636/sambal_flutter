import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/storage/local_storage.dart';
import '../../core/theme/app_theme.dart';
import '../case/case_controller.dart';
import '../documents/pdf_service.dart';
import '../documents/scanned_document.dart';

class PreparationScreen extends StatefulWidget {
  const PreparationScreen({super.key});

  @override
  State<PreparationScreen> createState() => _PreparationScreenState();
}

class _PreparationScreenState extends State<PreparationScreen> {
  bool _generating = false;
  File? _pdfFile;

  String _t(String hi, String en) =>
      SambalScope.of(context).isHindi ? hi : en;

  @override
  Widget build(BuildContext context) {
    final controller = SambalScope.of(context);
    final data = controller.data;
    final hindi = controller.isHindi;
    final colors = Theme.of(context).colorScheme;
    final docs = LocalStorage.loadScannedDocs();
    final roadmapDone = LocalStorage.roadmapDoneIds;
    final certReceived = LocalStorage.certificateReceived;
    final days = DateTime.now().difference(data.deathDate).inDays;

    final checklist = _buildChecklist(data, docs, certReceived, days);
    final doneCount = checklist.where((c) => c.done).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(_t('तैयारी पैक', 'Preparation pack')),
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
                  Row(
                    children: [
                      Icon(Icons.assignment_outlined,
                          size: 32, color: colors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _t('आवेदन की तैयारी', 'Application readiness'),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: doneCount / checklist.length,
                      minHeight: 8,
                      backgroundColor: colors.surfaceContainerHighest,
                      color: AppTheme.success(Theme.of(context).brightness),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _t('$doneCount / ${checklist.length} तैयार',
                        '$doneCount / ${checklist.length} ready'),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          Text(
            _t('चेकलिस्ट', 'Checklist'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ...checklist.map((item) => _CheckItem(item: item, colors: colors)),

          const SizedBox(height: 16),
          Text(
            _t('केस विवरण', 'Case details'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _DetailRow(
                    label: _t('राज्य', 'State'),
                    value: data.state.isNotEmpty
                        ? data.state
                        : _t('सेट नहीं', 'Not set'),
                  ),
                  _DetailRow(
                    label: _t('जिला', 'District'),
                    value: data.district.isNotEmpty
                        ? data.district
                        : _t('सेट नहीं', 'Not set'),
                  ),
                  _DetailRow(
                    label: _t('परिस्थिति', 'Circumstance'),
                    value: data.circumstance.isNotEmpty
                        ? data.circumstance
                        : _t('सेट नहीं', 'Not set'),
                  ),
                  _DetailRow(
                    label: _t('बीते दिन', 'Days elapsed'),
                    value: '$days',
                  ),
                  _DetailRow(
                    label: _t('स्कैन किए दस्तावेज़', 'Scanned documents'),
                    value: '${docs.length}',
                  ),
                  _DetailRow(
                    label: _t('रोडमैप प्रगति', 'Roadmap progress'),
                    value: '${roadmapDone.length}/6',
                  ),
                ],
              ),
            ),
          ),

          if (docs.isNotEmpty) ...[
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _generating ? null : () => _generate(data, docs, hindi),
              icon: _generating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.picture_as_pdf_outlined),
              label: Text(_t('PDF पैक बनाएँ', 'Generate PDF pack')),
            ),
            if (_pdfFile != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => PdfService.printPack(_pdfFile!),
                      icon: const Icon(Icons.print_outlined),
                      label: Text(_t('प्रिंट', 'Print')),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => PdfService.sharePack(_pdfFile!),
                      icon: const Icon(Icons.share_outlined),
                      label: Text(_t('शेयर', 'Share')),
                    ),
                  ),
                ],
              ),
            ],
          ],

          if (docs.isEmpty) ...[
            const SizedBox(height: 24),
            Text(
              _t('PDF बनाने के लिए पहले दस्तावेज़ स्कैन करें।',
                  'Scan documents first to generate a PDF pack.'),
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
          ],

          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () => _shareWhatsApp(data, checklist, hindi, days),
            icon: const Icon(Icons.send_rounded),
            label: Text(_t('WhatsApp पर चेकलिस्ट भेजें',
                'Share checklist on WhatsApp')),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => _openOfficeFinder(data),
            icon: const Icon(Icons.location_on_outlined),
            label: Text(_t('नजदीकी पंजीकरण कार्यालय खोजें',
                'Find nearest registration office')),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _shareWhatsApp(
    CaseData data,
    List<_ChecklistItem> checklist,
    bool hindi,
    int days,
  ) {
    final buffer = StringBuffer();
    buffer.writeln(hindi
        ? '📋 *Sambal — मृत्यु प्रमाणपत्र चेकलिस्ट*'
        : '📋 *Sambal — Death Certificate Checklist*');
    buffer.writeln('');
    buffer.writeln(hindi
        ? 'राज्य: ${data.state} | जिला: ${data.district}'
        : 'State: ${data.state} | District: ${data.district}');
    buffer.writeln(hindi ? 'बीते दिन: $days' : 'Days elapsed: $days');
    buffer.writeln('');

    for (final item in checklist) {
      final mark = item.done ? '✅' : '⬜';
      buffer.writeln('$mark ${hindi ? item.hi : item.en}');
    }

    buffer.writeln('');
    buffer.writeln(hindi
        ? '_Sambal ऐप से बनाया गया — हर कदम पर साथ_'
        : '_Made with Sambal — हर कदम पर साथ_');

    final text = Uri.encodeComponent(buffer.toString());
    launchUrl(Uri.parse('https://wa.me/?text=$text'),
        mode: LaunchMode.externalApplication);
  }

  void _openOfficeFinder(CaseData data) {
    final query = Uri.encodeComponent(
        'death registration office ${data.district} ${data.state}');
    launchUrl(Uri.parse('https://www.google.com/maps/search/$query'),
        mode: LaunchMode.externalApplication);
  }

  List<_ChecklistItem> _buildChecklist(
    CaseData data,
    List<ScannedDocument> docs,
    bool certReceived,
    int days,
  ) {
    return [
      _ChecklistItem(
        hi: 'राज्य और जिला चुना',
        en: 'State & district selected',
        done: data.state.isNotEmpty,
      ),
      _ChecklistItem(
        hi: 'परिस्थिति चुनी',
        en: 'Circumstance selected',
        done: data.circumstance.isNotEmpty,
      ),
      _ChecklistItem(
        hi: 'मृत्यु प्रमाणपत्र प्राप्त',
        en: 'Death certificate received',
        done: certReceived,
      ),
      _ChecklistItem(
        hi: 'कम से कम एक दस्तावेज़ स्कैन किया',
        en: 'At least one document scanned',
        done: docs.isNotEmpty,
      ),
      _ChecklistItem(
        hi: 'पहचान पत्र स्कैन किया',
        en: 'Identity document scanned',
        done: docs.any((d) => d.categoryId == 'id'),
      ),
      _ChecklistItem(
        hi: 'समय पर आवेदन (21 दिन के अंदर)',
        en: 'Applied within free period (21 days)',
        done: days <= 21,
      ),
    ];
  }

  Future<void> _generate(
    CaseData data,
    List<ScannedDocument> docs,
    bool hindi,
  ) async {
    setState(() => _generating = true);
    try {
      final file = await PdfService.generatePack(
        caseData: data,
        documents: docs,
        isHindi: hindi,
      );
      if (mounted) setState(() => _pdfFile = file);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(_t('PDF बनाने में त्रुटि', 'Error generating PDF'))),
        );
      }
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }
}

class _ChecklistItem {
  final String hi;
  final String en;
  final bool done;

  const _ChecklistItem({
    required this.hi,
    required this.en,
    required this.done,
  });
}

class _CheckItem extends StatelessWidget {
  final _ChecklistItem item;
  final ColorScheme colors;

  const _CheckItem({required this.item, required this.colors});

  @override
  Widget build(BuildContext context) {
    final hindi = SambalScope.of(context).isHindi;
    final successColor = AppTheme.success(Theme.of(context).brightness);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            item.done
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked,
            size: 22,
            color: item.done ? successColor : colors.outline,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              hindi ? item.hi : item.en,
              style: TextStyle(
                decoration: item.done ? TextDecoration.lineThrough : null,
                color: item.done ? colors.onSurfaceVariant : colors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(
            value,
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
