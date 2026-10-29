import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/storage/local_storage.dart';
import '../case/case_controller.dart';
import 'capture_screen.dart';
import 'pdf_service.dart';
import 'scanned_document.dart';

class DocumentCategory {
  const DocumentCategory({
    required this.id,
    required this.hi,
    required this.en,
    required this.icon,
  });

  final String id;
  final String hi;
  final String en;
  final IconData icon;
}

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  static const categories = [
    DocumentCategory(id: 'id', hi: 'पहचान पत्र', en: 'Identity', icon: Icons.badge_outlined),
    DocumentCategory(id: 'certificate', hi: 'मृत्यु प्रमाणपत्र', en: 'Death certificate', icon: Icons.description_outlined),
    DocumentCategory(id: 'bank', hi: 'बैंक', en: 'Bank', icon: Icons.account_balance_outlined),
    DocumentCategory(id: 'insurance', hi: 'बीमा', en: 'Insurance', icon: Icons.health_and_safety_outlined),
    DocumentCategory(id: 'property', hi: 'संपत्ति', en: 'Property', icon: Icons.home_work_outlined),
    DocumentCategory(id: 'other', hi: 'अन्य', en: 'Other', icon: Icons.folder_outlined),
  ];

  String _selectedCategory = 'id';
  List<ScannedDocument> _docs = [];
  bool _generatingPdf = false;

  @override
  void initState() {
    super.initState();
    _docs = LocalStorage.loadScannedDocs();
  }

  void _persist() => LocalStorage.saveScannedDocs(_docs);

  List<ScannedDocument> get _currentDocs =>
      _docs.where((d) => d.categoryId == _selectedCategory).toList();

  Future<void> _openScanner() async {
    final result = await Navigator.push<ScannedDocument>(
      context,
      MaterialPageRoute(
        builder: (_) => CaptureScreen(initialCategory: _selectedCategory),
      ),
    );
    if (result != null) {
      setState(() => _docs.add(result));
      _persist();
      if (mounted) {
        final t = _t;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t('दस्तावेज़ सहेजा गया', 'Document saved'))),
        );
      }
    }
  }

  void _deleteDoc(ScannedDocument doc) {
    setState(() => _docs.removeWhere((d) => d.id == doc.id));
    _persist();
    for (final path in doc.imagePaths) {
      File(path).delete().ignore();
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_t('दस्तावेज़ हटाया गया', 'Document deleted'))),
    );
  }

  Future<void> _generatePdf() async {
    if (_docs.isEmpty) return;
    setState(() => _generatingPdf = true);
    try {
      final caseData = SambalScope.of(context).data;
      final isHindi = SambalScope.of(context).isHindi;
      final file = await PdfService.generatePack(
        caseData: caseData,
        documents: _docs,
        isHindi: isHindi,
      );
      if (!mounted) return;
      await _showPdfActions(file);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_t('PDF बनाने में त्रुटि', 'Error generating PDF'))),
        );
      }
    } finally {
      if (mounted) setState(() => _generatingPdf = false);
    }
  }

  Future<void> _showPdfActions(File pdfFile) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _t('PDF तैयार है', 'PDF ready'),
                style: Theme.of(ctx).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.print_outlined),
                title: Text(_t('प्रिंट करें', 'Print')),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                onTap: () => Navigator.pop(ctx, 'print'),
              ),
              ListTile(
                leading: const Icon(Icons.share_outlined),
                title: Text(_t('शेयर करें', 'Share')),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                onTap: () => Navigator.pop(ctx, 'share'),
              ),
            ],
          ),
        ),
      ),
    );
    if (action == 'print') {
      await PdfService.printPack(pdfFile);
    } else if (action == 'share') {
      await PdfService.sharePack(pdfFile);
    }
  }

  String Function(String, String) get _t {
    final hindi = SambalScope.of(context).isHindi;
    return (String hi, String en) => hindi ? hi : en;
  }

  @override
  Widget build(BuildContext context) {
    final t = _t;
    final hindi = SambalScope.of(context).isHindi;
    final colors = Theme.of(context).colorScheme;
    final selected = categories.firstWhere((c) => c.id == _selectedCategory);
    final currentDocs = _currentDocs;

    return Scaffold(
      appBar: AppBar(
        title: Text(t('दस्तावेज़', 'Documents')),
        actions: [
          if (_docs.isNotEmpty)
            IconButton(
              onPressed: _generatingPdf ? null : _generatePdf,
              icon: _generatingPdf
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.picture_as_pdf_outlined),
              tooltip: t('PDF बनाएँ', 'Generate PDF'),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openScanner,
        icon: const Icon(Icons.add_a_photo_outlined),
        label: Text(t('स्कैन करें', 'Scan')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            t('अपने ज़रूरी कागज़ स्कैन करके रखें',
                'Scan and keep your important documents'),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text(
            t('सभी स्कैन सिर्फ़ आपके फ़ोन पर रहते हैं।',
                'All scans stay only on your phone.'),
            style: TextStyle(color: colors.onSurfaceVariant),
          ),

          if (_docs.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              color: colors.primaryContainer,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: _generatingPdf ? null : _generatePdf,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.picture_as_pdf_outlined, color: colors.onPrimaryContainer),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t('PDF पैक बनाएँ और शेयर करें',
                                  'Generate & share PDF pack'),
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: colors.onPrimaryContainer,
                              ),
                            ),
                            Text(
                              t('${_docs.length} दस्तावेज़ स्कैन किए गए',
                                  '${_docs.length} documents scanned'),
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.onPrimaryContainer.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, size: 16, color: colors.onPrimaryContainer),
                    ],
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 18),
          Text(
            t('श्रेणियाँ', 'Categories'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categories.map((cat) {
              final count = _docs.where((d) => d.categoryId == cat.id).length;
              return ChoiceChip(
                avatar: Icon(cat.icon, size: 18,
                    color: _selectedCategory == cat.id ? colors.primary : null),
                label: Text(
                  '${hindi ? cat.hi : cat.en}${count > 0 ? ' ($count)' : ''}',
                ),
                selected: _selectedCategory == cat.id,
                onSelected: (_) => setState(() => _selectedCategory = cat.id),
              );
            }).toList(),
          ),

          const SizedBox(height: 22),
          Text(
            hindi ? selected.hi : selected.en,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),

          if (currentDocs.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(Icons.folder_open_outlined, size: 44),
                    const SizedBox(height: 10),
                    Text(
                      t('इस श्रेणी में अभी कोई स्कैन नहीं है।',
                          'No scans in this category yet.'),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _openScanner,
                      icon: const Icon(Icons.add_a_photo_outlined, size: 18),
                      label: Text(t('स्कैन करें', 'Scan')),
                    ),
                  ],
                ),
              ),
            ),

          ...currentDocs.map((doc) => _DocCard(
                doc: doc,
                category: selected,
                isHindi: hindi,
                onDelete: () => _deleteDoc(doc),
              )),

          const SizedBox(height: 24),
          Text(
            t('अभी भी चाहिए', 'Still needed'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          _buildStillNeeded(context, t),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildStillNeeded(
    BuildContext context,
    String Function(String, String) t,
  ) {
    final caseData = SambalScope.of(context).data;
    final circumstance = caseData.circumstance.toLowerCase();
    final days = DateTime.now().difference(caseData.deathDate).inDays;
    final colors = Theme.of(context).colorScheme;

    final needed = <({String hi, String en, String category, bool required})>[];

    needed.add((hi: 'आवेदन पत्र (फॉर्म 2)', en: 'Application form (Form 2)', category: 'other', required: true));
    needed.add((hi: 'सूचनादाता का पहचान पत्र', en: "Informant's ID proof", category: 'id', required: true));
    needed.add((hi: 'मृतक का पहचान पत्र', en: "Deceased's ID proof", category: 'id', required: true));
    needed.add((hi: 'मृतक के निवास का प्रमाण', en: "Deceased's address proof", category: 'id', required: true));

    if (circumstance == 'hospital') {
      needed.add((hi: 'मेडिकल सर्टिफिकेट (MCCD)', en: 'Medical Certificate of Cause of Death (MCCD)', category: 'certificate', required: true));
      needed.add((hi: 'अस्पताल डिस्चार्ज / मृत्यु सारांश', en: 'Hospital discharge / death summary', category: 'certificate', required: true));
    } else if (circumstance == 'home') {
      needed.add((hi: 'परिवार के सदस्य का घोषणा पत्र', en: 'Declaration from family member', category: 'other', required: true));
      needed.add((hi: 'अंतिम संस्कार / दफ़न प्रमाण पत्र', en: 'Cremation / burial certificate', category: 'other', required: true));
    } else if (circumstance == 'accident') {
      needed.add((hi: 'FIR की प्रति', en: 'Copy of FIR', category: 'other', required: true));
      needed.add((hi: 'पोस्टमार्टम रिपोर्ट', en: 'Postmortem report', category: 'certificate', required: true));
      needed.add((hi: 'पुलिस पंचनामा', en: 'Police inquest report', category: 'other', required: true));
    }

    if (days > 21) {
      needed.add((hi: 'सूचनादाता का शपथ पत्र', en: 'Affidavit from informant', category: 'other', required: true));
    }
    if (days > 30) {
      needed.add((hi: 'निर्धारित प्राधिकारी की अनुमति', en: 'Permission from prescribed authority', category: 'other', required: true));
    }
    if (days > 365) {
      needed.add((hi: 'प्रथम श्रेणी मजिस्ट्रेट का आदेश', en: 'Order from First Class Magistrate', category: 'other', required: true));
    }

    final scannedLabels = _docs.map((d) => d.label.toLowerCase()).toSet();

    bool isMatched(({String hi, String en, String category, bool required}) item) {
      final enWords = item.en.toLowerCase().split(' ');
      final hiWords = item.hi.split(' ');
      return scannedLabels.any((l) =>
          enWords.any((w) => w.length > 3 && l.contains(w)) ||
          hiWords.any((w) => w.length > 2 && l.contains(w)));
    }

    final matchedCount = needed.where(isMatched).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t('$matchedCount / ${needed.length} दस्तावेज़ मिलान',
              '$matchedCount / ${needed.length} documents matched'),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          t('RBD Act 1969 के अनुसार। स्थानीय निकाय अतिरिक्त कागज़ात माँग सकता है।',
              'Per RBD Act 1969. Local body may ask for additional papers.'),
          style: TextStyle(fontSize: 11, color: colors.outline),
        ),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: needed.map((item) {
              final matched = isMatched(item);
              return ListTile(
                leading: Icon(
                  matched ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                  color: matched ? colors.primary : colors.outline,
                  size: 22,
                ),
                title: Text(
                  t(item.hi, item.en),
                  style: TextStyle(
                    fontSize: 14,
                    decoration: matched ? TextDecoration.lineThrough : null,
                    color: matched ? colors.onSurfaceVariant : colors.onSurface,
                  ),
                ),
                dense: true,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _DocCard extends StatelessWidget {
  final ScannedDocument doc;
  final DocumentCategory category;
  final bool isHindi;
  final VoidCallback onDelete;

  const _DocCard({
    required this.doc,
    required this.category,
    required this.isHindi,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final firstImage = doc.imagePaths.isNotEmpty ? doc.imagePaths.first : null;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => _showDetail(context),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              if (firstImage != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    File(firstImage),
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(category.icon, color: colors.onSurfaceVariant),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc.label,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${doc.imagePaths.length} ${isHindi ? "पन्ने" : "pages"}',
                      style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: isHindi ? 'हटाएँ' : 'Delete',
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              doc.label,
              style: Theme.of(ctx).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              doc.scannedAt.toString().split('.').first,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(ctx).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            ...doc.imagePaths.map(
              (path) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.file(File(path), fit: BoxFit.contain),
                ),
              ),
            ),
            if (doc.ocrText.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                isHindi ? 'पहचाना गया टेक्स्ट' : 'Recognized text',
                style: Theme.of(ctx).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: SelectableText(
                    doc.ocrText,
                    style: Theme.of(ctx).textTheme.bodySmall,
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
