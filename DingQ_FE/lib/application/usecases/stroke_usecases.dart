import '../../domain/entities/stroke.dart';
import '../../domain/repositories/stroke_repository.dart';

/// Stroke 추가 유스케이스
class AddStrokeUseCase {
  final StrokeRepository _repository;

  const AddStrokeUseCase(this._repository);

  /// 유효한 Stroke를 리포지토리에 추가
  void call(Stroke stroke) {
    if (stroke.isValid) {
      _repository.addStroke(stroke);
    }
  }
}

/// Stroke Undo 유스케이스
class UndoStrokeUseCase {
  final StrokeRepository _repository;

  const UndoStrokeUseCase(this._repository);

  /// 가장 최근 Stroke를 제거
  void call() {
    _repository.undo();
  }
}

/// 모든 Stroke Clear 유스케이스
class ClearStrokesUseCase {
  final StrokeRepository _repository;

  const ClearStrokesUseCase(this._repository);

  /// 모든 Stroke를 제거
  void call() {
    _repository.clear();
  }
}

/// Stroke 목록 조회 유스케이스
class GetStrokesUseCase {
  final StrokeRepository _repository;

  const GetStrokesUseCase(this._repository);

  /// 모든 Stroke 목록을 반환
  List<Stroke> call() {
    return _repository.strokes;
  }
} 