import 'dart:io';

import 'package:flutter/material.dart';

import '../case/case_controller.dart';
import 'scanner_service.dart';
import 'scanned_document.dart';

class CaptureScreen extends StatefulWidget {
  final String initialCategory;

  const CaptureScreen({super.key, this.initialCategory = 'other'});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  final List<String> _imagePaths = [];
  String _ocrText = '';
  bool _processing = false;
  late String _selectedCategory;
  final _labelController = TextEditingController();

  static const _categories = [
    ('id', 'पहचान पत्र', 'Identity'),
    ('certificate', 'मृत्यु प्रमाणपत्र', 'Death certificate'),
    ('bank', 'बैंक', 'Bank'),
    ('insurance', 'बीमा', 'Insurance'),
    ('property', 'संपत्ति', 'Property'),
    ('other', 'अन्य', 'Other'),
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    WidgetsBinding.instance.addPostFrameCallback((_) => _capture());
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  String _t(String hi, String en) =>
      SambalScope.of(context).isHindi ? hi : en;

  Future<void> _capture() async {
    final path = await ScannerService.captureFromCamera();
    if (path == null) {
      if (_imagePaths.isEmpty && mounted) Navigator.pop(context);
      return;
    }
    setState(() {
      _imagePaths.add(path);
      _processing = true;
    });
    try {
      final text = await ScannerService.recognizeText(path);
      if (!mounted) return;
      setState(() {
        if (text.isNotEmpty) {
          _ocrText += (_ocrText.isNotEmpty ? '\n---\n' : '') + text;
        }
        _processing = false;
      });
    } catch (_) {
      if (mounted) setState(() => _processing = false);
    }
  }

  Future<void> _pickGallery() async {
    final path = await ScannerService.pickFromGallery();
    if (path == null) return;
    setState(() {
      _imagePaths.add(path);
      _processing = true;
    });
    try {
      final text = await ScannerService.recognizeText(path);
      if (!mounted) return;
      setState(() {
        if (text.isNotEmpty) {
          _ocrText += (_ocrText.isNotEmpty ? '\n---\n' : '') + text;
        }
        _processing = false;
      });
    } catch (_) {
      if (mounted) setState(() => _processing = false);
    }
  }

  Future<void> _save() async {
    if (_imagePaths.isEmpty) return;
    final label = _labelController.text.trim();
    if (label.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_t('नाम दें', 'Enter a label'))),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_t('दस्तावेज़ सही है?', 'Is this document correct?')),
        content: Text(_t(
          'कृपया पुष्टि करें कि "$label" का स्कैन स्पष्ट और सही है। Sambal किसी दस्तावेज़ को स्वतः स्वीकृत नहीं करता।',
          'Please confirm that the scan of "$label" is clear and correct. Sambal does not auto-accept any document.',
        )),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(_t('वापस जाएँ', 'Go back')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(_t('पुष्टि करें', 'Confirm')),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final doc = ScannedDocument(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      categoryId: _selectedCategory,
      label: label,
      imagePaths: List.unmodifiable(_imagePaths),
      ocrText: _ocrText,
      confirmedByUser: true,
      scannedAt: DateTime.now(),
    );
    Navigator.pop(context, doc);
  }

  @override
  Widget build(BuildContext context) {
    final hindi = SambalScope.of(context).isHindi;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_t('दस्तावेज़ स्कैन करें', 'Scan document')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_imagePaths.isNotEmpty) ...[
            Text(
              _t('स्कैन किए पन्ने (${_imagePaths.length})',
                  'Scanned pages (${_imagePaths.length})'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 130,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _imagePaths.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) => ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      Image.file(
                        File(_imagePaths[index]),
                        width: 95,
                        height: 130,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            ScannerService.deleteFile(_imagePaths[index]);
                            setState(() => _imagePaths.removeAt(index));
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 4,
                        left: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _processing ? null : _capture,
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: Text(_t('कैमरा', 'Camera')),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _processing ? null : _pickGallery,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: Text(_t('गैलरी', 'Gallery')),
                ),
              ),
            ],
          ),

          if (_processing)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: LinearProgressIndicator(),
            ),

          if (_ocrText.isNotEmpty) ...[
            const SizedBox(height: 16),
            ExpansionTile(
              leading: Icon(Icons.text_snippet_outlined, color: colors.primary),
              title: Text(_t('पहचाना गया टेक्स्ट', 'Recognized text')),
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    _ocrText.length > 500
                        ? '${_ocrText.substring(0, 500)}…'
                        : _ocrText,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ],

          if (_imagePaths.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              _t('श्रेणी चुनें', 'Select category'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((cat) {
                final (id, hi, en) = cat;
                return ChoiceChip(
                  label: Text(hindi ? hi : en),
                  selected: _selectedCategory == id,
                  onSelected: (_) =>
                      setState(() => _selectedCategory = id),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _labelController,
              decoration: InputDecoration(
                labelText: _t('दस्तावेज़ का नाम', 'Document label'),
                hintText:
                    _t('जैसे: आधार कार्ड', 'e.g. Aadhaar card'),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _processing ? null : _save,
              icon: const Icon(Icons.check_circle_outline),
              label: Text(_t('सहेजें', 'Save')),
            ),
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
