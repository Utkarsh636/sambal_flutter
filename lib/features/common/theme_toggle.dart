import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

import '../case/case_controller.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = SambalScope.of(context);
    final isDark = controller.isDarkMode;
    final colors = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark
            ? AppTheme.darkRaised
            : AppTheme.mochaCream.withValues(alpha: 0.35),
        border: Border.all(
          color: isDark
              ? AppTheme.ceruleanBlue.withValues(alpha: 0.65)
              : AppTheme.mochaCream,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? AppTheme.neonRose : AppTheme.deepBurgundy)
                .withValues(alpha: 0.16),
            blurRadius: 14,
            spreadRadius: 1,
          ),
        ],
      ),
      child: IconButton(
        tooltip: isDark ? 'Use light theme' : 'Use dark theme',
        onPressed: controller.toggleTheme,
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            key: ValueKey(isDark),
            color: isDark ? AppTheme.neonRose : colors.primary,
          ),
        ),
      ),
    );
  }
}