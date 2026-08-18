import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class EmojiPickerBar extends StatelessWidget {
  final String? selectedEmoji;
  final ValueChanged<String?> onEmojiSelected;

  const EmojiPickerBar({
    super.key,
    required this.selectedEmoji,
    required this.onEmojiSelected,
  });

  static const List<String> availableEmojis = [
    '💡', '🚀', '📝', '🎯', '🎨', '🧠', '⚡', '📌',
    '💼', '🎓', '💰', '🎧', '🌟', '🏷️', '🔍', '📅',
    '💬', '🛠️', '📊', '🏆', '✈️', '🌴', '☕', '💻',
    '🔥', '✨', '❤️', '✅', '📈', '🧘', '🍔', '🛒',
  ];

  static void show(
    BuildContext context, {
    required String? selectedEmoji,
    required ValueChanged<String?> onEmojiSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 320,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkSurface
              : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
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
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Escolha um Ícone / Emoji',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                if (selectedEmoji != null)
                  TextButton.icon(
                    onPressed: () {
                      onEmojiSelected(null);
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.error),
                    label: const Text('Remover', style: TextStyle(color: AppColors.error)),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: availableEmojis.length,
                itemBuilder: (context, index) {
                  final emoji = availableEmojis[index];
                  final isSelected = selectedEmoji == emoji;

                  return InkWell(
                    onTap: () {
                      onEmojiSelected(emoji);
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withOpacity(0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected
                            ? Border.all(color: AppColors.primary, width: 2)
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        emoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => show(
        context,
        selectedEmoji: selectedEmoji,
        onEmojiSelected: onEmojiSelected,
      ),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: Text(
          selectedEmoji ?? '😀',
          style: TextStyle(
            fontSize: selectedEmoji != null ? 24 : 20,
          ),
        ),
      ),
    );
  }
}
