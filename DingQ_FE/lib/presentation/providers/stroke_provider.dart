import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/stroke.dart';
import '../../data/repositories/stroke_repository_impl.dart';
import '../../application/usecases/stroke_usecases.dart';

/// Stroke 리포지토리 프로바이더
final strokeRepositoryProvider = Provider<StrokeRepositoryImpl>((ref) {
  return StrokeRepositoryImpl();
});

/// Stroke 관련 유스케이스 프로바이더들
final addStrokeUseCaseProvider = Provider<AddStrokeUseCase>((ref) {
  final repository = ref.watch(strokeRepositoryProvider);
  return AddStrokeUseCase(repository);
});

final undoStrokeUseCaseProvider = Provider<UndoStrokeUseCase>((ref) {
  final repository = ref.watch(strokeRepositoryProvider);
  return UndoStrokeUseCase(repository);
});

final clearStrokesUseCaseProvider = Provider<ClearStrokesUseCase>((ref) {
  final repository = ref.watch(strokeRepositoryProvider);
  return ClearStrokesUseCase(repository);
});

final getStrokesUseCaseProvider = Provider<GetStrokesUseCase>((ref) {
  final repository = ref.watch(strokeRepositoryProvider);
  return GetStrokesUseCase(repository);
});

/// Stroke 상태 관리 Notifier
class StrokesNotifier extends StateNotifier<List<Stroke>> {
  final AddStrokeUseCase _addStrokeUseCase;
  final UndoStrokeUseCase _undoStrokeUseCase;
  final ClearStrokesUseCase _clearStrokesUseCase;
  final GetStrokesUseCase _getStrokesUseCase;

  StrokesNotifier({
    required AddStrokeUseCase addStrokeUseCase,
    required UndoStrokeUseCase undoStrokeUseCase,
    required ClearStrokesUseCase clearStrokesUseCase,
    required GetStrokesUseCase getStrokesUseCase,
  })  : _addStrokeUseCase = addStrokeUseCase,
        _undoStrokeUseCase = undoStrokeUseCase,
        _clearStrokesUseCase = clearStrokesUseCase,
        _getStrokesUseCase = getStrokesUseCase,
        super([]) {
    _refreshState();
  }

  /// 상태 새로고침
  void _refreshState() {
    state = _getStrokesUseCase();
  }

  /// 새로운 Stroke 추가
  void addStroke(Stroke stroke) {
    _addStrokeUseCase(stroke);
    _refreshState();
  }

  /// 가장 최근 Stroke 제거 (Undo)
  void undo() {
    _undoStrokeUseCase();
    _refreshState();
  }

  /// 모든 Stroke 제거 (Clear)
  void clear() {
    _clearStrokesUseCase();
    _refreshState();
  }

  /// 현재 Stroke 개수 반환
  int get strokeCount => state.length;

  /// Stroke가 비어있는지 확인
  bool get isEmpty => state.isEmpty;
}

/// Stroke 상태 관리 프로바이더
final strokesProvider = StateNotifierProvider<StrokesNotifier, List<Stroke>>((ref) {
  return StrokesNotifier(
    addStrokeUseCase: ref.watch(addStrokeUseCaseProvider),
    undoStrokeUseCase: ref.watch(undoStrokeUseCaseProvider),
    clearStrokesUseCase: ref.watch(clearStrokesUseCaseProvider),
    getStrokesUseCase: ref.watch(getStrokesUseCaseProvider),
  );
}); 