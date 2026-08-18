import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../domain/models/audio_memo.dart';
import '../../../domain/models/drawing_point.dart';
import '../../../domain/models/note_category.dart';
import '../../../domain/models/note_model.dart';
import '../../controllers/notes_controller.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../widgets/custom_snackbar.dart';
import 'widgets/ai_assistant_modal.dart';
import 'widgets/audio_recorder_modal.dart';
import 'widgets/color_picker_palette.dart';
import 'widgets/drawing_canvas_modal.dart';
import 'widgets/emoji_picker_bar.dart';
import 'widgets/font_style_selector.dart';

class NoteEditorScreen extends StatefulWidget {
  final NoteModel? initialNote;

  const NoteEditorScreen({super.key, this.initialNote});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _tagInputController;

  late bool _isPinned;
  late int _colorIndex;
  late String _categoryId;
  late List<String> _tags;
  String? _aiSummary;
  String? _emoji;
  String _fontFamily = 'Inter';
  double _fontSize = 15.5;
  List<DrawingPoint> _drawingPoints = [];
  List<AudioMemo> _audioMemos = [];
  late DateTime _createdAt;

  bool _isModified = false;

  @override
  void initState() {
    super.initState();
    debugPrint('📝 [NoteEditorScreen] initState iniciado para nota: ${widget.initialNote?.id ?? "NOVA_NOTA"}');
    final note = widget.initialNote;

    _titleController = TextEditingController(text: note?.title ?? '');
    _contentController = TextEditingController(text: note?.content ?? '');
    _tagInputController = TextEditingController();

    _isPinned = note?.isPinned ?? false;
    _colorIndex = note?.colorIndex ?? 0;
    _categoryId = note?.categoryId ?? 'geral';
    _tags = List.from(note?.tags ?? []);
    _aiSummary = note?.aiSummary;
    _emoji = note?.emoji;
    _fontFamily = note?.fontFamily ?? 'Inter';
    _fontSize = note?.fontSize ?? 15.5;
    _drawingPoints = List.from(note?.drawingPoints ?? []);
    _audioMemos = List.from(note?.audioMemos ?? []);
    _createdAt = note?.createdAt ?? DateTime.now();

    _titleController.addListener(_markModified);
    _contentController.addListener(_markModified);
    debugPrint('📝 [NoteEditorScreen] initState concluído com sucesso.');
  }

  void _markModified() {
    if (!_isModified) {
      setState(() {
        _isModified = true;
      });
    } else {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagInputController.dispose();
    super.dispose();
  }

  Future<void> _saveNote({bool pop = true}) async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty && _drawingPoints.isEmpty && _audioMemos.isEmpty) {
      if (pop) Navigator.of(context).pop();
      return;
    }

    final notesController = context.read<NotesController>();

    final now = DateTime.now();
    final note = NoteModel(
      id: widget.initialNote?.id ?? const Uuid().v4(),
      title: title.isEmpty ? 'Sem título' : title,
      content: content,
      createdAt: _createdAt,
      updatedAt: now,
      isPinned: _isPinned,
      colorIndex: _colorIndex,
      categoryId: _categoryId,
      tags: _tags,
      aiSummary: _aiSummary,
      emoji: _emoji,
      fontFamily: _fontFamily,
      fontSize: _fontSize,
      drawingPoints: _drawingPoints,
      audioMemos: _audioMemos,
    );

    if (widget.initialNote == null) {
      await notesController.addNote(note);
    } else {
      await notesController.updateNote(note);
    }

    _isModified = false;

