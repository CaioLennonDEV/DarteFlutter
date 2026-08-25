import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

class AppTheme {
  static const String defaultFontFamily = '-apple-system';
  static const List<String> defaultFontFamilyFallback = [
    'BlinkMacSystemFont',
    'SF Pro Text',
    'SF Pro Display',
    'Segoe UI',
    'Roboto',
    'Helvetica Neue',
    'Helvetica',
    'Arial',
    'sans-serif',
  ];

  // iOS Light Theme Configuration
  static ThemeData get lightTheme {
    const textTheme = TextTheme(
      displaySmall: TextStyle(
        fontWeight: FontWeight.w800,
        color: AppColors.lightTextPrimary,
        letterSpacing: -1.0,
        fontFamily: defaultFontFamily,
        fontFamilyFallback: defaultFontFamilyFallback,
      ),
      headlineMedium: TextStyle(
        fontWeight: FontWeight.bold,
        color: AppColors.lightTextPrimary,
        letterSpacing: -0.5,
        fontFamily: defaultFontFamily,
        fontFamilyFallback: defaultFontFamilyFallback,
      ),
      titleLarge: TextStyle(
        fontWeight: FontWeight.w700,
        color: AppColors.lightTextPrimary,
        letterSpacing: -0.3,
        fontFamily: defaultFontFamily,
        fontFamilyFallback: defaultFontFamilyFallback,
      ),
      titleMedium: TextStyle(
        fontWeight: FontWeight.w600,
        color: AppColors.lightTextPrimary,
        fontFamily: defaultFontFamily,
        fontFamilyFallback: defaultFontFamilyFallback,
      ),
      bodyLarge: TextStyle(
        color: AppColors.lightTextPrimary,
        fontSize: 16,
        fontFamily: defaultFontFamily,
        fontFamilyFallback: defaultFontFamilyFallback,
      ),
      bodyMedium: TextStyle(
        color: AppColors.lightTextSecondary,
        fontSize: 14,
        fontFamily: defaultFontFamily,
        fontFamilyFallback: defaultFontFamilyFallback,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: defaultFontFamily,
      fontFamilyFallback: defaultFontFamilyFallback,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.lightBg,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.secondary,
        onSecondary: Colors.white,
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightTextPrimary,
        error: AppColors.error,
        onError: Colors.white,
      ),
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: IconThemeData(color: AppColors.primary),
        titleTextStyle: TextStyle(
          color: AppColors.lightTextPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          fontFamily: defaultFontFamily,
          fontFamilyFallback: defaultFontFamilyFallback,
        ),
      ),
      cardTheme: CardTheme(
        color: AppColors.lightCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.lightBorder, width: 0.5),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFE5E5EA).withOpacity(0.7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: AppColors.primary, width: 1.0),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }

  // iOS Dark Theme Configuration
  static ThemeData get darkTheme {
    const textTheme = TextTheme(
      displaySmall: TextStyle(
        fontWeight: FontWeight.w800,
        color: AppColors.darkTextPrimary,
        letterSpacing: -1.0,
        fontFamily: defaultFontFamily,
        fontFamilyFallback: defaultFontFamilyFallback,
      ),
      headlineMedium: TextStyle(
        fontWeight: FontWeight.bold,
        color: AppColors.darkTextPrimary,
        letterSpacing: -0.5,
        fontFamily: defaultFontFamily,
        fontFamilyFallback: defaultFontFamilyFallback,
      ),
      titleLarge: TextStyle(
        fontWeight: FontWeight.w700,
        color: AppColors.darkTextPrimary,
        letterSpacing: -0.3,
        fontFamily: defaultFontFamily,
        fontFamilyFallback: defaultFontFamilyFallback,
      ),
      titleMedium: TextStyle(
        fontWeight: FontWeight.w600,
        color: AppColors.darkTextPrimary,
        fontFamily: defaultFontFamily,
        fontFamilyFallback: defaultFontFamilyFallback,
      ),
      bodyLarge: TextStyle(
        color: AppColors.darkTextPrimary,
        fontSize: 16,
        fontFamily: defaultFontFamily,
        fontFamilyFallback: defaultFontFamilyFallback,
      ),
      bodyMedium: TextStyle(
        color: AppColors.darkTextSecondary,
        fontSize: 14,
        fontFamily: defaultFontFamily,
        fontFamilyFallback: defaultFontFamilyFallback,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: defaultFontFamily,
      fontFamilyFallback: defaultFontFamilyFallback,
      primaryColor: AppColors.primaryLight,
      scaffoldBackgroundColor: AppColors.darkBg,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryLight,
        onPrimary: Colors.black,
        secondary: AppColors.secondary,
        onSecondary: Colors.white,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkTextPrimary,
        error: AppColors.error,
        onError: Colors.white,
      ),
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: IconThemeData(color: AppColors.primaryLight),
        titleTextStyle: TextStyle(
          color: AppColors.darkTextPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          fontFamily: defaultFontFamily,
          fontFamilyFallback: defaultFontFamilyFallback,
        ),
      ),
      cardTheme: CardTheme(
        color: AppColors.darkCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.darkBorder, width: 0.5),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2C2C2E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: AppColors.primaryLight, width: 1.0),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
}
