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
      appBar: AppBar(
        title: const Text('Configurações & Sobre'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Theme Section
          _buildSectionHeader('APARÊNCIA', isDark),
          const SizedBox(height: 8),
          Container(
            decoration: _boxDecoration(isDark),
            child: SwitchListTile(
              secondary: Icon(
                themeController.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                color: AppColors.primary,
              ),
              title: const Text('Modo Escuro (Dark Mode)'),
              subtitle: Text(
                themeController.isDarkMode ? 'Tema escuro ativado' : 'Tema claro ativado',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              value: themeController.isDarkMode,
              activeColor: AppColors.primary,
              onChanged: (_) => themeController.toggleTheme(),
            ),
          ),

          const SizedBox(height: 24),

          // Storage & Stats Section
          _buildSectionHeader('ARMAZENAMENTO LOCAL', isDark),
          const SizedBox(height: 8),
          Container(
            decoration: _boxDecoration(isDark),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildStatRow('Motor de Persistência', 'Hive NoSQL (100% Local)', isDark),
                const Divider(height: 20),
                _buildStatRow('Total de Notas', '$totalNotes', isDark),
                const Divider(height: 20),
                _buildStatRow('Notas Fixadas', '$pinnedNotes', isDark),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Data Management
          _buildSectionHeader('GERENCIAMENTO DE DADOS', isDark),
          const SizedBox(height: 8),
          Container(
            decoration: _boxDecoration(isDark),
            child: ListTile(
              leading: const Icon(Icons.delete_sweep_rounded, color: AppColors.error),
              title: const Text(
                'Limpar Todas as Notas',
                style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                'Remove permanentemente todas as notas salvas localmente.',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              onTap: () {
                ConfirmationDialog.show(
                  context,
                  title: 'Apagar Tudo?',
                  message: 'Tem certeza que deseja apagar todas as notas do dispositivo? Esta ação é irreversível.',
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
          ),

          const SizedBox(height: 24),

          // About Card
          _buildSectionHeader('SOBRE O NOTAIA', isDark),
          const SizedBox(height: 8),
          Container(
            decoration: _boxDecoration(isDark),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.secondary],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.appName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                        const Text(
                          'Versão 1.0.0 • Docker & Flutter Web Ready',
                          style: TextStyle(fontSize: 12, color: AppColors.primaryLight),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  '${AppStrings.appTagline}. Construído com Clean Architecture, Flutter 3.x, persistência NoSQL local ultrarrápida e Docker multi-stage build com Nginx.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.45,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.0,
        color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
      ),
    );
  }

  BoxDecoration _boxDecoration(bool isDark) {
    return BoxDecoration(
      color: isDark ? AppColors.darkCard : AppColors.lightCard,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.5,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryLight,
          ),
        ),
      ],
    );
  }
}
