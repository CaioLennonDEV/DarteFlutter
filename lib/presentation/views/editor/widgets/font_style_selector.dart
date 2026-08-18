import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

class FontStyleSelector {
  static const List<String> fontFamilies = [
    'Inter',
    'Playfair Display',
    'Fira Code',
    'Caveat',
    'Roboto',
  ];

  static TextStyle getTextStyle({
    String? fontFamily,
    double? fontSize,
    required Color color,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    final size = fontSize ?? 15.5;
    final font = fontFamily ?? 'Inter';

    try {
      switch (font) {
        case 'Playfair Display':
          return GoogleFonts.playfairDisplay(
            fontSize: size,
            color: color,
            fontWeight: fontWeight,
          );
        case 'Fira Code':
          return GoogleFonts.firaCode(
            fontSize: size,
            color: color,
            fontWeight: fontWeight,
          );
        case 'Caveat':
          return GoogleFonts.caveat(
            fontSize: size + 4,
            color: color,
            fontWeight: fontWeight,
          );
        case 'Roboto':
          return GoogleFonts.roboto(
            fontSize: size,
            color: color,
            fontWeight: fontWeight,
          );
        case 'Inter':
        default:
          return GoogleFonts.inter(
            fontSize: size,
            color: color,
            fontWeight: fontWeight,
          );
      }
    } catch (_) {
      return TextStyle(
        fontSize: size,
        color: color,
        fontWeight: fontWeight,
      );
    }
  }

  static void show(
    BuildContext context, {
    required String currentFontFamily,
    required double currentFontSize,
    required ValueChanged<String> onFontChanged,
    required ValueChanged<double> onSizeChanged,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;

          return Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Tipografia & Estilo',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Font Family Selector
                const Text(
                  'FONTE DO TEXTO',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: fontFamilies.map((font) {
                    final isSelected = currentFontFamily == font;
                    return ChoiceChip(
                      label: Text(
                        font,
                        style: getTextStyle(
                          fontFamily: font,
                          fontSize: 13,
                          color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black),
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      onSelected: (selected) {
                        if (selected) {
                          setModalState(() {});
                          onFontChanged(font);
                        }
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),

                // Font Size Selector
                const Text(
                  'TAMANHO DA FONTE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('A', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Slider(
                        value: currentFontSize,
                        min: 13.0,
                        max: 22.0,
                        divisions: 9,
                        activeColor: AppColors.primary,
                        label: '${currentFontSize.toInt()}px',
                        onChanged: (val) {
                          setModalState(() {});
                          onSizeChanged(val);
                        },
                      ),
                    ),
                    const Text('A', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  ],
                ),

                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}
