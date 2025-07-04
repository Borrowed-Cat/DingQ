import '../../domain/entities/stroke.dart';
import '../../domain/repositories/stroke_repository.dart';

/// Stroke 리포지토리의 메모리 기반 구현체
class StrokeRepositoryImpl implements StrokeRepository {
  final List<Stroke> _strokes = [];

  @override
  List<Stroke> get strokes => List.unmodifiable(_strokes);

  @override
  void addStroke(Stroke stroke) {
    if (stroke.isValid) {
      _strokes.add(stroke);
    }
  }

  @override
  void undo() {
    if (_strokes.isNotEmpty) {
      _strokes.removeLast();
    }
  }

  @override
  void clear() {
    _strokes.clear();
  }

  @override
  bool get isEmpty => _strokes.isEmpty;

  @override
  int get length => _strokes.length;
} 