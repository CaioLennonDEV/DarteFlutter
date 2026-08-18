import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/ai_assistant_service.dart';

class AIAssistantModal extends StatefulWidget {
  final String currentTitle;
  final String currentContent;
  final Function(String newContent) onApplyContent;
  final Function(String newTitle) onApplyTitle;
  final Function(List<String> suggestedTags) onApplyTags;
  final Function(String summary) onApplySummary;

  const AIAssistantModal({
    super.key,
    required this.currentTitle,
    required this.currentContent,
    required this.onApplyContent,
    required this.onApplyTitle,
    required this.onApplyTags,
    required this.onApplySummary,
  });

  static void show(
    BuildContext context, {
    required String currentTitle,
    required String currentContent,
    required Function(String newContent) onApplyContent,
    required Function(String newTitle) onApplyTitle,
    required Function(List<String> suggestedTags) onApplyTags,
    required Function(String summary) onApplySummary,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AIAssistantModal(
        currentTitle: currentTitle,
        currentContent: currentContent,
        onApplyContent: onApplyContent,
        onApplyTitle: onApplyTitle,
        onApplyTags: onApplyTags,
        onApplySummary: onApplySummary,
      ),
    );
  }

  @override
  State<AIAssistantModal> createState() => _AIAssistantModalState();
}

class _AIAssistantModalState extends State<AIAssistantModal> {
  String? _previewResult;
  String? _currentActionName;
  bool _isProcessing = false;

  void _runAction(String name, VoidCallback process) async {
    setState(() {
      _isProcessing = true;
      _currentActionName = name;
      _previewResult = null;
    });

    await Future.delayed(const Duration(milliseconds: 350)); // UI feedback animation

    process();

    setState(() {
      _isProcessing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      padding: EdgeInsets.only(
        top: 16,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Assistente NotaIA',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  Text(
                    'Turbine suas notas com processamento inteligente',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // AI Action Buttons
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildActionChip(
                  icon: Icons.summarize_outlined,
                  label: 'Resumir',
                  color: AppColors.primary,
                  onTap: () => _runAction('Resumo Inteligente', () {
                    final summary = AIAssistantService.summarize(widget.currentContent);
                    _previewResult = summary;
                  }),
                ),
                const SizedBox(width: 8),
                _buildActionChip(
                  icon: Icons.auto_fix_high_rounded,
                  label: 'Melhorar Escrita',
                  color: AppColors.secondary,
                  onTap: () => _runAction('Melhoria de Escrita', () {
                    final enhanced = AIAssistantService.enhanceText(widget.currentContent);
                    _previewResult = enhanced;
                  }),
                ),
                const SizedBox(width: 8),
                _buildActionChip(
                  icon: Icons.checklist_rounded,
                  label: 'Extrair Checklist',
                  color: AppColors.accent,
                  onTap: () => _runAction('Checklist de Tarefas', () {
                    final checklist = AIAssistantService.extractActionItems(widget.currentContent);
                    _previewResult = checklist;
                  }),
                ),
                const SizedBox(width: 8),
                _buildActionChip(
                  icon: Icons.sell_outlined,
                  label: 'Sugerir Tags',
                  color: AppColors.success,
                  onTap: () => _runAction('Sugestão de Tags', () {
                    final tags = AIAssistantService.suggestTags(widget.currentContent);
                    _previewResult = 'Tags sugeridas: ${tags.map((t) => '#$t').join(' ')}';
                  }),
                ),
                const SizedBox(width: 8),
                _buildActionChip(
                  icon: Icons.title_rounded,
                  label: 'Gerar Título',
                  color: AppColors.warning,
                  onTap: () => _runAction('Gerar Título', () {
                    final title = AIAssistantService.generateTitle(widget.currentContent);
                    _previewResult = title;
                  }),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Processing State or Result View
          if (_isProcessing) ...[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 28),
              alignment: Alignment.center,
              child: const Column(
                children: [
                  CircularProgressIndicator(strokeWidth: 2.5),
                  SizedBox(height: 12),
                  Text(
                    'Processando com NotaIA...',
                    style: TextStyle(fontSize: 13, color: AppColors.primaryLight),
                  ),
                ],
              ),
            ),
          ] else if (_previewResult != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _currentActionName ?? 'Resultado:',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryLight,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 16),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => setState(() => _previewResult = null),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _previewResult!,
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.4,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Action to apply
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Fechar'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: () {
                    if (_currentActionName == 'Resumo Inteligente') {
                      widget.onApplySummary(_previewResult!);
                    } else if (_currentActionName == 'Melhoria de Escrita') {
                      widget.onApplyContent(_previewResult!);
                    } else if (_currentActionName == 'Checklist de Tarefas') {
                      final updated = '${widget.currentContent}\n\n$_previewResult';
                      widget.onApplyContent(updated);
                    } else if (_currentActionName == 'Sugestão de Tags') {
                      final tags = AIAssistantService.suggestTags(widget.currentContent);
                      widget.onApplyTags(tags);
                    } else if (_currentActionName == 'Gerar Título') {
                      widget.onApplyTitle(_previewResult!);
                    }
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text('Aplicar à Nota'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ] else ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'Selecione uma ação acima para analisar ou aprimorar o conteúdo da sua nota.',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ActionChip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(label),
      onPressed: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      side: BorderSide(color: color.withOpacity(0.3)),
      backgroundColor: color.withOpacity(0.08),
      labelStyle: TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }
}
