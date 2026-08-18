import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../domain/models/note_category.dart';
import '../../../../domain/models/note_model.dart';
import '../../editor/widgets/drawing_canvas_modal.dart';
import '../../editor/widgets/font_style_selector.dart';

class NoteCard extends StatelessWidget {
  final NoteModel note;
  final VoidCallback onTap;
  final VoidCallback onPinToggle;
  final VoidCallback onDelete;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.onPinToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final category = NoteCategory.getCategoryById(note.categoryId);

    final safeColorIndex = (note.colorIndex < 0 ? 0 : note.colorIndex) % AppColors.noteColorsLight.length;
    final cardBgColor = isDark
        ? AppColors.noteColorsDark[safeColorIndex]
        : AppColors.noteColorsLight[safeColorIndex];

    final isDefaultColor = safeColorIndex == 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: cardBgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? (isDefaultColor ? const Color(0xFF38383A) : Colors.white.withOpacity(0.08))
                  : (isDefaultColor ? const Color(0xFFE5E5EA) : Colors.black.withOpacity(0.06)),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header: Pin, Emoji & Category
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (note.emoji != null) ...[
                        Text(note.emoji!, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        category.name,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: category.color,
                        ),
                      ),
                      if (note.hasAudio) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.mic, size: 12, color: AppColors.iosRed),
                      ],
                    ],
                  ),
                  if (note.isPinned)
                    const Icon(Icons.push_pin, size: 14, color: AppColors.primary),
                ],
              ),

              const SizedBox(height: 8),

              // Title
              if (note.title.isNotEmpty) ...[
                Text(
                  note.title,
                  style: FontStyleSelector.getTextStyle(
                    fontFamily: note.fontFamily,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
              ],

              // Content snippet
              if (note.content.isNotEmpty)
                Text(
                  note.previewContent,
                  style: FontStyleSelector.getTextStyle(
                    fontFamily: note.fontFamily,
                    fontSize: 13,
                    color: isDark ? const Color(0xFFA1A1A6) : const Color(0xFF636366),
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

              // Drawing thumbnail if present
              if (note.hasDrawings) ...[
                const SizedBox(height: 8),
                DrawingThumbnailWidget(points: note.drawingPoints, height: 60),
              ],

              const SizedBox(height: 10),

              // Date Footer
              Text(
                DateFormatter.formatNoteDate(note.updatedAt),
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF8E8E93),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
