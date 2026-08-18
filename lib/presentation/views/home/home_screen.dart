import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../domain/models/note_model.dart';
import '../../controllers/notes_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../widgets/confirmation_dialog.dart';
import '../editor/note_editor_screen.dart';
import '../settings/settings_screen.dart';
import 'widgets/category_chips_bar.dart';
import 'widgets/empty_notes_view.dart';
import 'widgets/note_card.dart';
import 'widgets/search_and_filter_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToEditor([NoteModel? note]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NoteEditorScreen(initialNote: note),
      ),
    );
  }

  void _navigateToSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notesController = context.watch<NotesController>();
    final themeController = context.watch<ThemeController>();

    final pinnedNotes = notesController.pinnedNotes;
    final unpinnedNotes = notesController.unpinnedNotes;
    final allNotes = notesController.allNotes;
    final hasNotes = allNotes.isNotEmpty;
    final isSearching = notesController.searchQuery.isNotEmpty || notesController.selectedCategory != 'todas';

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Bar (Settings & Theme)
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 12, top: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.auto_awesome, color: AppColors.primary, size: 18),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'NotaIA',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  themeController.isDarkMode
                                      ? Icons.light_mode_outlined
                                      : Icons.dark_mode_outlined,
                                  size: 20,
                                  color: AppColors.primary,
                                ),
                                tooltip: 'Tema',
                                onPressed: () => themeController.toggleTheme(),
                              ),
                              IconButton(
                                icon: const Icon(Icons.tune_rounded, size: 20, color: AppColors.primary),
                                tooltip: 'Configurações',
                                onPressed: _navigateToSettings,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Large iOS Title: "Notas"
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      child: Text(
                        'Notas',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.8,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    // iOS Cupertino Search Bar
                    SearchAndFilterBar(
                      searchController: _searchController,
                      onSearchChanged: (val) => notesController.setSearchQuery(val),
                      onClearSearch: () => notesController.clearSearch(),
                      isGridView: notesController.isGridView,
                      onToggleViewMode: () => notesController.toggleViewMode(),
                    ),

                    const SizedBox(height: 10),

                    // Category Filter Pills
                    CategoryChipsBar(
                      selectedCategory: notesController.selectedCategory,
                      onCategorySelected: (catId) => notesController.setSelectedCategory(catId),
                      allNotes: notesController.allNotes,
                    ),

                    const SizedBox(height: 10),

                    // Notes List / Masonry Grid
                    Expanded(
                      child: notesController.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : !hasNotes
                              ? const EmptyNotesView(isSearch: false)
                              : (pinnedNotes.isEmpty && unpinnedNotes.isEmpty)
                                  ? EmptyNotesView(
                                      isSearch: isSearching,
                                      onResetFilter: () {
                                        _searchController.clear();
                                        notesController.clearSearch();
                                        notesController.setSelectedCategory('todas');
                                      },
                                    )
                                  : RefreshIndicator(
                                      onRefresh: () => notesController.loadNotes(),
                                      child: ListView(
                                        physics: const AlwaysScrollableScrollPhysics(
                                          parent: BouncingScrollPhysics(),
                                        ),
                                        padding: EdgeInsets.only(
                                          left: ResponsiveLayout.getHorizontalPadding(context),
                                          right: ResponsiveLayout.getHorizontalPadding(context),
                                          top: 8,
                                          bottom: 90,
                                        ),
                                        children: [
                                          // Pinned Notes Section
                                          if (pinnedNotes.isNotEmpty) ...[
                                            _buildSectionHeader('FIXADAS', isDark),
                                            const SizedBox(height: 8),
                                            _buildNotesGrid(pinnedNotes, notesController),
                                            const SizedBox(height: 20),
                                          ],

                                          // Other Notes Section
                                          if (unpinnedNotes.isNotEmpty) ...[
                                            if (pinnedNotes.isNotEmpty)
                                              _buildSectionHeader('NOTAS', isDark),
                                            const SizedBox(height: 8),
                                            _buildNotesGrid(unpinnedNotes, notesController),
                                          ],
                                        ],
                                      ),
                                    ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Apple Notes Floating Bottom Bar (Count + New Note Button)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1C1C1E).withOpacity(0.85)
                        : Colors.white.withOpacity(0.85),
                    border: Border(
                      top: BorderSide(
                        color: isDark ? const Color(0xFF38383A) : const Color(0xFFE5E5EA),
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 44), // balance spacer
                        // Center Notes Count
                        Text(
                          '${allNotes.length} ${allNotes.length == 1 ? 'Nota' : 'Notas'}',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF8E8E93),
                          ),
                        ),
                        // Right: New Note Button (Apple Notes Style)
                        IconButton(
                          icon: const Icon(Icons.edit_square, size: 24, color: AppColors.primary),
                          tooltip: 'Nova Nota',
                          onPressed: () => _navigateToEditor(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.8,
        color: Color(0xFF8E8E93),
      ),
    );
  }

  Widget _buildNotesGrid(List<NoteModel> notes, NotesController controller) {
    final isGridView = controller.isGridView;
    final columnCount = ResponsiveLayout.getGridColumnCount(context);

    if (!isGridView || columnCount == 1) {
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: notes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final note = notes[index];
          return NoteCard(
            note: note,
            onTap: () => _navigateToEditor(note),
            onPinToggle: () => controller.togglePin(note.id),
            onDelete: () => _confirmDelete(note, controller),
          );
        },
      );
    }

    return MasonryGridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: columnCount,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return NoteCard(
          note: note,
          onTap: () => _navigateToEditor(note),
          onPinToggle: () => controller.togglePin(note.id),
          onDelete: () => _confirmDelete(note, controller),
        );
      },
    );
  }

  void _confirmDelete(NoteModel note, NotesController controller) {
    ConfirmationDialog.show(
      context,
      onConfirm: () async {
        await controller.deleteNote(note.id);
      },
    );
  }
}
