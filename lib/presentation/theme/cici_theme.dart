import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design system completo do app Cici — visual dark premium estilo Alexa.
///
/// Define cores, tipografia, formas e temas (dark/light) para toda a
/// aplicação com glassmorphism e estética moderna.
class CiciTheme {
  CiciTheme._();

  // =========================================================================
  // PALETA DE CORES
  // =========================================================================

  // -- Fundos --
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color cardDark = Color(0xFF1E293B);
  static const Color cardElevated = Color(0xFF273548);

  // -- Acentos --
  static const Color primaryBlue = Color(0xFF3B82F6);
  static const Color primaryBlueLight = Color(0xFF60A5FA);
  static const Color accentCyan = Color(0xFF06B6D4);
  static const Color successGreen = Color(0xFF10B981);
  static const Color warningAmber = Color(0xFFF59E0B);
  static const Color dangerRed = Color(0xFFEF4444);
  static const Color purpleAccent = Color(0xFF8B5CF6);

  // -- Textos --
  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // -- Dispositivos (cores por tipo) --
  static const Color lampadaColor = Color(0xFFFBBF24);
  static const Color termostatoColor = Color(0xFFF97316);
  static const Color sensorColor = Color(0xFF06B6D4);

  // -- Glassmorphism --
  static const Color glassBorder = Color(0x33FFFFFF);
  static const Color glassBackground = Color(0x1AFFFFFF);

  // =========================================================================
  // BORDER RADIUS
  // =========================================================================

  static final BorderRadius radiusSm = BorderRadius.circular(8);
  static final BorderRadius radiusMd = BorderRadius.circular(12);
  static final BorderRadius radiusLg = BorderRadius.circular(16);
  static final BorderRadius radiusXl = BorderRadius.circular(20);
  static final BorderRadius radiusFull = BorderRadius.circular(100);

  // =========================================================================
  // SHADOWS
  // =========================================================================

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get glowShadow => [
        BoxShadow(
          color: primaryBlue.withOpacity(0.3),
          blurRadius: 20,
          spreadRadius: 2,
        ),
      ];

  // =========================================================================
  // DECORAÇÕES GLASSMORPHISM
  // =========================================================================

  static BoxDecoration get glassCard => BoxDecoration(
        color: glassBackground,
        borderRadius: radiusXl,
        border: Border.all(color: glassBorder, width: 1),
        boxShadow: cardShadow,
      );

  static BoxDecoration get solidCard => BoxDecoration(
        color: cardDark,
        borderRadius: radiusXl,
        border: Border.all(color: glassBorder, width: 0.5),
        boxShadow: cardShadow,
      );

  // =========================================================================
  // TIPOGRAFIA
  // =========================================================================

  static TextStyle get headingLg => GoogleFonts.outfit(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      );

  static TextStyle get headingMd => GoogleFonts.outfit(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      );

  static TextStyle get headingSm => GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      );

  static TextStyle get bodyLg => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textPrimary,
      );

  static TextStyle get bodyMd => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textSecondary,
      );

  static TextStyle get bodySm => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textMuted,
      );

  static TextStyle get labelBold => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: textSecondary,
        letterSpacing: 0.5,
      );

  static TextStyle get numberLg => GoogleFonts.outfit(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      );

  // =========================================================================
  // TEMA COMPLETO
  // =========================================================================

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: backgroundDark,
        colorScheme: const ColorScheme.dark(
          primary: primaryBlue,
          secondary: accentCyan,
          surface: surfaceDark,
          error: dangerRed,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: backgroundDark,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: headingMd,
          iconTheme: const IconThemeData(color: textPrimary),
        ),
        cardTheme: CardThemeData(
          color: cardDark,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: radiusXl),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: radiusLg),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: surfaceDark,
          selectedColor: primaryBlue,
          labelStyle: GoogleFonts.inter(fontSize: 13, color: textSecondary),
          shape: RoundedRectangleBorder(borderRadius: radiusFull),
          side: const BorderSide(color: glassBorder),
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor: primaryBlue,
          inactiveTrackColor: surfaceDark,
          thumbColor: primaryBlueLight,
          overlayColor: primaryBlue.withOpacity(0.2),
          trackHeight: 6,
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return successGreen;
            return textMuted;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return successGreen.withOpacity(0.4);
            }
            return surfaceDark;
          }),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: cardElevated,
          contentTextStyle: GoogleFonts.inter(color: textPrimary, fontSize: 14),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: radiusMd),
        ),
      );
}
