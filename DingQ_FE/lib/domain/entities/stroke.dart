import 'package:flutter/material.dart';

/// 사용자가 그린 한 번의 선을 나타내는 엔티티
class Stroke {
  final List<Offset> points;
  final Color color;
  final double strokeWidth;

  const Stroke({
    required this.points,
    this.color = Colors.black,
    this.strokeWidth = 3.0,
  });

  /// 빈 Stroke 생성
  factory Stroke.empty() => const Stroke(points: []);

  /// 새로운 점을 추가한 Stroke 생성
  Stroke addPoint(Offset point) {
    final newPoints = List<Offset>.from(points)..add(point);
    return Stroke(
      points: newPoints,
      color: color,
      strokeWidth: strokeWidth,
    );
  }

  /// Stroke가 유효한지 확인 (최소 2개 이상의 점이 있어야 함)
  bool get isValid => points.length >= 2;

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