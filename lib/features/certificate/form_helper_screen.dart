import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../case/case_controller.dart';

class FormHelperScreen extends StatelessWidget {
  const FormHelperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = SambalScope.of(context);
    final data = controller.data;
    final hindi = controller.isHindi;
    final colors = Theme.of(context).colorScheme;
    String t(String hi, String en) => hindi ? hi : en;

    final dateStr =
        '${data.deathDate.day}/${data.deathDate.month}/${data.deathDate.year}';

    final fields = <_FormField>[
      _FormField(
        label: t('सूचना देने वाले का नाम', "Informant's name"),
        value: data.name,
        prefilled: data.name.isNotEmpty,
        editable: true,
      ),
      _FormField(
        label: t('मृतक से संबंध', 'Relation to deceased'),
        value: data.relation,
        prefilled: data.relation.isNotEmpty,
        editable: true,
      ),
      _FormField(
        label: t('मृत्यु की तारीख', 'Date of death'),
        value: dateStr,
        prefilled: true,
        editable: true,
      ),
      _FormField(
        label: t('मृत्यु का स्थान (राज्य/जिला)', 'Place of death (State/District)'),
        value: data.state.isNotEmpty
            ? '${data.state}, ${data.district}'
            : '',
        prefilled: data.state.isNotEmpty,
        editable: true,
      ),
      _FormField(
        label: t('मृत्यु की परिस्थिति', 'Circumstance of death'),
        value: data.circumstance,
        prefilled: data.circumstance.isNotEmpty,
        editable: true,
      ),
      _FormField(
        label: t('अंतिम संस्कार / दाह संस्कार', 'Last rites / Cremation'),
        value: data.rites,
        prefilled: data.rites.isNotEmpty,
        editable: true,
      ),
      _FormField(
        label: t('मृत्यु का कारण', 'Cause of death'),
        value: '',
        prefilled: false,
        editable: false,
        doctorOnly: true,
      ),
      _FormField(
        label: t('चिकित्सा प्रमाणन', 'Medical certification'),
        value: '',
        prefilled: false,
        editable: false,
        doctorOnly: true,
      ),
      _FormField(
        label: t('पंजीकरण इकाई / केंद्र', 'Registration unit / Centre'),
        value: '',
        prefilled: false,
        editable: true,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(t('फॉर्म हेल्पर', 'Form helper')),
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
                      Icon(Icons.edit_document,
                          color: colors.primary, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          t('फॉर्म नं. 2 — मृत्यु सूचना',
                              'Form No. 2 — Death Intimation'),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t('आपके डेटा से भरे गए फील्ड। कॉपी बटन से ऑनलाइन फॉर्म में पेस्ट करें।',
                        'Fields pre-filled from your data. Use the copy button to paste into online forms.'),
                    style: TextStyle(
                        color: colors.onSurfaceVariant, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colors.errorContainer.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.medical_services_outlined,
                    size: 18, color: colors.onErrorContainer),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    t('🔒 चिह्नित फ़ील्ड केवल डॉक्टर / प्राधिकारी भर सकते हैं',
                        '🔒 Marked fields can only be filled by a doctor / authority'),
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.onErrorContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...fields.map((f) => _FormFieldTile(
                field: f,
                colors: colors,
                t: t,
              )),
          const SizedBox(height: 16),
          Text(
            t('यह फॉर्म केवल मदद के लिए है — आधिकारिक फॉर्म अपने पंजीकरण कार्यालय या पोर्टल से लें।',
                'This form is only a helper — get the official form from your registration office or portal.'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: colors.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _FormField {
  final String label;
  final String value;
  final bool prefilled;
  final bool editable;
  final bool doctorOnly;

  const _FormField({
    required this.label,
    required this.value,
    required this.prefilled,
    required this.editable,
    this.doctorOnly = false,
  });
}

class _FormFieldTile extends StatelessWidget {
  final _FormField field;
  final ColorScheme colors;
  final String Function(String, String) t;

  const _FormFieldTile({
    required this.field,
    required this.colors,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: field.doctorOnly
              ? colors.errorContainer.withValues(alpha: 0.15)
              : colors.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(14),
          border: field.prefilled
              ? Border.all(
                  color: colors.primary.withValues(alpha: 0.3), width: 1)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (field.doctorOnly)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Icon(Icons.lock_outlined,
                        size: 14, color: colors.error),
                  ),
                Expanded(
                  child: Text(
                    field.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
                if (field.prefilled)
                  Icon(Icons.check_circle,
                      size: 16, color: colors.primary),
              ],
            ),
            const SizedBox(height: 6),
            if (field.doctorOnly)
              Text(
                t('केवल डॉक्टर / प्राधिकारी', 'Doctor / authority only'),
                style: TextStyle(
                  fontSize: 13,
                  color: colors.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              )
            else if (field.value.isNotEmpty)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      field.value,
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 18),
                    tooltip: t('कॉपी करें', 'Copy'),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: field.value));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              t('कॉपी हो गया', 'Copied to clipboard')),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              )
            else
              Text(
                t('अभी खाली — फॉर्म में भरें', 'Empty — fill in the form'),
                style: TextStyle(
                  fontSize: 13,
                  color: colors.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
