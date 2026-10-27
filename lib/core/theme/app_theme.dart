import 'package:flutter/material.dart';

class AppTheme {
  // Light theme: Cosmic Latte, Mocha Cream, Deep Burgundy.
  static const cosmicLatte = Color(0xFFFFF8E7);
  static const mochaCream = Color(0xFFD6B38C);
  static const deepBurgundy = Color(0xFF5A1D2C);
  static const richBurgundy = Color(0xFF3E0F1C);
  static const warmInk = Color(0xFF3D2127);

  // Dark theme: Jet Black, Cerulean Blue, Neon Rose.
  static const jetBlack = Color(0xFF0A0A0A);
  static const darkSurface = Color(0xFF14161C);
  static const darkRaised = Color(0xFF1E2028);
  static const ceruleanBlue = Color(0xFF0090C4);
  static const neonRose = Color(0xFFFF3D9A);
  static const softWhite = Color(0xFFF2F4F8);
  static const mutedSlate = Color(0xFFAEB7C4);

  static const successLight = Color(0xFF2E7D32);
  static const successDark = Color(0xFF66BB6A);

  static Color success(Brightness brightness) =>
      brightness == Brightness.dark ? successDark : successLight;

  static final lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: deepBurgundy,
      onPrimary: cosmicLatte,
      primaryContainer: Color(0xFFEDD5B8),
      onPrimaryContainer: richBurgundy,
      secondary: mochaCream,
      onSecondary: richBurgundy,
      secondaryContainer: Color(0xFFF5E6D0),
      onSecondaryContainer: richBurgundy,
      surface: cosmicLatte,
      onSurface: warmInk,
      surfaceContainerHighest: Color(0xFFFFF3DA),
      error: Color(0xFFB42318),
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: cosmicLatte,
    appBarTheme: const AppBarTheme(
      backgroundColor: cosmicLatte,
      foregroundColor: deepBurgundy,
      elevation: 0,
      centerTitle: false,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFFFFFDF8),
      elevation: 0,
      shadowColor: deepBurgundy.withValues(alpha: 0.14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: mochaCream.withValues(alpha: 0.55),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFFFFDF8),
      labelStyle: const TextStyle(color: warmInk),
      hintStyle: TextStyle(color: warmInk.withValues(alpha: 0.5)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: mochaCream.withValues(alpha: 0.7),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: mochaCream.withValues(alpha: 0.7),
        ),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
        borderSide: BorderSide(color: deepBurgundy, width: 2),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: deepBurgundy,
        foregroundColor: cosmicLatte,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: deepBurgundy,
        foregroundColor: cosmicLatte,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: deepBurgundy,
        side: BorderSide(color: deepBurgundy.withValues(alpha: 0.5)),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: Color(0xFFFFFDF8),
      indicatorColor: Color(0xFFEDD5B8),
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFFFFF3DA),
      selectedColor: mochaCream,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: richBurgundy,
      contentTextStyle: const TextStyle(color: cosmicLatte),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      behavior: SnackBarBehavior.floating,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    textTheme: const TextTheme(
      headlineSmall: TextStyle(
        color: richBurgundy,
        fontWeight: FontWeight.w800,
      ),
      titleLarge: TextStyle(
        color: deepBurgundy,
        fontWeight: FontWeight.w800,
      ),
      titleMedium: TextStyle(
        color: deepBurgundy,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: TextStyle(color: warmInk),
      bodyMedium: TextStyle(color: warmInk),
    ),
  );

  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: ceruleanBlue,
      onPrimary: Color(0xFF001E2D),
      primaryContainer: Color(0xFF003E55),
      onPrimaryContainer: Color(0xFFC9F1FF),
      secondary: neonRose,
      onSecondary: jetBlack,
      secondaryContainer: Color(0xFF5D123D),
      onSecondaryContainer: Color(0xFFFFD8EA),
      surface: jetBlack,
      onSurface: softWhite,
      surfaceContainerHighest: darkRaised,
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
    ),
    scaffoldBackgroundColor: jetBlack,
    appBarTheme: const AppBarTheme(
      backgroundColor: jetBlack,
      foregroundColor: softWhite,
      elevation: 0,
      centerTitle: false,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      color: darkSurface,
      elevation: 0,
      shadowColor: ceruleanBlue.withValues(alpha: 0.12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: ceruleanBlue.withValues(alpha: 0.28),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkSurface,
      labelStyle: const TextStyle(color: mutedSlate),
      hintStyle: TextStyle(color: mutedSlate.withValues(alpha: 0.65)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: ceruleanBlue.withValues(alpha: 0.4),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: ceruleanBlue.withValues(alpha: 0.4),
        ),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
        borderSide: BorderSide(color: neonRose, width: 2),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ceruleanBlue,
        foregroundColor: softWhite,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: ceruleanBlue,
        foregroundColor: softWhite,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: ceruleanBlue,
        side: BorderSide(color: ceruleanBlue.withValues(alpha: 0.5)),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: darkSurface,
      indicatorColor: Color(0xFF003E55),
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(color: softWhite, fontWeight: FontWeight.w700),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: darkRaised,
      selectedColor: const Color(0xFF003E55),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF003E55),
      contentTextStyle: const TextStyle(color: softWhite),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      behavior: SnackBarBehavior.floating,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    textTheme: const TextTheme(
      headlineSmall: TextStyle(
        color: softWhite,
        fontWeight: FontWeight.w800,
      ),
      titleLarge: TextStyle(
        color: softWhite,
        fontWeight: FontWeight.w800,
      ),
      titleMedium: TextStyle(
        color: softWhite,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: TextStyle(color: softWhite),
      bodyMedium: TextStyle(color: mutedSlate),
    ),
  );
}
