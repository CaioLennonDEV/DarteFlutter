import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class IOSActionSheetMenu {
  static void show(
    BuildContext context, {
    required bool isPinned,
    required VoidCallback onTogglePin,
    required VoidCallback onOpenAI,
    required VoidCallback onOpenAudio,
    required VoidCallback onOpenDrawing,
    required VoidCallback onOpenTypography,
    required VoidCallback onOpenColorPalette,
    required VoidCallback onOpenTags,
    required VoidCallback onDelete,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // iOS drag indicator
            Container(
              width: 36,
              height: 5,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),

            // Section 1: AI Actions (Grouped iOS card)
            _buildGroupCard(
              isDark,
              [
                _buildActionItem(
                  icon: Icons.auto_awesome,
                  iconColor: AppColors.iosYellow,
                  title: 'Assistente NotaIA',
                  subtitle: 'Resumos, melhorias de escrita e tarefas',
                  onTap: () {
                    Navigator.pop(context);
                    onOpenAI();
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Section 2: Multimedia & Design Tools
            _buildGroupCard(
              isDark,
              [
                _buildActionItem(
                  icon: isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                  iconColor: AppColors.iosOrange,
                  title: isPinned ? 'Desafixar do Topo' : 'Fixar no Topo',
                  onTap: () {
                    Navigator.pop(context);
                    onTogglePin();
                  },
                ),
                _buildDivider(isDark),
                _buildActionItem(
                  icon: Icons.mic_rounded,
                  iconColor: AppColors.iosRed,
                  title: 'Gravar Nota de Voz',
                  onTap: () {
                    Navigator.pop(context);
                    onOpenAudio();
                  },
                ),
                _buildDivider(isDark),
                _buildActionItem(
                  icon: Icons.draw_outlined,
                  iconColor: AppColors.iosBlue,
                  title: 'Desenho / Rascunho à Mão',
                  onTap: () {
                    Navigator.pop(context);
                    onOpenDrawing();
                  },
                ),
                _buildDivider(isDark),
                _buildActionItem(
                  icon: Icons.text_fields_rounded,
                  iconColor: AppColors.iosPurple,
                  title: 'Tipografia & Tamanho da Fonte',
                  onTap: () {
                    Navigator.pop(context);
                    onOpenTypography();
                  },
                ),
                _buildDivider(isDark),
                _buildActionItem(
                  icon: Icons.palette_outlined,
                  iconColor: AppColors.iosTeal,
                  title: 'Cor da Nota & Fundo',
                  onTap: () {
                    Navigator.pop(context);
                    onOpenColorPalette();
                  },
                ),
                _buildDivider(isDark),
                _buildActionItem(
                  icon: Icons.tag_rounded,
                  iconColor: AppColors.iosGreen,
                  title: 'Adicionar Tags & Categoria',
                  onTap: () {
                    Navigator.pop(context);
                    onOpenTags();
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Section 3: Destructive Actions
            _buildGroupCard(
              isDark,
              [
                _buildActionItem(
                  icon: Icons.delete_outline_rounded,
                  iconColor: AppColors.iosRed,
                  title: 'Apagar Nota',
                  titleColor: AppColors.iosRed,
                  onTap: () {
                    Navigator.pop(context);
                    onDelete();
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  static Widget _buildGroupCard(bool isDark, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(children: children),
    );
  }

  static Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 0.5,
      indent: 52,
      color: isDark ? const Color(0xFF38383A) : const Color(0xFFE5E5EA),
    );
  }

  static Widget _buildActionItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: titleColor,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8E8E93),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 13,
              color: Color(0xFFC7C7CC),
            ),
          ],
        ),
      ),
    );
  }
}
