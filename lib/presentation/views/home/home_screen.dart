import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../domain/models/note_model.dart';
import '../../controllers/notes_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../widgets/custom_snackbar.dart';
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
    final hasNotes = notesController.allNotes.isNotEmpty;
    final isSearching = notesController.searchQuery.isNotEmpty || notesController.selectedCategory != 'todas';

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Text(
              AppStrings.appName,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 22,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'IA Local',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        actions: [
          // Theme Toggle
          IconButton(
            icon: Icon(
              themeController.isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              size: 22,
            ),
            tooltip: themeController.isDarkMode ? 'Tema Claro' : 'Tema Escuro',
            onPressed: () => themeController.toggleTheme(),
          ),

          // Settings
          IconButton(
            icon: const Icon(Icons.tune_rounded, size: 22),
            tooltip: 'Configurações',
            onPressed: _navigateToSettings,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              const SizedBox(height: 8),

              // Search and Mode Bar
              SearchAndFilterBar(
                searchController: _searchController,
                onSearchChanged: (val) => notesController.setSearchQuery(val),
                onClearSearch: () => notesController.clearSearch(),
                isGridView: notesController.isGridView,
                onToggleViewMode: () => notesController.toggleViewMode(),
              ),

              const SizedBox(height: 12),

              // Category Chips
              CategoryChipsBar(
                selectedCategory: notesController.selectedCategory,
                onCategorySelected: (catId) => notesController.setSelectedCategory(catId),
                allNotes: notesController.allNotes,
              ),

              const SizedBox(height: 12),

              // Main Content
              Expanded(
                child: notesController.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : !hasNotes
                        ? EmptyNotesView(
                            isSearch: false,
                            onResetFilter: null,
                          )
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
                                  padding: EdgeInsets.symmetric(
                                    horizontal: ResponsiveLayout.getHorizontalPadding(context),
                                    vertical: 8,
                                  ),
                                  children: [
                                    // Pinned Section
                                    if (pinnedNotes.isNotEmpty) ...[
                                      _buildSectionTitle(
                                        AppStrings.pinnedNotes,
                                        Icons.push_pin_rounded,
                                        pinnedNotes.length,
                                        isDark,
                                      ),
                                      const SizedBox(height: 8),
                                      _buildNotesLayout(pinnedNotes, notesController),
                                      const SizedBox(height: 20),
                                    ],

                                    // Other Notes Section
                                    if (unpinnedNotes.isNotEmpty) ...[
                                      if (pinnedNotes.isNotEmpty)
                                        _buildSectionTitle(
                                          AppStrings.otherNotes,
                                          Icons.note_alt_outlined,
                                          unpinnedNotes.length,
                                          isDark,
                                        ),
                                      const SizedBox(height: 8),
                                      _buildNotesLayout(unpinnedNotes, notesController),
                                    ],

                                    const SizedBox(height: 80), // bottom padding for FAB
                                  ],
                                ),
                              ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToEditor(),
        icon: const Icon(Icons.edit_note_rounded, size: 24),
        label: const Text('Nova Nota', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, int count, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          size: 15,
          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
        ),
        const SizedBox(width: 6),
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '($count)',
          style: TextStyle(
            fontSize: 11.5,
            color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesLayout(List<NoteModel> notes, NotesController controller) {
    final isGridView = controller.isGridView;
    final columnCount = ResponsiveLayout.getGridColumnCount(context);

    if (!isGridView || columnCount == 1) {
      // Linear List Layout
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: notes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
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

    // Responsive Masonry Grid Layout
    return MasonryGridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: columnCount,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
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
        if (mounted) {
          CustomSnackBar.show(
            context,
            message: AppStrings.noteDeleted,
            actionLabel: AppStrings.undoAction,
            onActionPressed: () {
              controller.undoDelete();
            },
          );
        }
      },
    );
  }
}
