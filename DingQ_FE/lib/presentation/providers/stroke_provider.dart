import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/stroke.dart';
import '../../data/repositories/stroke_repository_impl.dart';
import '../../application/usecases/stroke_usecases.dart';

/// Stroke repository provider
final strokeRepositoryProvider = Provider<StrokeRepositoryImpl>((ref) {
  return StrokeRepositoryImpl();
});

/// Providers for stroke-related use cases
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

/// State notifier for managing strokes
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

  /// Refresh state
  void _refreshState() {
    state = _getStrokesUseCase();
  }

  /// Add a new stroke
  void addStroke(Stroke stroke) {
    _addStrokeUseCase(stroke);
    _refreshState();
  }

  /// Remove the most recent stroke (Undo)
  void undo() {
    _undoStrokeUseCase();
    _refreshState();
  }

  /// Remove all strokes (Clear)
  void clear() {
    _clearStrokesUseCase();
    _refreshState();
  }

  /// Return the current number of strokes
  int get strokeCount => state.length;

  /// Check if strokes are empty
  bool get isEmpty => state.isEmpty;
}

/// Provider for managing stroke state
final strokesProvider = StateNotifierProvider<StrokesNotifier, List<Stroke>>((ref) {
  return StrokesNotifier(
    addStrokeUseCase: ref.watch(addStrokeUseCaseProvider),
    undoStrokeUseCase: ref.watch(undoStrokeUseCaseProvider),
    clearStrokesUseCase: ref.watch(clearStrokesUseCaseProvider),
    getStrokesUseCase: ref.watch(getStrokesUseCaseProvider),
  );
}); 