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

    final cardBgColor = isDark
        ? AppColors.noteColorsDark[note.colorIndex % AppColors.noteColorsDark.length]
        : AppColors.noteColorsLight[note.colorIndex % AppColors.noteColorsLight.length];

    final isDefaultColor = note.colorIndex == 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            color: cardBgColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark
                  ? (isDefaultColor ? const Color(0xFF334155) : Colors.white.withOpacity(0.08))
                  : (isDefaultColor ? const Color(0xFFE2E8F0) : Colors.black.withOpacity(0.06)),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.25 : 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header: Category Badge, Emoji, Audio Badge & Pin Button
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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: category.color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(category.icon, size: 13, color: category.color),
                            const SizedBox(width: 4),
                            Text(
                              category.name,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: category.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (note.hasAudio) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.mic, size: 11, color: AppColors.error),
                              const SizedBox(width: 2),
                              Text(
                                '${note.audioMemos.length}',
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  IconButton(
                    icon: Icon(
                      note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                      size: 18,
                      color: note.isPinned
                          ? AppColors.primary
                          : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                    ),
                    onPressed: onPinToggle,
                    tooltip: note.isPinned ? 'Desafixar nota' : 'Fixar no topo',
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Note Title with Custom Typography
              if (note.title.isNotEmpty) ...[
                Text(
                  note.title,
                  style: FontStyleSelector.getTextStyle(
                    fontFamily: note.fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
              ],

              // Note Content Snippet
              if (note.content.isNotEmpty)
                Text(
                  note.previewContent,
                  style: FontStyleSelector.getTextStyle(
                    fontFamily: note.fontFamily,
                    fontSize: 13.5,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),

              // Drawing Thumbnail (if exists)
              if (note.hasDrawings) ...[
                const SizedBox(height: 8),
                DrawingThumbnailWidget(points: note.drawingPoints, height: 75),
              ],

              // AI Badge if Note has AI Summary
              if (note.aiSummary != null && note.aiSummary!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome, size: 11, color: AppColors.primary),
                      SizedBox(width: 4),
                      Text(
                        'Resumido por IA',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Tags
              if (note.tags.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: note.tags.take(3).map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '#$tag',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],

              const SizedBox(height: 12),

              // Footer: Date & Delete action
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormatter.formatNoteDate(note.updatedAt),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, size: 17),
                    color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                    onPressed: onDelete,
                    tooltip: 'Excluir nota',
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
