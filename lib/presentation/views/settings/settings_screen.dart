import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../controllers/notes_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../widgets/custom_snackbar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notesController = context.watch<NotesController>();
    final themeController = context.watch<ThemeController>();

    final totalNotes = notesController.totalNotesCount;
    final pinnedNotes = notesController.allNotes.where((n) => n.isPinned).length;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        title: const Text('Ajustes & Sobre'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // iOS Group: Aparência
          _buildGroupHeader('APARÊNCIA'),
          const SizedBox(height: 6),
          _buildGroupCard(
            isDark,
            [
              SwitchListTile(
                secondary: _buildLeadingIcon(
                  themeController.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  AppColors.iosPurple,
                ),
                title: const Text('Modo Escuro (Dark Mode)', style: TextStyle(fontSize: 15)),
                value: themeController.isDarkMode,
                activeColor: AppColors.primary,
                onChanged: (_) => themeController.toggleTheme(),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // iOS Group: Armazenamento Local
          _buildGroupHeader('ARMAZENAMENTO LOCAL'),
          const SizedBox(height: 6),
          _buildGroupCard(
            isDark,
            [
              _buildInfoRow('Motor de Banco', 'Hive NoSQL (100% Offline)', isDark),
              _buildDivider(isDark),
              _buildInfoRow('Total de Notas', '$totalNotes', isDark),
              _buildDivider(isDark),
              _buildInfoRow('Notas Fixadas', '$pinnedNotes', isDark),
            ],
          ),

          const SizedBox(height: 20),

          // iOS Group: Gerenciamento de Dados
          _buildGroupHeader('GERENCIAMENTO'),
          const SizedBox(height: 6),
          _buildGroupCard(
            isDark,
            [
              ListTile(
                leading: _buildLeadingIcon(Icons.delete_sweep_rounded, AppColors.iosRed),
                title: const Text(
                  'Apagar Todas as Notas',
                  style: TextStyle(fontSize: 15, color: AppColors.iosRed, fontWeight: FontWeight.w500),
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: Color(0xFFC7C7CC)),
                onTap: () {
                  ConfirmationDialog.show(
                    context,
                    title: 'Apagar Tudo?',
                    message: 'Tem certeza que deseja apagar todas as notas salvas no seu aparelho?',
                    confirmText: 'Apagar Tudo',
                    onConfirm: () async {
                      await notesController.clearAllNotes();
                      if (context.mounted) {
                        CustomSnackBar.show(context, message: 'Todas as notas foram apagadas.');
                      }
                    },
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 20),

          // iOS Group: Sobre o NotaIA
          _buildGroupHeader('SOBRE'),
          const SizedBox(height: 6),
          _buildGroupCard(
            isDark,
            [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.iosOrange],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('NotaIA', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          SizedBox(height: 2),
                          Text('Versão 1.0.0 • Apple Notes Style', style: TextStyle(fontSize: 12.5, color: Color(0xFF8E8E93))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGroupHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
          color: Color(0xFF8E8E93),
        ),
      ),
    );
  }

  Widget _buildGroupCard(bool isDark, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF38383A) : const Color(0xFFE5E5EA),
          width: 0.5,
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 0.5,
      indent: 16,
      color: isDark ? const Color(0xFF38383A) : const Color(0xFFE5E5EA),
    );
  }

  Widget _buildLeadingIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 18, color: color),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 15)),
          Text(value, style: const TextStyle(fontSize: 14, color: Color(0xFF8E8E93))),
        ],
      ),
    );
  }
}
