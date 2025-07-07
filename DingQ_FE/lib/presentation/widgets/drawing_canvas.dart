import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/image_service.dart';
import '../../domain/entities/stroke.dart';
import '../providers/stroke_provider.dart';
import '../providers/dingbat_provider.dart';

/// Drawing canvas widget
class DrawingCanvas extends ConsumerStatefulWidget {
  final Function(GlobalKey)? onCanvasKeyCreated;
  
  const DrawingCanvas({super.key, this.onCanvasKeyCreated});

  @override
  ConsumerState<DrawingCanvas> createState() => DrawingCanvasState();
}

class DrawingCanvasState extends ConsumerState<DrawingCanvas> {
  final GlobalKey canvasKey = GlobalKey();
  List<Offset> _currentPoints = [];
  bool _isDrawing = false;

  @override
  void initState() {
    super.initState();
    // Call the callback when the canvasKey is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onCanvasKeyCreated?.call(canvasKey);
    });
  }

  @override
  Widget build(BuildContext context) {
    final strokes = ref.watch(strokesProvider);

    return GestureDetector(
      onPanStart: (details) {
        setState(() {
          _isDrawing = true;
          _currentPoints = [details.localPosition];
        });
      },
      onPanUpdate: (details) {
        if (_isDrawing) {
          setState(() {
            _currentPoints.add(details.localPosition);
          });
        }
      },
      onPanEnd: (details) {
        if (_isDrawing && _currentPoints.isNotEmpty) {
          // Add stroke to provider
          final stroke = Stroke(
            points: List.from(_currentPoints),
            color: Colors.black,
            strokeWidth: 18.0,
          );
          ref.read(strokesProvider.notifier).addStroke(stroke);

          // Send to API
          DrawingCanvasUtils.sendToApi(
            canvasKey: canvasKey,
            ref: ref,
            strokes: List.from(ref.read(strokesProvider)),
          );

          setState(() {
            _isDrawing = false;
            _currentPoints = [];
          });
        }
      },
      child: RepaintBoundary(
        key: canvasKey,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.white,
          child: CustomPaint(
            painter: _DrawingPainter(
              strokes: strokes,
              currentPoints: _currentPoints,
              isDrawing: _isDrawing,
            ),
          ),
        ),
      ),
    );
  }
}

class DrawingCanvasUtils {
  static void sendToApi({
    required GlobalKey canvasKey,
    required WidgetRef ref,
    required List<Stroke> strokes,
  }) {
    if (strokes.isEmpty) return;
    final bounds = calculateStrokeBounds(strokes);
    if (bounds == null) return;
    ref.read(recommendedDingbatsProvider.notifier).setLoading(true);
    ImageService.sendCanvasToApi(
      canvasKey,
      bounds,
      onResponse: (response) {
        ref.read(recommendedDingbatsProvider.notifier).setRecommendedDingbats(response);
      },
    );
  }

  static Rect? calculateStrokeBounds(List<Stroke> strokes) {
    if (strokes.isEmpty) return null;
    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = -double.infinity;
    double maxY = -double.infinity;
    for (final stroke in strokes) {
      for (final point in stroke.points) {
        minX = min(minX, point.dx);
        minY = min(minY, point.dy);
        maxX = max(maxX, point.dx);
        maxY = max(maxY, point.dy);
      }
    }
    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }
}

/// Custom painter for drawing strokes
class _DrawingPainter extends CustomPainter {
  final List<Stroke> strokes;
  final List<Offset> currentPoints;
  final bool isDrawing;

  _DrawingPainter({
    required this.strokes,
    required this.currentPoints,
    required this.isDrawing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw completed strokes
    for (final stroke in strokes) {
      _drawStroke(canvas, stroke);
    }

    // Draw current stroke being drawn
    if (isDrawing && currentPoints.length > 1) {
      final currentStroke = Stroke(
        points: currentPoints,
        color: Colors.black,
        strokeWidth: 18.0,
      );
      _drawStroke(canvas, currentStroke);
    }
  }

  /// Draw a single stroke
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
} 