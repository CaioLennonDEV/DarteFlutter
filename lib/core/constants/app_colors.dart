import 'package:flutter/material.dart';

class AppColors {
  // Apple iOS System Palette
  static const Color iosYellow = Color(0xFFD97706); // Apple Notes Gold/Amber
  static const Color iosIndigo = Color(0xFF5856D6); // iOS Indigo
  static const Color iosBlue = Color(0xFF007AFF);   // iOS System Blue
  static const Color iosGreen = Color(0xFF34C759);  // iOS System Green
  static const Color iosRed = Color(0xFFFF3B30);    // iOS System Red
  static const Color iosOrange = Color(0xFFFF9500); // iOS System Orange
  static const Color iosPurple = Color(0xFFAF52DE); // iOS System Purple
  static const Color iosTeal = Color(0xFF5AC8FA);   // iOS System Teal

  // Primary Brand Color
  static const Color primary = Color(0xFFD97706); // Apple Notes Amber Accent
  static const Color primaryLight = Color(0xFFF59E0B);
  static const Color primaryDark = Color(0xFFB45309);
  static const Color secondary = Color(0xFF5856D6);
  static const Color accent = Color(0xFF007AFF);

  // iOS Light Theme Tokens
  static const Color lightBg = Color(0xFFF2F2F7);       // iOS Grouped Background
  static const Color lightSurface = Color(0xFFFFFFFF);  // Pure White Card
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE5E5EA);   // iOS System Separator
  static const Color lightTextPrimary = Color(0xFF000000);
  static const Color lightTextSecondary = Color(0xFF8E8E93); // iOS System Gray

  // iOS Dark Theme Tokens
  static const Color darkBg = Color(0xFF000000);        // True Black OLED
  static const Color darkSurface = Color(0xFF1C1C1E);   // iOS Dark Grouped Card
  static const Color darkCard = Color(0xFF1C1C1E);
  static const Color darkBorder = Color(0xFF38383A);    // iOS Dark Separator
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFF8E8E93);

  // Feedback
  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFFF9500);
  static const Color error = Color(0xFFFF3B30);

  // Subtle iOS Pastel Note Backgrounds (Indices 0 to 7)
  static const List<Color> noteColorsLight = [
    Color(0xFFFFFFFF), // 0: White
    Color(0xFFFEF9C3), // 1: Warm Yellow
    Color(0xFFDCFCE7), // 2: Mint Green
    Color(0xFFE0E7FF), // 3: Soft Lavender
    Color(0xFFFCE7F3), // 4: Soft Rose
    Color(0xFFEDE9FE), // 5: Soft Lilac
    Color(0xFFE0F2FE), // 6: Soft Sky
    Color(0xFFFFEDD5), // 7: Soft Peach
  ];

  static const List<Color> noteColorsDark = [
    Color(0xFF1C1C1E), // 0: iOS Dark Gray
    Color(0xFF2E2413), // 1: Dark Amber
    Color(0xFF132B1F), // 2: Dark Mint
    Color(0xFF1B1F38), // 3: Dark Lavender
    Color(0xFF331622), // 4: Dark Rose
    Color(0xFF25163D), // 5: Dark Lilac
    Color(0xFF10283B), // 6: Dark Sky
    Color(0xFF331F14), // 7: Dark Peach
  ];
}
