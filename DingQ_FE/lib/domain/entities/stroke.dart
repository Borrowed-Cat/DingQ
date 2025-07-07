import 'package:flutter/material.dart';
import 'dart:math';

/// Stroke entity representing a single line drawn by the user
class Stroke {
  final List<Offset> points;
  final Color color;
  final double strokeWidth;

  const Stroke({
    required this.points,
    this.color = Colors.black,
    this.strokeWidth = 3.0,
  });

  /// Create empty stroke
  factory Stroke.empty() => const Stroke(points: []);

  /// Create stroke with new point added
  Stroke addPoint(Offset point) {
    final newPoints = List<Offset>.from(points)..add(point);
    return Stroke(
      points: newPoints,
      color: color,
      strokeWidth: strokeWidth,
    );
  }

  /// Check if stroke is valid (must have at least 2 points)
  bool get isValid => points.length >= 2;

  /// Calculate stroke bounds (x, y min/max values)
  Rect? getBounds() {
    if (points.isEmpty) return null;
    
    double minX = points.first.dx;
    double maxX = points.first.dx;
    double minY = points.first.dy;
    double maxY = points.first.dy;
    
    for (final point in points) {
      minX = min(minX, point.dx);
      maxX = max(maxX, point.dx);
      minY = min(minY, point.dy);
      maxY = max(maxY, point.dy);
    }
    
    // Expand bounds considering stroke width
    final halfWidth = strokeWidth / 2;
    return Rect.fromLTRB(
      minX - halfWidth,
      minY - halfWidth,
      maxX + halfWidth,
      maxY + halfWidth,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Stroke &&
        other.points.length == points.length &&
        other.color == color &&
        other.strokeWidth == strokeWidth;
  }

  @override
  int get hashCode => Object.hash(
        Object.hashAll(points),
        color,
        strokeWidth,
      );

  @override
  String toString() => 'Stroke(points: ${points.length}, color: $color, width: $strokeWidth)';
} 