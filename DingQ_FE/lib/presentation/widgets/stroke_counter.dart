import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/stroke_provider.dart';

/// Stroke 개수를 표시하는 원형 카운터
class StrokeCounter extends ConsumerWidget {
  const StrokeCounter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strokes = ref.watch(strokesProvider);

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          '${strokes.length}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: strokes.isEmpty ? Colors.grey.shade500 : Colors.black87,
          ),
        ),
      ),
    );
  }
} 