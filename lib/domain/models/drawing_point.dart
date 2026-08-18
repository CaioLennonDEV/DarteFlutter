import 'package:flutter/material.dart';

class DrawingPoint {
  final double x;
  final double y;
  final int colorValue;
  final double strokeWidth;
  final bool isEndOfStroke;

  const DrawingPoint({
    required this.x,
    required this.y,
    required this.colorValue,
    this.strokeWidth = 3.0,
    this.isEndOfStroke = false,
  });

  Offset get offset => Offset(x, y);
  Color get color => Color(colorValue);

  Map<String, dynamic> toMap() {
    return {
      'x': x,
      'y': y,
      'c': colorValue,
      'w': strokeWidth,
      'e': isEndOfStroke,
    };
  }

  factory DrawingPoint.fromMap(Map<dynamic, dynamic> map) {
    return DrawingPoint(
      x: (map['x'] as num?)?.toDouble() ?? 0.0,
      y: (map['y'] as num?)?.toDouble() ?? 0.0,
      colorValue: (map['c'] as num?)?.toInt() ?? 0xFF6366F1,
      strokeWidth: (map['w'] as num?)?.toDouble() ?? 3.0,
      isEndOfStroke: (map['e'] as bool?) ?? false,
    );
  }
}
