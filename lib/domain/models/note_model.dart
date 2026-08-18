import 'audio_memo.dart';
import 'drawing_point.dart';

class NoteModel {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPinned;
  final int colorIndex;
  final String categoryId;
  final List<String> tags;
  final String? aiSummary;
  final String? emoji;
  final String fontFamily;
  final double fontSize;
  final List<DrawingPoint> drawingPoints;
  final List<AudioMemo> audioMemos;

  const NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.isPinned = false,
    this.colorIndex = 0,
    this.categoryId = 'geral',
    this.tags = const [],
    this.aiSummary,
    this.emoji,
    this.fontFamily = 'Inter',
    this.fontSize = 15.5,
    this.drawingPoints = const [],
    this.audioMemos = const [],
  });

  int get wordCount {
    if (content.trim().isEmpty) return 0;
    return content.trim().split(RegExp(r'\s+')).length;
  }

  int get charCount => content.length;

  bool get hasDrawings => drawingPoints.isNotEmpty;
  bool get hasAudio => audioMemos.isNotEmpty;

  String get previewContent {
    if (content.length > 120) {
      return '${content.substring(0, 120).trim()}...';
    }
    return content;
  }

  NoteModel copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPinned,
    int? colorIndex,
    String? categoryId,
    List<String>? tags,
    String? aiSummary,
    String? emoji,
    String? fontFamily,
    double? fontSize,
    List<DrawingPoint>? drawingPoints,
    List<AudioMemo>? audioMemos,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPinned: isPinned ?? this.isPinned,
      colorIndex: colorIndex ?? this.colorIndex,
      categoryId: categoryId ?? this.categoryId,
      tags: tags ?? this.tags,
      aiSummary: aiSummary ?? this.aiSummary,
      emoji: emoji ?? this.emoji,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      drawingPoints: drawingPoints ?? this.drawingPoints,
      audioMemos: audioMemos ?? this.audioMemos,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isPinned': isPinned,
      'colorIndex': colorIndex,
      'categoryId': categoryId,
      'tags': tags,
      'aiSummary': aiSummary,
      'emoji': emoji,
      'fontFamily': fontFamily,
      'fontSize': fontSize,
      'drawingPoints': drawingPoints.map((d) => d.toMap()).toList(),
      'audioMemos': audioMemos.map((a) => a.toMap()).toList(),
    };
  }

  factory NoteModel.fromMap(Map<dynamic, dynamic> map) {
    List<DrawingPoint> parsedDrawings = [];
    if (map['drawingPoints'] is List) {
      for (var item in (map['drawingPoints'] as List)) {
        if (item is Map) {
          parsedDrawings.add(DrawingPoint.fromMap(item));
        }
      }
    }

    List<AudioMemo> parsedAudio = [];
    if (map['audioMemos'] is List) {
      for (var item in (map['audioMemos'] as List)) {
        if (item is Map) {
          parsedAudio.add(AudioMemo.fromMap(item));
        }
      }
    }

    return NoteModel(
      id: (map['id'] as String?) ?? '',
      title: (map['title'] as String?) ?? '',
      content: (map['content'] as String?) ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isPinned: (map['isPinned'] as bool?) ?? false,
      colorIndex: (map['colorIndex'] as num?)?.toInt() ?? 0,
      categoryId: (map['categoryId'] as String?) ?? 'geral',
      tags: (map['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      aiSummary: map['aiSummary'] as String?,
      emoji: map['emoji'] as String?,
      fontFamily: (map['fontFamily'] as String?) ?? 'Inter',
      fontSize: (map['fontSize'] as num?)?.toDouble() ?? 15.5,
      drawingPoints: parsedDrawings,
      audioMemos: parsedAudio,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoteModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
