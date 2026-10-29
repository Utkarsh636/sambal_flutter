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
            _t('प्रोफ़ाइल', 'Profile'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                _EditTile(
                  icon: Icons.person_outline,
                  label: _t('नाम', 'Name'),
                  value: data.name.isNotEmpty
                      ? data.name
                      : _t('सेट नहीं', 'Not set'),
                  onTap: () => _editName(controller),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
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
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: Text(_t('PIN लॉक', 'PIN lock')),
                  subtitle: Text(controller.hasPin
                      ? _t('चालू', 'Enabled')
                      : _t('बंद', 'Disabled')),
                  trailing: Switch(
                    value: controller.hasPin,
                    onChanged: (_) => _togglePin(controller),
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

  Future<void> _editName(SambalController controller) async {
    final nameController = TextEditingController(text: controller.data.name);
    final result = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _t('नाम बदलें', 'Change name'),
              style: Theme.of(ctx).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              textCapitalization: TextCapitalization.words,
              autofocus: true,
              decoration: InputDecoration(
                labelText: _t('पूरा नाम', 'Full name'),
                prefixIcon: const Icon(Icons.person_outline),
              ),
              onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () =>
                    Navigator.pop(ctx, nameController.text.trim()),
                child: Text(_t('सहेजें', 'Save')),
              ),
            ),
          ],
        ),
      ),
    );
    nameController.dispose();
    if (result != null && result.isNotEmpty && mounted) {
      controller.saveSetup(
        name: result,
        relation: controller.data.relation,
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

  Future<void> _togglePin(SambalController controller) async {
    if (controller.hasPin) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(_t('PIN हटाएँ?', 'Remove PIN?')),
          content: Text(_t(
            'ऐप लॉक बंद हो जाएगा।',
            'App lock will be disabled.',
          )),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(_t('नहीं', 'Cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(_t('हटाएँ', 'Remove')),
            ),
          ],
        ),
      );
      if (confirm == true) {
        controller.removePin();
        if (mounted) setState(() {});
      }
    } else {
      final pinController = TextEditingController();
      final confirmController = TextEditingController();
      final result = await showModalBottomSheet<String>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (ctx) => _PinSetupSheet(
          pinController: pinController,
          confirmController: confirmController,
          t: _t,
        ),
      );
      pinController.dispose();
      confirmController.dispose();
      if (result != null && result.length == 4) {
        controller.setPin(result);
        if (mounted) setState(() {});
      }
    }
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

class _PinSetupSheet extends StatefulWidget {
  final TextEditingController pinController;
  final TextEditingController confirmController;
  final String Function(String, String) t;

  const _PinSetupSheet({
    required this.pinController,
    required this.confirmController,
    required this.t,
  });

  @override
  State<_PinSetupSheet> createState() => _PinSetupSheetState();
}

class _PinSetupSheetState extends State<_PinSetupSheet> {
  String? _error;

  void _submit() {
    final pin = widget.pinController.text;
    final confirm = widget.confirmController.text;
    if (pin.length != 4) {
      setState(() => _error = widget.t('4 अंक डालें', 'Enter 4 digits'));
      return;
    }
    if (pin != confirm) {
      setState(() =>
          _error = widget.t('PIN मेल नहीं खाता', 'PINs do not match'));
      return;
    }
    Navigator.pop(context, pin);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.t('PIN बनाएँ', 'Create PIN'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: widget.pinController,
            keyboardType: TextInputType.number,
            maxLength: 4,
            obscureText: true,
            autofocus: true,
            decoration: InputDecoration(
              labelText: widget.t('4 अंकों का PIN', '4-digit PIN'),
              prefixIcon: const Icon(Icons.lock_outline),
              counterText: '',
            ),
            onChanged: (_) => setState(() => _error = null),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: widget.confirmController,
            keyboardType: TextInputType.number,
            maxLength: 4,
            obscureText: true,
            decoration: InputDecoration(
              labelText: widget.t('PIN दोबारा डालें', 'Confirm PIN'),
              prefixIcon: const Icon(Icons.lock_outline),
              counterText: '',
              errorText: _error,
            ),
            onChanged: (_) => setState(() => _error = null),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _submit,
              child: Text(widget.t('सहेजें', 'Save')),
            ),
          ),
        ],
      ),
    );
  }
}
