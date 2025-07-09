import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../providers/genai_provider.dart';
import '../../data/services/image_service.dart';
import '../../domain/entities/stroke.dart';

/// Circular Generative AI button with animated text field on hover
class FloatingGenAIButton extends ConsumerStatefulWidget {
  final GlobalKey? canvasKey;
  final List<Stroke>? strokes;
  
  const FloatingGenAIButton({
    super.key, 
    this.canvasKey,
    this.strokes,
  });

  @override
  ConsumerState<FloatingGenAIButton> createState() => _FloatingGenAIButtonState();
}

class _FloatingGenAIButtonState extends ConsumerState<FloatingGenAIButton> {
  bool _hovering = false;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Calculate stroke bounds for export
  Rect? _calculateStrokeBounds() {
    final strokes = widget.strokes;
    if (strokes == null || strokes.isEmpty) return null;
    
    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = -double.infinity;
    double maxY = -double.infinity;
    
    for (final stroke in strokes) {
      for (final point in stroke.points) {
        minX = math.min(minX, point.dx);
        minY = math.min(minY, point.dy);
        maxX = math.max(maxX, point.dx);
        maxY = math.max(maxY, point.dy);
      }
    }
    
    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  /// Generate AI icon
  Future<void> _generateAIIcon() async {
    final canvasKey = widget.canvasKey;
    final strokes = widget.strokes;
    
    if (canvasKey == null || strokes == null || strokes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please draw something first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final bounds = _calculateStrokeBounds();
    if (bounds == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to calculate drawing bounds'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Get current input values
    final description = _controller.text.trim();
    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a description'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final genAINotifier = ref.read(genAIProvider.notifier);
    
    // Update description in provider
    genAINotifier.setDescription(description);
    
    // Export canvas to PNG
    final pngBytes = await ImageService.exportCanvasToPng(canvasKey, bounds);
    if (pngBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to export canvas image'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Generate AI icon
    try {
      await genAINotifier.generate(pngBytes);
      
      // Check for success/error
      if (mounted) {
        final state = ref.read(genAIProvider);
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('AI 생성 실패: ${state.error}'),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state.result != null) {
          // Show modal with generated images
          genAINotifier.showModal();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류 발생: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onHover(bool hover) {
    setState(() {
      _hovering = hover;
    });
    if (hover) {
      // Slight delay to allow animation before focusing
      Future.delayed(const Duration(milliseconds: 180), () {
        if (mounted && _hovering) {
          _focusNode.requestFocus();
        }
      });
    } else {
      _focusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            width: _hovering ? 240 : 0,
            margin: const EdgeInsets.only(right: 12),
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                if (_hovering)
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
              ],
              border: Border.all(
                color: Colors.purple.shade200,
                width: 1.2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 180),
                opacity: _hovering ? 1.0 : 0.0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Row(
                    children: [
                      // Description text field
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          decoration: const InputDecoration(
                            hintText: '어떤 아이콘을 만들까요?',
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 4),
                          ),
                          style: const TextStyle(fontSize: 12),
                          enabled: _hovering,
                        ),
                      ),
                      
                      // Temperature slider
                      Consumer(
                        builder: (context, ref, child) {
                          final genAIState = ref.watch(genAIProvider);
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '창의성: ${(genAIState.temperature * 100).toInt()}%',
                                style: const TextStyle(
                                  fontSize: 8,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(
                                width: 50,
                                child: SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    trackHeight: 2,
                                    thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 2,
                                    ),
                                    overlayShape: const RoundSliderOverlayShape(
                                      overlayRadius: 4,
                                    ),
                                  ),
                                  child: Slider(
                                    value: genAIState.temperature,
                                    min: 0.0,
                                    max: 1.0,
                                    divisions: 10,
                                    onChanged: _hovering ? (value) {
                                      ref.read(genAIProvider.notifier).setTemperature(value);
                                    } : null,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.purple.shade600,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _generateAIIcon,
                borderRadius: BorderRadius.circular(28),
                child: Center(
                  child: Consumer(
                    builder: (context, ref, child) {
                      final genAIState = ref.watch(genAIProvider);
                      if (genAIState.loading) {
                        return const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        );
                      }
                      return SvgPicture.asset(
                        'assets/dingbats/ai.svg',
                        width: 28,
                        height: 28,
                        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 