import 'package:flutter/material.dart';

enum AppThemeMode {
  light,
  dark,
  warm,
  midnight,
  highContrast,
}

extension AppThemeModeX on AppThemeMode {
  String get label {
    switch (this) {
      case AppThemeMode.light:
        return 'Hell';
      case AppThemeMode.dark:
        return 'Dunkel';
      case AppThemeMode.warm:
        return 'Warm';
      case AppThemeMode.midnight:
        return 'Mitternacht';
      case AppThemeMode.highContrast:
        return 'Hoher Kontrast';
    }
  }

  static AppThemeMode fromString(String? value) {
    switch (value) {
      case 'dark':
        return AppThemeMode.dark;
      case 'warm':
        return AppThemeMode.warm;
      case 'midnight':
        return AppThemeMode.midnight;
      case 'highContrast':
        return AppThemeMode.highContrast;
      default:
        return AppThemeMode.light;
    }
  }

  String get storageKey => name;
}

TextStyle sectionTitleStyle(BuildContext context) {
  final theme = Theme.of(context);
  return theme.textTheme.titleMedium!.copyWith(
    fontWeight: FontWeight.w600,
    color: theme.colorScheme.onSurface,
    letterSpacing: -0.2,
  );
}

TextStyle greetingStyle(BuildContext context) {
  final theme = Theme.of(context);
  return theme.textTheme.titleLarge!.copyWith(
    fontWeight: FontWeight.w600,
    color: theme.colorScheme.onSurface,
    letterSpacing: -0.3,
  );
}

class AppTheme {
  static ThemeData light() {
    const seedColor = Color(0xFF27AE60);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
      surface: const Color(0xFFF2F2F7),
    ).copyWith(
      surfaceContainerHighest: const Color(0xFFFFFFFF),
      surfaceContainerHigh: const Color(0xFFE5E5EA),
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      textTheme: _appleTextTheme(Brightness.light, colorScheme),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
          letterSpacing: -0.4,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 10),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 10),
      ),
    );
  }

  static ThemeData dark() {
    const seedColor = Color(0xFF27AE60);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
      surface: const Color(0xFF000000),
    ).copyWith(
      surfaceContainerHighest: const Color(0xFF2C2C2E),
      surfaceContainerHigh: const Color(0xFF3A3A3E),
      onSurfaceVariant: const Color(0xFFEBEBF5).withOpacity(0.6),
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFF000000),
      textTheme: _appleTextTheme(Brightness.dark, colorScheme),
      cardTheme: CardThemeData(
        color: const Color(0xFF2C2C2E),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
          letterSpacing: -0.4,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1C1C1E),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 10),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 10),
      ),
    );
  }

  static ThemeData warm() {
    const seedColor = Color(0xFFD4A574);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
      surface: const Color(0xFFF5F0E8),
    ).copyWith(
      surfaceContainerHighest: const Color(0xFFFFFBF5),
      surfaceContainerHigh: const Color(0xFFEDE6DC),
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFF5F0E8),
      textTheme: _appleTextTheme(Brightness.light, colorScheme),
      cardTheme: CardThemeData(
        color: const Color(0xFFFFFBF5),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
          letterSpacing: -0.4,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 10),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 10),
      ),
    );
  }

  static ThemeData midnight() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF64B5F6),
      brightness: Brightness.dark,
      surface: const Color(0xFF0D1B2A),
    ).copyWith(
      primary: const Color(0xFF64B5F6),
      onPrimary: const Color(0xFF0D1B2A),
      surface: const Color(0xFF0D1B2A),
      onSurface: const Color(0xFFE8EDF2),
      surfaceContainerHighest: const Color(0xFF1B2838),
      surfaceContainerHigh: const Color(0xFF243447),
      onSurfaceVariant: const Color(0xFFB0BEC5),
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFF0D1B2A),
      textTheme: _appleTextTheme(Brightness.dark, colorScheme),
      cardTheme: CardThemeData(
        color: const Color(0xFF1B2838),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
          letterSpacing: -0.4,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1B2838),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF0D1B2A),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 10),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 10),
      ),
    );
  }

  static ThemeData highContrast() {
    const black = Color(0xFF000000);
    const white = Color(0xFFFFFFFF);
    const green = Color(0xFF008000);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: green,
        onPrimary: white,
        secondary: green,
        onSecondary: white,
        surface: white,
        onSurface: black,
        surfaceContainerHighest: white,
        surfaceContainerHigh: Color(0xFFF0F0F0),
        onSurfaceVariant: black,
        error: Color(0xFFCC0000),
        onError: white,
        outline: black,
      ),
      scaffoldBackgroundColor: white,
      textTheme: const TextTheme(
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: black),
        titleMedium: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: black),
        bodyMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: black),
        bodySmall: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: black),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: white,
        foregroundColor: black,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: black, width: 4),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: black, width: 4),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: black, width: 4),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: green, width: 5),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: green,
        linearTrackColor: Color(0xFFE0E0E0),
      ),
    );
  }

  static TextTheme _appleTextTheme(Brightness brightness, ColorScheme colorScheme) {
    final onSurface = colorScheme.onSurface;
    final onSurfaceVariant = colorScheme.onSurfaceVariant;
    return TextTheme(
      headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: onSurface, letterSpacing: -0.5),
      titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: onSurface, letterSpacing: -0.4),
      titleMedium: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: onSurface, letterSpacing: -0.4),
      titleSmall: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: onSurface),
      bodyLarge: TextStyle(fontSize: 17, fontWeight: FontWeight.w400, color: onSurface),
      bodyMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: onSurface),
      bodySmall: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: onSurfaceVariant),
      labelLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: onSurface),
    );
  }

  static ThemeData themeFor(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return light();
      case AppThemeMode.dark:
        return dark();
      case AppThemeMode.warm:
        return warm();
      case AppThemeMode.midnight:
        return midnight();
      case AppThemeMode.highContrast:
        return highContrast();
    }
  }
}
