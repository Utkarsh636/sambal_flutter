import 'package:flutter/material.dart';
import '../case/case_controller.dart';

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
  final categories = const [
    DocumentCategory(
      id: 'id',
      hi: 'पहचान पत्र',
      en: 'Identity',
      icon: Icons.badge_outlined,
    ),
    DocumentCategory(
      id: 'certificate',
      hi: 'मृत्यु प्रमाणपत्र',
      en: 'Death certificate',
      icon: Icons.description_outlined,
    ),
    DocumentCategory(
      id: 'bank',
      hi: 'बैंक',
      en: 'Bank',
      icon: Icons.account_balance_outlined,
    ),
    DocumentCategory(
      id: 'insurance',
      hi: 'बीमा',
      en: 'Insurance',
      icon: Icons.health_and_safety_outlined,
    ),
    DocumentCategory(
      id: 'property',
      hi: 'संपत्ति',
      en: 'Property',
      icon: Icons.home_work_outlined,
    ),
    DocumentCategory(
      id: 'other',
      hi: 'अन्य',
      en: 'Other',
      icon: Icons.folder_outlined,
    ),
  ];

  String selectedCategory = 'id';

  final documents = <String, List<String>>{
    'id': ['Aadhaar (last 4 digits only)'],
    'certificate': [],
    'bank': ['Bank passbook photo'],
    'insurance': [],
    'property': [],
    'other': [],
  };

  @override
  Widget build(BuildContext context) {
    final controller = SambalScope.of(context);
    final hindi = controller.isHindi;
    String t(String hi, String en) => hindi ? hi : en;

    final selected = categories.firstWhere((item) => item.id == selectedCategory);
    final currentDocuments = documents[selectedCategory] ?? [];

    return Scaffold(
      appBar: AppBar(title: Text(t('दस्तावेज़', 'Documents'))),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addDocument(context, t),
        icon: const Icon(Icons.add_a_photo_outlined),
        label: Text(t('जोड़ें', 'Add')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            t('ज़रूरी कागज़ एक जगह रखें', 'Keep important papers in one place'),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            t(
              'अभी दस्तावेज़ सिर्फ़ इस ऐप के डेमो में दिखते हैं।',
              'For now, documents are shown only inside this app demo.',
            ),
          ),
          const SizedBox(height: 18),

          Text(
            t('श्रेणियाँ', 'Categories'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categories.map((category) {
              return ChoiceChip(
                avatar: Icon(
                  category.icon,
                  size: 18,
                  color: selectedCategory == category.id
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                label: Text(hindi ? category.hi : category.en),
                selected: selectedCategory == category.id,
                onSelected: (_) {
                  setState(() => selectedCategory = category.id);
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 22),

          Text(
            hindi ? selected.hi : selected.en,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),

          if (currentDocuments.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(Icons.folder_open_outlined, size: 44),
                    const SizedBox(height: 10),
                    Text(
                      t(
                        'इस श्रेणी में अभी कोई दस्तावेज़ नहीं है।',
                        'There are no documents in this category yet.',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

          ...currentDocuments.map(
            (document) => Card(
              child: ListTile(
                leading: Icon(selected.icon),
                title: Text(document),
                subtitle: Text(t('डेमो दस्तावेज़', 'Demo document')),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    setState(() => currentDocuments.remove(document));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(t('दस्तावेज़ हटाया गया', 'Document deleted')),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          Text(
            t('अभी भी चाहिए', 'Still needed'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),

          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.pending_actions_outlined),
                  title: Text(
                    t(
                      'मृत्यु प्रमाणपत्र की प्रति',
                      'Copy of death certificate',
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.pending_actions_outlined),
                  title: Text(
                    t(
                      'अस्पताल का मृत्यु-कारण प्रमाणपत्र',
                      'Hospital cause-of-death certificate',
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 72),
        ],
      ),
    );
  }

  void _addDocument(
    BuildContext context,
    String Function(String, String) t,
  ) {
    final nameController = TextEditingController();

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Wrap(
              children: [
                Text(
                  t('दस्तावेज़ जोड़ें', 'Add document'),
                  style: Theme.of(sheetContext).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: t('दस्तावेज़ का नाम', 'Document name'),
                    hintText: t('जैसे: पैन कार्ड', 'e.g. PAN card'),
                  ),
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: () {
                    final name = nameController.text.trim();
                    if (name.isEmpty) return;

                    setState(() {
                      documents.putIfAbsent(selectedCategory, () => []);
                      documents[selectedCategory]!.add(name);
                    });

                    Navigator.pop(sheetContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(t('दस्तावेज़ जोड़ा गया', 'Document added')),
                      ),
                    );
                  },
                  icon: const Icon(Icons.upload_file_outlined),
                  label: Text(t('डेमो दस्तावेज़ जोड़ें', 'Add demo document')),
                ),
                const SizedBox(height: 8),
                Text(
                  t(
                    'कैमरा और गैलरी से असली फ़ाइल जोड़ना अगले चरण में आएगा।',
                    'Real camera and gallery upload will be added in the next stage.',
                  ),
                  style: Theme.of(sheetContext).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}