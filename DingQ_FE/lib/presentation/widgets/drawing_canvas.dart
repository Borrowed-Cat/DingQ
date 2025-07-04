import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/stroke.dart';
import '../providers/stroke_provider.dart';

/// 드로잉 캔버스 위젯
class DrawingCanvas extends ConsumerStatefulWidget {
  const DrawingCanvas({super.key});

  @override
  ConsumerState<DrawingCanvas> createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends ConsumerState<DrawingCanvas> {
  Stroke? _currentStroke;
  bool _isDrawing = false;

  @override
  Widget build(BuildContext context) {
    final strokes = ref.watch(strokesProvider);

    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade200.withOpacity(0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: CustomPaint(
          painter: _CanvasPainter(
            strokes: strokes,
            currentStroke: _currentStroke,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }

  /// 드로잉 시작
  void _onPanStart(DragStartDetails details) {
    setState(() {
      _isDrawing = true;
      _currentStroke = Stroke(
        points: [details.localPosition],
        color: Colors.black,
        strokeWidth: 3.0,
      );
    });
  }

  /// 드로잉 중
  void _onPanUpdate(DragUpdateDetails details) {
    if (_isDrawing && _currentStroke != null) {
      setState(() {
        _currentStroke = _currentStroke!.addPoint(details.localPosition);
      });
    }
  }

  /// 드로잉 종료
  void _onPanEnd(DragEndDetails details) {
    if (_isDrawing && _currentStroke != null && _currentStroke!.isValid) {
      ref.read(strokesProvider.notifier).addStroke(_currentStroke!);
    }
    
    setState(() {
      _isDrawing = false;
      _currentStroke = null;
    });
  }
}

/// 캔버스 그리기 담당 CustomPainter
class _CanvasPainter extends CustomPainter {
  final List<Stroke> strokes;
  final Stroke? currentStroke;

  _CanvasPainter({
    required this.strokes,
    this.currentStroke,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 완성된 Stroke들 그리기
    for (final stroke in strokes) {
      _drawStroke(canvas, stroke);
    }

    // 현재 그리는 중인 Stroke 그리기
    if (currentStroke != null && currentStroke!.isValid) {
      _drawStroke(canvas, currentStroke!);
    }
  }

  /// 개별 Stroke 그리기
  void _drawStroke(Canvas canvas, Stroke stroke) {
    if (stroke.points.length < 2) return;

    final paint = Paint()
      ..color = stroke.color
      ..strokeWidth = stroke.strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(stroke.points.first.dx, stroke.points.first.dy);

    for (int i = 1; i < stroke.points.length; i++) {
      path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // 항상 다시 그리기 (성능 최적화 필요시 개선 가능)
  }
} 