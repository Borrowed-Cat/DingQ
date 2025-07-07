import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/drawing_canvas.dart';
import '../widgets/floating_undo_button.dart';
import '../widgets/floating_clear_button.dart';
import '../widgets/dingbat_grid.dart';
import '../widgets/recommended_dingbats_display.dart';

/// Main home page
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  GlobalKey? _canvasKey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'DingQ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue.shade700,
        elevation: 2,
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Determine layout based on screen width
          final isWideScreen = constraints.maxWidth > 800;
          
          if (isWideScreen) {
            // Wide screen: left-right split
            return Row(
              children: [
                // Left: dingbat grid (half)
                Expanded(
                  flex: 1,
                  child: const DingbatGrid(),
                ),
                
                // Right: drawing canvas and recommendations (half)
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Top: drawing canvas area
                        Expanded(
                          flex: 3,
                          child: Stack(
                            children: [
                              DrawingCanvas(
                                onCanvasKeyCreated: (key) {
                                  setState(() {
                                    _canvasKey = key;
                                  });
                                },
                              ),
                              
                              // Undo button (bottom left)
                              Positioned(
                                left: 20,
                                bottom: 20,
                                child: FloatingUndoButton(canvasKey: _canvasKey),
                              ),
                              
                              // Clear button (next to undo button)
                              const Positioned(
                                left: 88,
                                bottom: 20,
                                child: FloatingClearButton(),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Bottom: recommended dingbats
                        Expanded(
                          flex: 2,
                          child: const RecommendedDingbatsDisplay(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else {
            // Narrow screen: top-bottom split
            return Column(
              children: [
                // Top: dingbat grid (half)
                Expanded(
                  flex: 1,
                  child: const DingbatGrid(),
                ),
                
                // Bottom: drawing canvas and recommendations (half)
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Left: drawing canvas area
                        Expanded(
                          flex: 3,
                          child: Stack(
                            children: [
                              DrawingCanvas(
                                onCanvasKeyCreated: (key) {
                                  setState(() {
                                    _canvasKey = key;
                                  });
                                },
                              ),
                              
                              // Undo button (bottom left)
                              Positioned(
                                left: 20,
                                bottom: 20,
                                child: FloatingUndoButton(canvasKey: _canvasKey),
                              ),
                              
                              // Clear button (next to undo button)
                              const Positioned(
                                left: 88,
                                bottom: 20,
                                child: FloatingClearButton(),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(width: 16),
                        
                        // Right: recommended dingbats
                        Expanded(
                          flex: 2,
                          child: const RecommendedDingbatsDisplay(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
} 