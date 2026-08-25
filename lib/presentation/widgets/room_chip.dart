import 'package:flutter/material.dart';

import '../theme/cici_theme.dart';

/// Chip de seleção de cômodo com animação de seleção.
class RoomChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  const RoomChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? CiciTheme.primaryBlue
              : CiciTheme.surfaceDark,
          borderRadius: CiciTheme.radiusFull,
          border: Border.all(
            color: isSelected
                ? CiciTheme.primaryBlue
                : CiciTheme.glassBorder,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: CiciTheme.primaryBlue.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 1,
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? Colors.white
                    : CiciTheme.textMuted,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: CiciTheme.labelBold.copyWith(
                color: isSelected
                    ? Colors.white
                    : CiciTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
