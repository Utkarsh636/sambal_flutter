import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../core/config/api_config.dart';
import 'case_controller.dart';

class LocationSetupScreen extends StatefulWidget {
  const LocationSetupScreen({super.key});

  @override
  State<LocationSetupScreen> createState() => _LocationSetupScreenState();
}

class _LocationSetupScreenState extends State<LocationSetupScreen> {
  bool _started = false;
  bool _loading = true;
  String? _error;

  List<_StateOption> _states = [];
  List<_DistrictOption> _districts = [];

  String? _selectedState;
  String? _selectedDistrict;

  bool get _isHindi => SambalScope.of(context).isHindi;

  String _t(String hi, String en) => _isHindi ? hi : en;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_started) {
      _started = true;
      _loadInitialData();
    }
  }

  Future<void> _loadInitialData() async {
    final existing = SambalScope.of(context).data;

    try {
      final uri = Uri.http(ApiConfig.host, "/certificate/coverage");
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception("Could not load state coverage.");
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final rawStates = body["states"] as List? ?? const [];

      final states = rawStates
          .whereType<Map>()
          .map(
            (item) => _StateOption(
              id: item["id"]?.toString() ?? "",
              name: item["name"]?.toString() ?? "",
            ),
          )
          .where((item) => item.id.isNotEmpty && item.name.isNotEmpty)
          .toList();

      if (!mounted) return;

      setState(() {
        _states = states;
        _selectedState = states
            .where((state) => state.name == existing.state)
            .map((state) => state.name)
            .firstOrNull;
      });

      if (_selectedState != null) {
        await _loadDistricts(existing.district);
      }

      if (!mounted) return;

      setState(() => _loading = false);
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = _t(
          "राज्य सूची लोड नहीं हो सकी। API और इंटरनेट जाँचें।",
          "Could not load state list. Check the API and your internet.",
        );
      });
    }
  }

  Future<void> _loadDistricts([String existingDistrict = ""]) async {
    final state = _selectedState;

    if (state == null) return;

    setState(() {
      _districts = [];
      _selectedDistrict = null;
    });

    try {
      final uri = Uri.http(
        ApiConfig.host,
        "/certificate/districts",
        {"state": state},
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception("Could not load districts.");
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final rawDistricts = body["districts"] as List? ?? const [];

      final districts = rawDistricts
          .whereType<Map>()
          .map(
            (item) => _DistrictOption(
              name: item["name"]?.toString() ?? "",
              lgdCode: item["lgdCode"]?.toString() ?? "",
            ),
          )
          .where((item) => item.name.isNotEmpty)
          .toList();

      if (!mounted) return;

      setState(() {
        _districts = districts;
        _selectedDistrict = districts
            .where((district) => district.name == existingDistrict)
            .map((district) => district.name)
            .firstOrNull;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _error = _t(
          "जिला सूची लोड नहीं हो सकी।",
          "Could not load district list.",
        );
      });
    }
  }

  void _saveLocation() {
    final state = _selectedState;
    final district = _selectedDistrict;

    if (state == null || district == null) return;

    final controller = SambalScope.of(context);
    final oldData = controller.data;

    controller.saveSetup(
      relation: oldData.relation,
      onBehalf: oldData.onBehalf,
      deathDate: oldData.deathDate,
      state: state,
      district: district,
      circumstance: oldData.circumstance,
      rites: oldData.rites,
    );

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_t("स्थान चुनें", "Choose location")),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _error != null && _states.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_error!),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () {
                        setState(() {
                          _loading = true;
                          _error = null;
                        });
                        _loadInitialData();
                      },
                      child: Text(_t("फिर से कोशिश करें", "Try again")),
                    ),
                  ],
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(_t(
                    "Sambal केवल आधिकारिक जिला सूची में मौजूद स्थान चुनने देता है।",
                    "Sambal only allows selecting locations from the official district directory.",
                  )),
                  const SizedBox(height: 24),
                  DropdownButtonFormField<String>(
                    key: ValueKey("state-$_selectedState"),
                    initialValue: _selectedState,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: _t("राज्य", "State"),
                    ),
                    items: _states
                        .map(
                          (state) => DropdownMenuItem(
                            value: state.name,
                            child: Text(state.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;

                      setState(() {
                        _selectedState = value;
                        _selectedDistrict = null;
                        _error = null;
                      });

                      _loadDistricts();
                    },
                  ),
                  const SizedBox(height: 18),
                  DropdownButtonFormField<String>(
                    key: ValueKey("district-$_selectedDistrict"),
                    initialValue: _selectedDistrict,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: _t("जिला", "District"),
                    ),
                    items: _districts
                        .map(
                          (district) => DropdownMenuItem(
                            value: district.name,
                            child: Text(district.name),
                          ),
                        )
                        .toList(),
                    onChanged: _districts.isEmpty
                        ? null
                        : (value) {
                            setState(() => _selectedDistrict = value);
                          },
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  const Spacer(),
                  FilledButton.icon(
                    onPressed:
                        _selectedState != null && _selectedDistrict != null
                            ? _saveLocation
                            : null,
                    icon: const Icon(Icons.verified_outlined),
                    label: Text(_t("स्थान सुरक्षित करें", "Save location")),
                  ),
                ],
              ),
      ),
    );
  }
}

class _StateOption {
  final String id;
  final String name;

  const _StateOption({
    required this.id,
    required this.name,
  });
}

class _DistrictOption {
  final String name;
  final String lgdCode;

  const _DistrictOption({
    required this.name,
    required this.lgdCode,
  });
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