    if (mounted) {
      CustomSnackBar.show(context, message: AppStrings.noteSaved);
      if (pop) Navigator.of(context).pop();
    }
  }

  void _addTag(String tag) {
    final cleaned = tag.trim().replaceAll('#', '');
    if (cleaned.isNotEmpty && !_tags.contains(cleaned)) {
      setState(() {
        _tags.add(cleaned);
        _isModified = true;
      });
      _tagInputController.clear();
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
      _isModified = true;
    });
  }

  void _openDrawingCanvas() {
    DrawingCanvasModal.show(
      context,
      initialPoints: _drawingPoints,
      onSave: (points) {
        setState(() {
          _drawingPoints = points;
          _isModified = true;
        });
      },
    );
  }

  void _openAudioRecorder() {
    AudioRecorderModal.show(
      context,
      onSaveAudio: (memo) {
        setState(() {
          _audioMemos.add(memo);
          _isModified = true;
        });
      },
    );
  }

  void _openFontSelector() {
    FontStyleSelector.show(
      context,
      currentFontFamily: _fontFamily,
      currentFontSize: _fontSize,
      onFontChanged: (font) {
        setState(() {
          _fontFamily = font;
          _isModified = true;
        });
      },
      onSizeChanged: (size) {
        setState(() {
          _fontSize = size;
          _isModified = true;
        });
      },
    );
  }

  void _openAIAssistant() {
    AIAssistantModal.show(
      context,
      currentTitle: _titleController.text,
      currentContent: _contentController.text,
      onApplyContent: (newContent) {
        setState(() {
          _contentController.text = newContent;
          _isModified = true;
        });
      },
      onApplyTitle: (newTitle) {
        setState(() {
          _titleController.text = newTitle;
          _isModified = true;
        });
      },
      onApplyTags: (suggestedTags) {
        setState(() {
          for (var tag in suggestedTags) {
            if (!_tags.contains(tag)) _tags.add(tag);
          }
          _isModified = true;
        });
      },
      onApplySummary: (summary) {
        setState(() {
          _aiSummary = summary;
          _isModified = true;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.initialNote != null;

    final bgColor = isDark
        ? AppColors.noteColorsDark[_colorIndex % AppColors.noteColorsDark.length]
        : AppColors.noteColorsLight[_colorIndex % AppColors.noteColorsLight.length];

    final wordCount = _contentController.text.trim().isEmpty
        ? 0
        : _contentController.text.trim().split(RegExp(r'\s+')).length;
    final charCount = _contentController.text.length;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && _isModified) {
          _saveNote(pop: false);
        }
      },
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () => _saveNote(pop: true),
            tooltip: 'Voltar e salvar',
          ),
          title: Text(
            isEditing ? AppStrings.editNoteTitle : AppStrings.newNoteTitle,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          actions: [
            // Pin toggle
            IconButton(
              icon: Icon(
                _isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                color: _isPinned ? AppColors.primary : null,
              ),
              onPressed: () {
                setState(() {
                  _isPinned = !_isPinned;
                  _isModified = true;
                });
              },
              tooltip: _isPinned ? 'Desafixar' : 'Fixar no topo',
            ),

            // Delete button (if editing)
            if (isEditing)
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                onPressed: () {
                  ConfirmationDialog.show(
                    context,
                    onConfirm: () async {
                      await context.read<NotesController>().deleteNote(widget.initialNote!.id);
                      if (mounted) {
                        Navigator.of(context).pop();
                        CustomSnackBar.show(
                          context,
                          message: AppStrings.noteDeleted,
                          actionLabel: AppStrings.undoAction,
                          onActionPressed: () {
                            context.read<NotesController>().undoDelete();
                          },
                        );
                      }
                    },
                  );
                },
                tooltip: 'Excluir nota',
              ),

            // Save check button
            IconButton(
              icon: const Icon(Icons.check_rounded, size: 24, color: AppColors.success),
              onPressed: () => _saveNote(pop: true),
              tooltip: 'Salvar',
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 900),
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveLayout.getHorizontalPadding(context),
              vertical: 8,
            ),
            child: Column(
              children: [
                // Quick Multimedia Toolbar Bar (Audio, Draw, Typography, AI)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? Colors.white10 : Colors.black.withOpacity(0.06),
                    ),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildToolButton(
                          icon: Icons.auto_awesome,
                          label: 'NotaIA',
                          color: AppColors.primary,
                          onTap: _openAIAssistant,
                          isHighlight: true,
                        ),
                        const SizedBox(width: 6),
                        _buildToolButton(
                          icon: Icons.mic_none_rounded,
                          label: 'Gravar Áudio',
                          color: AppColors.error,
                          onTap: _openAudioRecorder,
                        ),
                        const SizedBox(width: 6),
                        _buildToolButton(
                          icon: Icons.draw_outlined,
                          label: 'Desenhar',
                          color: AppColors.accent,
                          onTap: _openDrawingCanvas,
                        ),
                        const SizedBox(width: 6),
                        _buildToolButton(
                          icon: Icons.text_fields_rounded,
                          label: 'Fonte & Estilo',
                          color: AppColors.secondary,
                          onTap: _openFontSelector,
                        ),
                      ],
                    ),
                  ),
                ),

                // Editor Content
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      // Category, Date and Emoji Header
                      Row(
                        children: [
                          EmojiPickerBar(
                            selectedEmoji: _emoji,
                            onEmojiSelected: (emoji) {
                              setState(() {
                                _emoji = emoji;
                                _isModified = true;
                              });
                            },
                          ),
                          const SizedBox(width: 10),
                          _buildCategoryDropdown(isDark),
                          const Spacer(),
                          Text(
                            DateFormatter.formatFullDate(widget.initialNote?.updatedAt ?? DateTime.now()),
                            style: TextStyle(
                              fontSize: 11.5,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // AI Summary Box (if present)
                      if (_aiSummary != null && _aiSummary!.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.primary.withOpacity(0.25)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.auto_awesome, size: 16, color: AppColors.primary),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'Resumo Gerado por IA',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    icon: const Icon(Icons.close, size: 14),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () => setState(() => _aiSummary = null),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _aiSummary!,
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.4,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Drawings Preview Area (if present)
                      if (_drawingPoints.isNotEmpty) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.draw_outlined, size: 16, color: AppColors.accent),
                                SizedBox(width: 6),
                                Text(
                                  'Rascunho / Desenho',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                TextButton.icon(
                                  onPressed: _openDrawingCanvas,
                                  icon: const Icon(Icons.edit, size: 14),
                                  label: const Text('Editar'),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, size: 16, color: AppColors.error),
                                  onPressed: () => setState(() {
                                    _drawingPoints.clear();
                                    _isModified = true;
                                  }),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: _openDrawingCanvas,
                          child: DrawingThumbnailWidget(points: _drawingPoints, height: 140),
                        ),
                        const SizedBox(height: 18),
                      ],

                      // Audio Memos Section (if present)
                      if (_audioMemos.isNotEmpty) ...[
                        const Row(
                          children: [
                            Icon(Icons.mic_rounded, size: 16, color: AppColors.error),
                            SizedBox(width: 6),
                            Text(
                              'Gravações de Voz',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ..._audioMemos.map((memo) => _buildAudioMemoCard(memo, isDark)),
                        const SizedBox(height: 18),
                      ],

                      // Title TextField
                      TextField(
                        controller: _titleController,
                        style: FontStyleSelector.getTextStyle(
                          fontFamily: _fontFamily,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: AppStrings.titleHint,
                          hintStyle: FontStyleSelector.getTextStyle(
                            fontFamily: _fontFamily,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          contentPadding: EdgeInsets.zero,
                        ),
                        maxLines: null,
                      ),
                      const SizedBox(height: 8),

                      // Content TextField with Dynamic Typography
                      TextField(
                        controller: _contentController,
                        style: FontStyleSelector.getTextStyle(
                          fontFamily: _fontFamily,
                          fontSize: _fontSize,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: AppStrings.contentHint,
                          hintStyle: FontStyleSelector.getTextStyle(
                            fontFamily: _fontFamily,
                            fontSize: _fontSize,
                            color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          contentPadding: EdgeInsets.zero,
                        ),
                        maxLines: null,
                        minLines: 10,
                        keyboardType: TextInputType.multiline,
                      ),
                      const SizedBox(height: 16),

                      // Tags Section
                      _buildTagsSection(isDark),
                      const SizedBox(height: 20),

                      // Color Picker Section
                      Text(
                        AppStrings.colorLabel,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ColorPickerPalette(
                        selectedColorIndex: _colorIndex,
                        onColorSelected: (index) {
                          setState(() {
                            _colorIndex = index;
                            _isModified = true;
                          });
                        },
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),

                // Bottom Status Bar
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black.withOpacity(0.2) : Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$wordCount ${AppStrings.wordsCount} • $charCount ${AppStrings.charsCount} • $_fontFamily (${_fontSize.toInt()}px)',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                      if (_isModified)
                        const Row(
                          children: [
                            Icon(Icons.circle, size: 8, color: AppColors.warning),
                            SizedBox(width: 4),
                            Text(
                              'Alterações não salvas',
                              style: TextStyle(fontSize: 11, color: AppColors.warning),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool isHighlight = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isHighlight ? color.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: isHighlight ? Border.all(color: color.withOpacity(0.4)) : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAudioMemoCard(AudioMemo memo, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.play_arrow_rounded, color: AppColors.error, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      memo.title,
                      style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'Duração: ${memo.formattedDuration}',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                onPressed: () {
                  setState(() {
                    _audioMemos.removeWhere((m) => m.id == memo.id);
                    _isModified = true;
                  });
                },
              ),
            ],
          ),
          if (memo.transcript != null) ...[
            const SizedBox(height: 6),
            Text(
              memo.transcript!,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                height: 1.35,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown(bool isDark) {
    final currentCat = NoteCategory.getCategoryById(_categoryId);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: currentCat.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _categoryId,
          isDense: true,
          icon: Icon(Icons.arrow_drop_down, color: currentCat.color, size: 20),
          dropdownColor: isDark ? AppColors.darkCard : AppColors.lightCard,
          items: NoteCategory.defaultCategories.map((category) {
            return DropdownMenuItem<String>(
              value: category.id,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(category.icon, size: 14, color: category.color),
                  const SizedBox(width: 8),
                  Text(
                    category.name,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: category.color,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() {
                _categoryId = val;
                _isModified = true;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildTagsSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            ..._tags.map(
              (tag) => Chip(
                label: Text('#$tag'),
                labelStyle: const TextStyle(fontSize: 12),
                deleteIcon: const Icon(Icons.close, size: 14),
                onDeleted: () => _removeTag(tag),
                backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 4),
              ),
            ),
            SizedBox(
              width: 140,
              height: 32,
              child: TextField(
                controller: _tagInputController,
                style: const TextStyle(fontSize: 12),
                decoration: InputDecoration(
                  hintText: '+ Adicionar tag',
                  hintStyle: TextStyle(
                    fontSize: 12,
                    color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                    ),
                  ),
                ),
                onSubmitted: _addTag,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
