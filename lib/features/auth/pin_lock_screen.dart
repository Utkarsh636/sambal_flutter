import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../case/case_controller.dart';

class PinLockScreen extends StatefulWidget {
  final VoidCallback onUnlocked;

  const PinLockScreen({super.key, required this.onUnlocked});

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen>
    with SingleTickerProviderStateMixin {
  final _digits = <int>[];
  String? _error;
  int _attempts = 0;
  late final AnimationController _shakeController;

  String _t(String hi, String en) =>
      SambalScope.of(context).isHindi ? hi : en;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _addDigit(int digit) {
    if (_digits.length >= 4) return;
    HapticFeedback.lightImpact();
    setState(() {
      _digits.add(digit);
      _error = null;
    });

    if (_digits.length == 4) {
      _verify();
    }
  }

  void _removeDigit() {
    if (_digits.isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() {
      _digits.removeLast();
      _error = null;
    });
  }

  void _verify() {
    final pin = _digits.join();
    final controller = SambalScope.of(context);
    if (controller.verifyPin(pin)) {
      widget.onUnlocked();
    } else {
      _attempts++;
      _shakeController.forward(from: 0);
      HapticFeedback.heavyImpact();
      setState(() {
        _digits.clear();
        _error = _attempts >= 5
            ? _t('बहुत प्रयास — थोड़ी देर बाद कोशिश करें',
                'Too many attempts — try again later')
            : _t('गलत PIN', 'Incorrect PIN');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final controller = SambalScope.of(context);
    final name = controller.data.name;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            Icon(Icons.lock_rounded, size: 48, color: colors.primary),
            const SizedBox(height: 16),
            Text(
              name.isNotEmpty
                  ? _t('नमस्ते, $name', 'Hello, $name')
                  : _t('नमस्ते', 'Hello'),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _t('अपना PIN डालें', 'Enter your PIN'),
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 28),
            AnimatedBuilder(
              animation: _shakeController,
              builder: (context, child) {
                final shake = _shakeController.isAnimating
                    ? 12.0 *
                        (1 - _shakeController.value) *
                        (((_shakeController.value * 8).toInt() % 2 == 0)
                            ? 1
                            : -1)
                    : 0.0;
                return Transform.translate(
                  offset: Offset(shake, 0),
                  child: child,
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) {
                  final filled = i < _digits.length;
                  return Container(
                    width: 18,
                    height: 18,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: filled ? colors.primary : Colors.transparent,
                      border: Border.all(
                        color: _error != null
                            ? colors.error
                            : colors.primary,
                        width: 2,
                      ),
                    ),
                  );
                }),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: TextStyle(color: colors.error, fontSize: 13),
              ),
            ],
            const Spacer(),
            _buildKeypad(colors),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypad(ColorScheme colors) {
    Widget key(String label, {VoidCallback? onTap, Widget? child}) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(40),
              onTap: _attempts >= 5 ? null : onTap,
              child: Container(
                height: 64,
                alignment: Alignment.center,
                child: child ??
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w500,
                        color: colors.onSurface,
                      ),
                    ),
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          Row(children: [
            key('1', onTap: () => _addDigit(1)),
            key('2', onTap: () => _addDigit(2)),
            key('3', onTap: () => _addDigit(3)),
          ]),
          Row(children: [
            key('4', onTap: () => _addDigit(4)),
            key('5', onTap: () => _addDigit(5)),
            key('6', onTap: () => _addDigit(6)),
          ]),
          Row(children: [
            key('7', onTap: () => _addDigit(7)),
            key('8', onTap: () => _addDigit(8)),
            key('9', onTap: () => _addDigit(9)),
          ]),
          Row(children: [
            key('', onTap: null),
            key('0', onTap: () => _addDigit(0)),
            key('',
                onTap: _removeDigit,
                child: Icon(Icons.backspace_outlined,
                    color: colors.onSurfaceVariant)),
          ]),
        ],
      ),
    );
  }
}
