import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../domain/models/note_category.dart';
import '../../../../domain/models/note_model.dart';

class CategoryChipsBar extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;
  final List<NoteModel> allNotes;

  const CategoryChipsBar({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.allNotes,
  });

  int _getCountForCategory(String categoryId) {
    if (categoryId == 'todas') return allNotes.length;
    return allNotes.where((n) => n.categoryId == categoryId).length;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final categories = [
      const NoteCategory(
        id: 'todas',
        name: 'Todas',
        icon: Icons.all_inclusive_rounded,
        color: AppColors.primary,
      ),
      ...NoteCategory.defaultCategories,
    ];

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = selectedCategory == cat.id;
          final count = _getCountForCategory(cat.id);

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onCategorySelected(cat.id),
              borderRadius: BorderRadius.circular(18),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : (isDark ? const Color(0xFF1C1C1E) : const Color(0xFFE5E5EA)),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      cat.name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.white70 : const Color(0xFF1C1C1E)),
                      ),
                    ),
                    if (count > 0) ...[
                      const SizedBox(width: 5),
                      Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white70
                              : (isDark ? Colors.white38 : const Color(0xFF8E8E93)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
