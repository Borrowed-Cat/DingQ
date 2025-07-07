import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/stroke.dart';
import '../../domain/entities/stroke_bounds.dart';
import '../../data/services/image_service.dart';
import '../providers/stroke_provider.dart';

/// Drawing canvas widget
class DrawingCanvas extends ConsumerStatefulWidget {
  const DrawingCanvas({super.key});

  @override
  ConsumerState<DrawingCanvas> createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends ConsumerState<DrawingCanvas> {
  Stroke? _currentStroke;
  bool _isDrawing = false;
  final GlobalKey _canvasKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final strokes = ref.watch(strokesProvider);

    return RepaintBoundary(
      key: _canvasKey,
      child: GestureDetector(
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
      ),
    );
  }

  /// Start drawing
  void _onPanStart(DragStartDetails details) {
    setState(() {
      _isDrawing = true;
      _currentStroke = Stroke(
        points: [details.localPosition],
        color: Colors.black,
        strokeWidth: 18.0,
      );
    });
  }

  /// Drawing in progress
  void _onPanUpdate(DragUpdateDetails details) {
    if (_isDrawing && _currentStroke != null) {
      setState(() {
        _currentStroke = _currentStroke!.addPoint(details.localPosition);
      });
    }
  }

  /// End drawing
  void _onPanEnd(DragEndDetails details) async {
    if (_isDrawing && _currentStroke != null && _currentStroke!.isValid) {
      // Add stroke
      ref.read(strokesProvider.notifier).addStroke(_currentStroke!);
      
      // Calculate bounds for all strokes
      final allStrokes = ref.read(strokesProvider);
      final bounds = StrokeBounds.calculateBounds(allStrokes);
      
      if (bounds != null) {
        // Save image
        await ImageService.saveCanvasAsPng(_canvasKey, bounds);
      }
    }
    
    setState(() {
      _isDrawing = false;
      _currentStroke = null;
    });
  }
}

/// CustomPainter responsible for canvas drawing
class _CanvasPainter extends CustomPainter {
  final List<Stroke> strokes;
  final Stroke? currentStroke;

  _CanvasPainter({
    required this.strokes,
    this.currentStroke,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw completed strokes
    for (final stroke in strokes) {
      _drawStroke(canvas, stroke);
    }

    // Draw current stroke being drawn
    if (currentStroke != null && currentStroke!.isValid) {
      _drawStroke(canvas, currentStroke!);
    }
  }

  /// Draw individual stroke
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
    return true; // Always repaint (can be optimized for performance if needed)
  }
} 