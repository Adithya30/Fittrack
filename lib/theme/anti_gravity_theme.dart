import 'package:flutter/material.dart';

class AntiGravityTheme {
  // Black & White Color Palette
  static const Color pureBlack = Color(0xFF000000);
  static const Color deepBlack = Color(0xFF0A0A0A);
  static const Color darkGray = Color(0xFF1A1A1A);
  static const Color mediumGray = Color(0xFF2A2A2A);
  static const Color lightGray = Color(0xFF3A3A3A);
  static const Color offWhite = Color(0xFFF5F5F5);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color accentWhite = Color(0xFFE0E0E0);

  // Glassmorphism colors
  static Color glassBackground = Colors.white.withOpacity(0.1);
  static Color glassBorder = Colors.white.withOpacity(0.2);

  // Gradient colors for mesh
  static const List<Color> meshColors = [
    Color(0xFF000000),
    Color(0xFF1A1A1A),
    Color(0xFF2A2A2A),
    Color(0xFF000000),
  ];

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: pureBlack,
      colorScheme: const ColorScheme.dark(
        primary: pureWhite,
        secondary: accentWhite,
        surface: darkGray,
        background: pureBlack,
        error: Colors.red,
        onPrimary: pureBlack,
        onSecondary: pureBlack,
        onSurface: pureWhite,
        onBackground: pureWhite,
        onError: pureWhite,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: pureWhite),
        titleTextStyle: TextStyle(
          color: pureWhite,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: darkGray.withOpacity(0.5),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: pureWhite.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkGray.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: pureWhite.withOpacity(0.2),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: pureWhite.withOpacity(0.2),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: pureWhite,
            width: 2,
          ),
        ),
        labelStyle: const TextStyle(color: accentWhite),
        hintStyle: TextStyle(color: accentWhite.withOpacity(0.5)),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: pureWhite,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
        displayMedium: TextStyle(
          color: pureWhite,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
        displaySmall: TextStyle(
          color: pureWhite,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.0,
        ),
        headlineMedium: TextStyle(
          color: pureWhite,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: pureWhite,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: accentWhite,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: accentWhite,
          fontSize: 14,
        ),
        bodySmall: TextStyle(
          color: accentWhite,
          fontSize: 12,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: pureWhite.withOpacity(0.1),
          foregroundColor: pureWhite,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: pureWhite.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
      iconTheme: const IconThemeData(
        color: pureWhite,
        size: 24,
      ),
    );
  }

  // Mesh gradient widget for background
  static Widget meshGradientBackground({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: meshColors,
        ),
      ),
      child: child,
    );
  }

  // Glassmorphic container helper
  static BoxDecoration glassmorphicDecoration({
    double opacity = 0.1,
    double borderOpacity = 0.2,
    double borderRadius = 20,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      color: pureWhite.withOpacity(opacity),
      border: Border.all(
        color: pureWhite.withOpacity(borderOpacity),
        width: 1.5,
      ),
    );
  }
}
