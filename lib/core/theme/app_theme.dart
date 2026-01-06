import 'package:flutter/material.dart';

/// Modern, vibrant app theme configuration
class AppTheme {
  // DARK MODE COLORS - Deep, rich, energizing
  static const Color backgroundDark = Color(0xFF0F0F1E);
  static const Color cardDark = Color(0xFF1C1C2E);
  static const Color surfaceDark = Color(0xFF252538);

  // LIGHT MODE COLORS - Clean, bright, fresh
  static const Color backgroundLight = Color(0xFFF8F9FE);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF1F3F9);

  // ACCENT COLORS - Vibrant and motivating
  static const Color primaryPurple = Color(0xFF7C3AED);
  static const Color primaryBlue = Color(0xFF3B82F6);
  static const Color successGreen = Color(0xFF10B981);
  static const Color energyOrange = Color(0xFFFF6B35);
  static const Color focusIndigo = Color(0xFF6366F1);
  static const Color streakFire = Color(0xFFEF4444);

  // GRADIENT COLORS
  static const List<Color> purpleGradient = [
    Color(0xFF7C3AED),
    Color(0xFF9333EA),
  ];

  static const List<Color> blueGradient = [
    Color(0xFF3B82F6),
    Color(0xFF2563EB),
  ];

  static const List<Color> greenGradient = [
    Color(0xFF10B981),
    Color(0xFF059669),
  ];

  static const List<Color> orangeGradient = [
    Color(0xFFFF6B35),
    Color(0xFFF59E0B),
  ];

  // TEXT COLORS
  static const Color textDark = Color(0xFFF9FAFB);
  static const Color textSecondaryDark = Color(0xFFD1D5DB);
  static const Color textLight = Color(0xFF1F2937);
  static const Color textSecondaryLight = Color(0xFF6B7280);

  // Modern gradient card with elevation
  static BoxDecoration gradientCard({
    required List<Color> colors,
    double borderRadius = 24,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: colors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: colors.first.withOpacity(0.3),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  // Elevated card with soft shadow
  static BoxDecoration elevatedCard(BuildContext context, {Color? color}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: color ?? (isDark ? cardDark : cardLight),
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: isDark
              ? Colors.black.withOpacity(0.3)
              : Colors.black.withOpacity(0.08),
          blurRadius: isDark ? 30 : 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  // DARK THEME - Modern, vibrant, energizing
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: backgroundDark,
    primaryColor: primaryPurple,

    colorScheme: const ColorScheme.dark(
      primary: primaryPurple,
      secondary: focusIndigo,
      tertiary: successGreen,
      surface: cardDark,
      background: backgroundDark,
      error: streakFire,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textDark,
      onBackground: textDark,
    ),

    // App Bar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: textDark,
        letterSpacing: 0.5,
      ),
      iconTheme: IconThemeData(color: textDark),
    ),

    // Text Theme
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 56,
        fontWeight: FontWeight.w900,
        color: textDark,
        letterSpacing: -2,
        height: 1.1,
      ),
      displayMedium: TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.w800,
        color: textDark,
        letterSpacing: -1,
      ),
      displaySmall: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: textDark,
        letterSpacing: -0.5,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: textDark,
      ),
      headlineSmall: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textDark,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textDark,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textDark,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textSecondaryDark,
        height: 1.5,
      ),
      labelLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textDark,
        letterSpacing: 0.5,
      ),
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      color: cardDark,
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryPurple, width: 2),
      ),
      contentPadding: const EdgeInsets.all(20),
      hintStyle: TextStyle(
        color: textSecondaryDark.withOpacity(0.6),
      ),
    ),

    // Icon Theme
    iconTheme: const IconThemeData(
      color: textDark,
      size: 24,
    ),
  );

  // LIGHT THEME - Clean, bright, fresh
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: backgroundLight,
    primaryColor: primaryPurple,

    colorScheme: const ColorScheme.light(
      primary: primaryPurple,
      secondary: focusIndigo,
      tertiary: successGreen,
      surface: cardLight,
      background: backgroundLight,
      error: streakFire,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textLight,
      onBackground: textLight,
    ),

    // App Bar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: textLight,
        letterSpacing: 0.5,
      ),
      iconTheme: IconThemeData(color: textLight),
    ),

    // Text Theme
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 56,
        fontWeight: FontWeight.w900,
        color: textLight,
        letterSpacing: -2,
        height: 1.1,
      ),
      displayMedium: TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.w800,
        color: textLight,
        letterSpacing: -1,
      ),
      displaySmall: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: textLight,
        letterSpacing: -0.5,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: textLight,
      ),
      headlineSmall: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textLight,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textLight,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textLight,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textSecondaryLight,
        height: 1.5,
      ),
      labelLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textLight,
        letterSpacing: 0.5,
      ),
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      color: cardLight,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryPurple, width: 2),
      ),
      contentPadding: const EdgeInsets.all(20),
      hintStyle: TextStyle(
        color: textSecondaryLight.withOpacity(0.6),
      ),
    ),

    // Icon Theme
    iconTheme: const IconThemeData(
      color: textLight,
      size: 24,
    ),
  );
}

