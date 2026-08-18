import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ColorPickerPalette extends StatelessWidget {
  final int selectedColorIndex;
  final ValueChanged<int> onColorSelected;

  const ColorPickerPalette({
    super.key,
    required this.selectedColorIndex,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.noteColorsDark : AppColors.noteColorsLight;

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: colors.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final color = colors[index];
          final isSelected = selectedColorIndex == index;

          return GestureDetector(
            onTap: () => onColorSelected(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : (isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)),
                  width: isSelected ? 2.5 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: 20,
                      color: isDark ? Colors.white : AppColors.primary,
                    )
                  : (index == 0
                      ? Icon(
                          Icons.format_color_reset_outlined,
                          size: 16,
                          color: isDark ? Colors.white54 : Colors.black38,
                        )
                      : null),
            ),
          );
        },
      ),
    );
  }
}
