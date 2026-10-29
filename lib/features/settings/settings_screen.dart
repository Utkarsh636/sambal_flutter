import 'package:flutter/material.dart';

import '../case/case_controller.dart';
import '../case/location_setup_screen.dart';
import '../help/about_screen.dart';
import 'privacy_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _t(String hi, String en) =>
      SambalScope.of(context).isHindi ? hi : en;

  @override
  Widget build(BuildContext context) {
    final controller = SambalScope.of(context);
    final data = controller.data;
    final colors = Theme.of(context).colorScheme;
    final days = DateTime.now().difference(data.deathDate).inDays;

    return Scaffold(
      appBar: AppBar(
        title: Text(_t('सेटिंग', 'Settings')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            _t('केस विवरण', 'Case details'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                _EditTile(
                  icon: Icons.people_outlined,
                  label: _t('रिश्ता', 'Relation'),
                  value: data.relation.isNotEmpty
                      ? data.relation
                      : _t('सेट नहीं', 'Not set'),
                  onTap: () => _editRelation(controller),
                ),
                const Divider(height: 1, indent: 56),
                _EditTile(
                  icon: Icons.calendar_today_outlined,
                  label: _t('मृत्यु तिथि', 'Date of death'),
                  value: '${data.deathDate.day}/${data.deathDate.month}/${data.deathDate.year}'
                      ' ($days ${_t('दिन', 'days')})',
                  onTap: () => _editDeathDate(controller),
                ),
                const Divider(height: 1, indent: 56),
                _EditTile(
                  icon: Icons.location_on_outlined,
                  label: _t('राज्य / जिला', 'State / District'),
                  value: data.state.isNotEmpty
                      ? '${data.state} / ${data.district}'
                      : _t('सेट नहीं', 'Not set'),
                  onTap: () => _editLocation(controller),
                ),
                const Divider(height: 1, indent: 56),
                _EditTile(
                  icon: Icons.home_work_outlined,
                  label: _t('परिस्थिति', 'Circumstance'),
                  value: data.circumstance.isNotEmpty
                      ? data.circumstance
                      : _t('सेट नहीं', 'Not set'),
                  onTap: () => _editCircumstance(controller),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          Text(
            _t('ऐप सेटिंग', 'App settings'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(_t('भाषा', 'Language')),
                  subtitle: Text(controller.isHindi ? 'हिन्दी' : 'English'),
                  trailing: Switch(
                    value: controller.isHindi,
                    onChanged: (_) {
                      controller.toggleLanguage();
                      setState(() {});
                    },
                  ),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.dark_mode_outlined),
                  title: Text(_t('डार्क मोड', 'Dark mode')),
                  trailing: Switch(
                    value: controller.isDarkMode,
                    onChanged: (_) {
                      controller.toggleTheme();
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.shield_outlined),
                  title: Text(_t('गोपनीयता और डेटा', 'Privacy & Data')),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PrivacyScreen()),
                  ),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.info_outline_rounded),
                  title: Text(_t('Sambal के बारे में', 'About Sambal')),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AboutScreen()),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          Text(
            _t('सभी डेटा सिर्फ़ आपके फ़ोन पर रहता है।',
                'All data stays only on your phone.'),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> _editRelation(SambalController controller) async {
    final relations = [
      (_t('पिता', 'Father'), 'father'),
      (_t('माता', 'Mother'), 'mother'),
      (_t('पति / पत्नी', 'Spouse'), 'spouse'),
    ];

    final result = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _t('रिश्ता बदलें', 'Change relation'),
                style: Theme.of(ctx).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ...relations.map((r) => ListTile(
                    title: Text(r.$1),
                    selected: controller.data.relation == r.$2,
                    trailing: controller.data.relation == r.$2
                        ? const Icon(Icons.check_circle)
                        : null,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    onTap: () => Navigator.pop(ctx, r.$2),
                  )),
            ],
          ),
        ),
      ),
    );

    if (result != null && mounted) {
      controller.saveSetup(
        relation: result,
        onBehalf: controller.data.onBehalf,
        deathDate: controller.data.deathDate,
        state: controller.data.state,
        district: controller.data.district,
        circumstance: controller.data.circumstance,
        rites: controller.data.rites,
      );
      setState(() {});
    }
  }

  Future<void> _editDeathDate(SambalController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: controller.data.deathDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null && mounted) {
      controller.saveSetup(
        relation: controller.data.relation,
        onBehalf: controller.data.onBehalf,
        deathDate: picked,
        state: controller.data.state,
        district: controller.data.district,
        circumstance: controller.data.circumstance,
        rites: controller.data.rites,
      );
      setState(() {});
    }
  }

  Future<void> _editLocation(SambalController controller) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const LocationSetupScreen()),
    );
    if (saved == true && mounted) setState(() {});
  }

  Future<void> _editCircumstance(SambalController controller) async {
    final circumstances = [
      (_t('अस्पताल', 'Hospital'), 'hospital'),
      (_t('घर', 'Home'), 'home'),
      (_t('दुर्घटना', 'Accident'), 'accident'),
    ];

    final result = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _t('परिस्थिति बदलें', 'Change circumstance'),
                style: Theme.of(ctx).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ...circumstances.map((c) => ListTile(
                    title: Text(c.$1),
                    selected: controller.data.circumstance == c.$2,
                    trailing: controller.data.circumstance == c.$2
                        ? const Icon(Icons.check_circle)
                        : null,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    onTap: () => Navigator.pop(ctx, c.$2),
                  )),
            ],
          ),
        ),
      ),
    );

    if (result != null && mounted) {
      controller.saveSetup(
        relation: controller.data.relation,
        onBehalf: controller.data.onBehalf,
        deathDate: controller.data.deathDate,
        state: controller.data.state,
        district: controller.data.district,
        circumstance: result,
        rites: controller.data.rites,
      );
      setState(() {});
    }
  }
}

class _EditTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _EditTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(value),
      trailing: const Icon(Icons.edit_outlined, size: 20),
      onTap: onTap,
    );
  }
}
