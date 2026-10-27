import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/case/case_controller.dart';
import 'features/onboarding/splash_screen.dart';

class SambalApp extends StatefulWidget {
  const SambalApp({super.key});

  @override
  State<SambalApp> createState() => _SambalAppState();
}

class _SambalAppState extends State<SambalApp> {
  late final SambalController _sambalController;

  @override
  void initState() {
    super.initState();
    _sambalController = SambalController();
  }

  @override
  void dispose() {
    _sambalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SambalScope(
      controller: _sambalController,
      child: AnimatedBuilder(
        animation: _sambalController,
        builder: (context, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Sambal — हर कदम पर साथ',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: _sambalController.isDarkMode
                ? ThemeMode.dark
                : ThemeMode.light,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}