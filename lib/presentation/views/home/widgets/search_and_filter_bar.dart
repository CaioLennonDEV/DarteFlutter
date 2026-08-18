import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

class SearchAndFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final Function(String) onSearchChanged;
  final VoidCallback onClearSearch;
  final bool isGridView;
  final VoidCallback onToggleViewMode;

  const SearchAndFilterBar({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.isGridView,
    required this.onToggleViewMode,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // iOS Cupertino Style Search Bar
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFE5E5EA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: searchController,
                onChanged: onSearchChanged,
                textAlignVertical: TextAlignVertical.center,
                style: TextStyle(
                  fontSize: 14.5,
                  color: isDark ? Colors.white : Colors.black,
                ),
                decoration: InputDecoration(
                  hintText: 'Buscar nas notas...',
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF8E8E93),
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    size: 18,
                    color: Color(0xFF8E8E93),
                  ),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.cancel, size: 16, color: Color(0xFF8E8E93)),
                          onPressed: () {
                            searchController.clear();
                            onClearSearch();
                          },
                        )
                      : null,
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // View Mode Switcher
          IconButton(
            icon: Icon(
              isGridView ? Icons.view_agenda_outlined : Icons.grid_view_rounded,
              size: 20,
              color: AppColors.primary,
            ),
            onPressed: onToggleViewMode,
            tooltip: isGridView ? 'Lista' : 'Grade',
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
