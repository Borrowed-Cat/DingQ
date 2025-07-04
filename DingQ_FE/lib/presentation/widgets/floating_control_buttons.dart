import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/stroke_provider.dart';

/// 캔버스 위에 floating 형태로 떠있는 컨트롤 버튼들
class FloatingControlButtons extends ConsumerWidget {
  const FloatingControlButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strokes = ref.watch(strokesProvider);
    final notifier = ref.read(strokesProvider.notifier);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Undo 버튼
          _buildFloatingButton(
            onPressed: strokes.isNotEmpty ? () => notifier.undo() : null,
            icon: Icons.undo,
            label: 'Undo',
            color: Colors.blue.shade600,
          ),
          
          const SizedBox(width: 8),
          
          // Clear 버튼
          _buildFloatingButton(
            onPressed: strokes.isNotEmpty ? () => notifier.clear() : null,
            icon: Icons.clear,
            label: 'Clear',
            color: Colors.red.shade600,
          ),
          
          const SizedBox(width: 8),
          
          // Stroke 개수 표시
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              '${strokes.length}',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Floating 버튼 위젯 생성
  Widget _buildFloatingButton({
    required VoidCallback? onPressed,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: onPressed != null ? color : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(8),
        boxShadow: onPressed != null
            ? [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: onPressed != null ? Colors.white : Colors.grey.shade500,
                ),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: onPressed != null ? Colors.white : Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 