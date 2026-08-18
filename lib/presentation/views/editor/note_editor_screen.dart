import 'dart:ui';
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
import 'widgets/ios_action_sheet_menu.dart';

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
  double _fontSize = 16.0;
  List<DrawingPoint> _drawingPoints = [];
  List<AudioMemo> _audioMemos = [];
  late DateTime _createdAt;

  bool _isModified = false;

  @override
  void initState() {
    super.initState();
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
    _fontSize = note?.fontSize ?? 16.0;
    _drawingPoints = List.from(note?.drawingPoints ?? []);
    _audioMemos = List.from(note?.audioMemos ?? []);
    _createdAt = note?.createdAt ?? DateTime.now();

    _titleController.addListener(_markModified);
    _contentController.addListener(_markModified);
  }

  void _markModified() {
    if (!_isModified) {
      setState(() => _isModified = true);
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

  Future<void> _saveNoteSilently({bool pop = false}) async {
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
    if (pop && mounted) Navigator.of(context).pop();
  }

  void _openIOSMenu() {
    IOSActionSheetMenu.show(
      context,
      isPinned: _isPinned,
      onTogglePin: () {
        setState(() {
          _isPinned = !_isPinned;
          _isModified = true;
        });
      },
      onOpenAI: _openAIAssistant,
      onOpenAudio: _openAudioRecorder,
      onOpenDrawing: _openDrawingCanvas,
      onOpenTypography: _openFontSelector,
      onOpenColorPalette: _openColorPickerModal,
      onOpenTags: _openTagsModal,
      onDelete: () {
        if (widget.initialNote != null) {
          ConfirmationDialog.show(
            context,
            onConfirm: () async {
              await context.read<NotesController>().deleteNote(widget.initialNote!.id);
              if (mounted) Navigator.of(context).pop();
            },
          );
        } else {
          Navigator.of(context).pop();
        }
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

  void _openColorPickerModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Cor de Fundo da Nota', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              ColorPickerPalette(
                selectedColorIndex: _colorIndex,
                onColorSelected: (idx) {
                  setState(() {
                    _colorIndex = idx;
                    _isModified = true;
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _openTagsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: EdgeInsets.only(
              top: 20,
              left: 20,
              right: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tags & Categorias', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 14),
                _buildCategoryPicker(isDark),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    ..._tags.map(
                      (tag) => Chip(
                        label: Text('#$tag'),
                        deleteIcon: const Icon(Icons.close, size: 14),
                        onDeleted: () {
                          setState(() => _tags.remove(tag));
                          setModalState(() {});
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _tagInputController,
                  decoration: const InputDecoration(
                    hintText: '+ Digite uma tag e pressione Enter',
                    isDense: true,
                  ),
                  onSubmitted: (tag) {
                    final cleaned = tag.trim().replaceAll('#', '');
                    if (cleaned.isNotEmpty && !_tags.contains(cleaned)) {
                      setState(() => _tags.add(cleaned));
                      _tagInputController.clear();
                      setModalState(() {});
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final safeColorIndex = (_colorIndex < 0 ? 0 : _colorIndex) % AppColors.noteColorsLight.length;

    final bgColor = isDark
        ? AppColors.noteColorsDark[safeColorIndex]
        : AppColors.noteColorsLight[safeColorIndex];

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) _saveNoteSilently(pop: false);
      },
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leadingWidth: 100,
          leading: TextButton.icon(
            onPressed: () => _saveNoteSilently(pop: true),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.primary),
            label: const Text(
              'Notas',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ),
          actions: [
            // iOS ... Circular Action Menu Button
            Container(
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.06),
              ),
              child: IconButton(
                icon: const Icon(Icons.more_horiz_rounded, size: 20, color: AppColors.primary),
                tooltip: 'Opções da Nota',
                onPressed: _openIOSMenu,
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            // Editor Content Area
            Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 840),
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveLayout.getHorizontalPadding(context),
                ),
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(top: 8, bottom: 100),
                  children: [
                    // Top: Notion-style cover emoji (tap to change)
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
                        const SizedBox(width: 8),
                        Text(
                          DateFormatter.formatFullDate(widget.initialNote?.updatedAt ?? DateTime.now()),
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // AI Summary Banner (if present)
                    if (_aiSummary != null && _aiSummary!.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.auto_awesome, size: 16, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _aiSummary!,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  height: 1.35,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 14),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => setState(() => _aiSummary = null),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Drawing Preview (if exists)
                    if (_drawingPoints.isNotEmpty) ...[
                      GestureDetector(
                        onTap: _openDrawingCanvas,
                        child: DrawingThumbnailWidget(points: _drawingPoints, height: 130),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Audio Memos (if exist)
                    if (_audioMemos.isNotEmpty) ...[
                      ..._audioMemos.map((memo) => _buildAudioMemoCard(memo, isDark)),
                      const SizedBox(height: 14),
                    ],

                    // Title Input (Apple Notes clean typography)
                    TextField(
                      controller: _titleController,
                      style: FontStyleSelector.getTextStyle(
                        fontFamily: _fontFamily,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: AppStrings.titleHint,
                        hintStyle: FontStyleSelector.getTextStyle(
                          fontFamily: _fontFamily,
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
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
                    const SizedBox(height: 10),

                    // Body Content Input (Flows naturally like Apple Notes)
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
                      minLines: 12,
                      keyboardType: TextInputType.multiline,
                    ),
                  ],
                ),
              ),
            ),

            // Floating iOS Frosted Glass Accessory Bar
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF2C2C2E).withOpacity(0.85)
                            : Colors.white.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: isDark ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.08),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.4 : 0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildAccessoryIcon(
                            icon: Icons.auto_awesome,
                            color: AppColors.primary,
                            tooltip: 'NotaIA',
                            onTap: _openAIAssistant,
                          ),
                          _buildVerticalDivider(isDark),
                          _buildAccessoryIcon(
                            icon: Icons.mic_rounded,
                            color: AppColors.iosRed,
                            tooltip: 'Gravar Áudio',
                            onTap: _openAudioRecorder,
                          ),
                          _buildAccessoryIcon(
                            icon: Icons.draw_outlined,
                            color: AppColors.iosBlue,
                            tooltip: 'Desenhar',
                            onTap: _openDrawingCanvas,
                          ),
                          _buildAccessoryIcon(
                            icon: Icons.text_fields_rounded,
                            color: AppColors.iosPurple,
                            tooltip: 'Tipografia',
                            onTap: _openFontSelector,
                          ),
                          _buildAccessoryIcon(
                            icon: Icons.palette_outlined,
                            color: AppColors.iosTeal,
                            tooltip: 'Cor',
                            onTap: _openColorPickerModal,
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
      ),
    );
  }

  Widget _buildAccessoryIcon({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return IconButton(
      icon: Icon(icon, color: color, size: 22),
      tooltip: tooltip,
      onPressed: onTap,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    );
  }

  Widget _buildVerticalDivider(bool isDark) {
    return Container(
      height: 20,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: isDark ? Colors.white24 : Colors.black12,
    );
  }

  Widget _buildCategoryPicker(bool isDark) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: NoteCategory.defaultCategories.map((category) {
        final isSelected = _categoryId == category.id;
        return ChoiceChip(
          avatar: Icon(category.icon, size: 14, color: isSelected ? Colors.white : category.color),
          label: Text(category.name),
          selected: isSelected,
          selectedColor: AppColors.primary,
          onSelected: (selected) {
            if (selected) {
              setState(() {
                _categoryId = category.id;
                _isModified = true;
              });
            }
          },
        );
      }).toList(),
    );
  }

  Widget _buildAudioMemoCard(AudioMemo memo, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.iosRed.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.play_arrow_rounded, color: AppColors.iosRed, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(memo.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                Text(
                  '${memo.formattedDuration} • Gravado em áudio',
                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF8E8E93)),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.iosRed),
            onPressed: () {
              setState(() {
                _audioMemos.removeWhere((m) => m.id == memo.id);
                _isModified = true;
              });
            },
          ),
        ],
      ),
    );
  }
}
