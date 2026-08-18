import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final bool isDestructive;
  final VoidCallback onConfirm;

  const ConfirmationDialog({
    super.key,
    this.title = AppStrings.deleteConfirmTitle,
    this.message = AppStrings.deleteConfirmMessage,
    this.confirmText = AppStrings.deleteAction,
    this.cancelText = AppStrings.cancelAction,
    this.isDestructive = true,
    required this.onConfirm,
  });

  static Future<bool?> show(
    BuildContext context, {
    String title = AppStrings.deleteConfirmTitle,
    String message = AppStrings.deleteConfirmMessage,
    String confirmText = AppStrings.deleteAction,
    bool isDestructive = true,
    required VoidCallback onConfirm,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        isDestructive: isDestructive,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(
            isDestructive ? Icons.warning_amber_rounded : Icons.help_outline_rounded,
            color: isDestructive ? AppColors.error : AppColors.primary,
            size: 26,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: TextStyle(
          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          fontSize: 14,
          height: 1.5,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            cancelText,
            style: TextStyle(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop(true);
            onConfirm();
          },
          style: FilledButton.styleFrom(
            backgroundColor: isDestructive ? AppColors.error : AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(confirmText),
        ),
      ],
    );
  }
}
