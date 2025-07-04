import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/stroke_provider.dart';

/// 원형 Undo 버튼
class FloatingUndoButton extends ConsumerWidget {
  const FloatingUndoButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strokes = ref.watch(strokesProvider);
    final notifier = ref.read(strokesProvider.notifier);

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: strokes.isNotEmpty 
            ? Colors.blue.shade600 
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
          onTap: strokes.isNotEmpty ? () => notifier.undo() : null,
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