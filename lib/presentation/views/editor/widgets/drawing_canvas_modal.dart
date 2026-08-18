import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../domain/models/drawing_point.dart';

class DrawingCanvasModal extends StatefulWidget {
  final List<DrawingPoint> initialPoints;
  final Function(List<DrawingPoint> points) onSave;

  const DrawingCanvasModal({
    super.key,
    required this.initialPoints,
    required this.onSave,
  });

  static void show(
    BuildContext context, {
    required List<DrawingPoint> initialPoints,
    required Function(List<DrawingPoint> points) onSave,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DrawingCanvasModal(
        initialPoints: initialPoints,
        onSave: onSave,
      ),
    );
  }

  @override
  State<DrawingCanvasModal> createState() => _DrawingCanvasModalState();
}

class _DrawingCanvasModalState extends State<DrawingCanvasModal> {
  late List<DrawingPoint> _points;
  final List<List<DrawingPoint>> _history = [];
  Color _selectedColor = AppColors.primary;
  double _strokeWidth = 3.5;
  bool _isEraser = false;

  final List<Color> _palette = const [
    AppColors.primary,
    Color(0xFF8B5CF6), // Violet
    Color(0xFFEC4899), // Pink
    Color(0xFFEF4444), // Red
    Color(0xFFF59E0B), // Amber
    Color(0xFF10B981), // Emerald
    Color(0xFF06B6D4), // Cyan
    Color(0xFF0F172A), // Dark Slate
    Color(0xFFFFFFFF), // White
  ];

  @override
  void initState() {
    super.initState();
    _points = List.from(widget.initialPoints);
  }

  void _saveToHistory() {
    _history.add(List.from(_points));
  }

  void _undo() {
    if (_history.isNotEmpty) {
      setState(() {
        _points = _history.removeLast();
      });
    } else if (_points.isNotEmpty) {
      setState(() {
        _points.clear();
      });
    }
  }

  void _clear() {
    _saveToHistory();
    setState(() {
      _points.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canvasBgColor = isDark ? const Color(0xFF131B2E) : const Color(0xFFF8FAFC);

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Fechar',
                ),
                const SizedBox(width: 8),
                Text(
                  'Quadro de Desenho',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.undo_rounded),
                  onPressed: _points.isNotEmpty || _history.isNotEmpty ? _undo : null,
                  tooltip: 'Desfazer',
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded),
                  onPressed: _points.isNotEmpty ? _clear : null,
                  tooltip: 'Limpar tudo',
                ),
                const SizedBox(width: 6),
                FilledButton.icon(
                  onPressed: () {
                    widget.onSave(_points);
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text('Salvar'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Interactive Drawing Area
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: canvasBgColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: GestureDetector(
                  onPanStart: (details) {
                    _saveToHistory();
                    final renderBox = context.findRenderObject() as RenderBox?;
                    final localPos = details.localPosition;

                    setState(() {
                      _points.add(
                        DrawingPoint(
                          x: localPos.dx,
                          y: localPos.dy,
                          colorValue: _isEraser
                              ? canvasBgColor.value
                              : _selectedColor.value,
                          strokeWidth: _isEraser ? _strokeWidth * 2.5 : _strokeWidth,
                        ),
                      );
                    });
                  },
                  onPanUpdate: (details) {
                    final localPos = details.localPosition;
                    setState(() {
                      _points.add(
                        DrawingPoint(
                          x: localPos.dx,
                          y: localPos.dy,
                          colorValue: _isEraser
                              ? canvasBgColor.value
                              : _selectedColor.value,
                          strokeWidth: _isEraser ? _strokeWidth * 2.5 : _strokeWidth,
                        ),
                      );
                    });
                  },
                  onPanEnd: (details) {
                    setState(() {
                      if (_points.isNotEmpty) {
                        _points.add(
                          DrawingPoint(
                            x: _points.last.x,
                            y: _points.last.y,
                            colorValue: _points.last.colorValue,
                            strokeWidth: _points.last.strokeWidth,
                            isEndOfStroke: true,
                          ),
                        );
                      }
                    });
                  },
                  child: CustomPaint(
                    painter: DrawingPainter(points: _points),
                    size: Size.infinite,
                  ),
                ),
              ),
            ),
          ),

          // Bottom Toolbar: Tools, Sizes & Colors
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              border: Border(
                top: BorderSide(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
            ),
            child: Column(
              children: [
                // Stroke size and tools
                Row(
                  children: [
                    // Pen vs Eraser
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(
                          value: false,
                          icon: Icon(Icons.edit_rounded, size: 16),
                          label: Text('Caneta'),
                        ),
                        ButtonSegment(
                          value: true,
                          icon: Icon(Icons.auto_fix_normal_rounded, size: 16),
                          label: Text('Borracha'),
                        ),
                      ],
                      selected: {_isEraser},
                      onSelectionChanged: (val) {
                        setState(() {
                          _isEraser = val.first;
                        });
                      },
                      style: ButtonStyle(
                        visualDensity: VisualDensity.compact,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Stroke size chips
                    _buildSizeButton(2.0, 'Fino'),
                    const SizedBox(width: 6),
                    _buildSizeButton(4.5, 'Médio'),
                    const SizedBox(width: 6),
                    _buildSizeButton(10.0, 'Marcador'),
                  ],
                ),
                const SizedBox(height: 12),

                // Color Palette Selector
                if (!_isEraser)
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _palette.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final color = _palette[index];
                        final isSelected = _selectedColor == color;

                        return GestureDetector(
                          onTap: () => setState(() => _selectedColor = color),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : (isDark ? Colors.white24 : Colors.black26),
                                width: isSelected ? 3 : 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: color.withOpacity(0.5),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: isSelected
                                ? Icon(
                                    Icons.check,
                                    size: 16,
                                    color: color.computeLuminance() > 0.5
                                        ? Colors.black
                                        : Colors.white,
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSizeButton(double size, String label) {
    final isSelected = _strokeWidth == size;
    return ChoiceChip(
      label: Text(label, style: const TextStyle(fontSize: 11.5)),
      selected: isSelected,
      onSelected: (_) => setState(() => _strokeWidth = size),
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 6),
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<DrawingPoint> points;

  DrawingPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i].isEndOfStroke) continue;
      if (points[i + 1].isEndOfStroke) continue;

      final p1 = points[i];
      final p2 = points[i + 1];

      final paint = Paint()
        ..color = p1.color
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = p1.strokeWidth
        ..isAntiAlias = true;

      canvas.drawLine(p1.offset, p2.offset, paint);
    }
  }

  @override
  bool shouldRepaint(covariant DrawingPainter oldDelegate) => true;
}

class DrawingThumbnailWidget extends StatelessWidget {
  final List<DrawingPoint> points;
  final double height;

  const DrawingThumbnailWidget({
    super.key,
    required this.points,
    this.height = 80,
  });

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A).withOpacity(0.6) : Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CustomPaint(
          painter: DrawingPainter(points: points),
          size: Size(double.infinity, height),
        ),
      ),
    );
  }
}
