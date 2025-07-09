import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/stroke_provider.dart';

/// 드로잉 컨트롤 버튼들
class ControlButtons extends ConsumerWidget {
  const ControlButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strokes = ref.watch(strokesProvider);
    final notifier = ref.read(strokesProvider.notifier);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Undo 버튼
          ElevatedButton.icon(
            onPressed: strokes.isNotEmpty ? () => notifier.undo() : null,
            icon: const Icon(Icons.undo, size: 18),
            label: const Text('Undo', style: TextStyle(fontSize: 14)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: const Size(80, 36),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Clear 버튼
          ElevatedButton.icon(
            onPressed: strokes.isNotEmpty ? () => notifier.clear() : null,
            icon: const Icon(Icons.clear, size: 18),
            label: const Text('Clear', style: TextStyle(fontSize: 14)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: const Size(80, 36),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Stroke 개수 표시
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              'Strokes: ${strokes.length}',
              style: TextStyle(
                fontFamily: 'LGEIHeadline',
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 