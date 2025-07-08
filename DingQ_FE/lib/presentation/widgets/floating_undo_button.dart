import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/stroke_provider.dart';
import '../providers/dingbat_provider.dart';
import 'drawing_canvas.dart';

/// Circular Undo button
class FloatingUndoButton extends ConsumerWidget {
  final GlobalKey? canvasKey;
  
  const FloatingUndoButton({super.key, this.canvasKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strokes = ref.watch(strokesProvider);
    final strokesNotifier = ref.read(strokesProvider.notifier);
    final recommendedDingbatsNotifier = ref.read(recommendedDingbatsProvider.notifier);
    final effectiveCanvasKey = canvasKey ?? (context.findAncestorStateOfType<DrawingCanvasState>()?.canvasKey) ?? GlobalKey();

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: strokes.isNotEmpty 
            ? Colors.black 
            : Colors.grey.shade400,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: strokes.isNotEmpty
              ? () {
                  strokesNotifier.undo();
                  // 상태 업데이트를 기다리기 위해 약간의 지연 추가
                  Future.delayed(const Duration(milliseconds: 10), () {
                    final updatedStrokes = ref.read(strokesProvider);
                    if (updatedStrokes.isEmpty) {
                      recommendedDingbatsNotifier.clearRecommendedDingbats();
                    } else {
                      DrawingCanvasUtils.sendToApi(
                        canvasKey: effectiveCanvasKey,
                        ref: ref,
                        strokes: List.from(updatedStrokes),
                      );
                    }
                  });
                }
              : null,
          borderRadius: BorderRadius.circular(28),
          child: Center(
            child: Icon(
              Icons.undo,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
} 