import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/stroke_provider.dart';

/// 원형 Clear 버튼
class FloatingClearButton extends ConsumerWidget {
  const FloatingClearButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strokes = ref.watch(strokesProvider);
    final notifier = ref.read(strokesProvider.notifier);

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: strokes.isNotEmpty 
            ? Colors.red.shade600 
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
          onTap: strokes.isNotEmpty ? () => notifier.clear() : null,
          borderRadius: BorderRadius.circular(28),
          child: Center(
            child: Icon(
              Icons.clear,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
} 