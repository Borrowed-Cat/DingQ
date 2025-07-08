import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/drawing_canvas.dart';
import '../widgets/floating_undo_button.dart';
import '../widgets/floating_clear_button.dart';
import '../widgets/dingbat_grid.dart';
import '../widgets/recommended_dingbats_display.dart';
import '../widgets/floating_genai_button.dart';
import '../widgets/tag_filter.dart';

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
      backgroundColor: Colors.grey.shade300,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Determine layout based on screen width
          final isWideScreen = constraints.maxWidth > 800;
          
          if (isWideScreen) {
            // Wide screen: TagFilter at top, then left-right split
            return Column(
              children: [
                // Top: DingQ title
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'DingQ',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                
                // TagFilter
                const TagFilter(),
                
                // Bottom: Main content area
                Expanded(
                  child: Row(
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
                          padding: const EdgeInsets.fromLTRB(8, 8, 16, 16),
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
                                    
                                    // GenAI button (bottom right)
                                    const Positioned(
                                      right: 20,
                                      bottom: 20,
                                      child: FloatingGenAIButton(),
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
                  ),
                ),
              ],
            );
          } else {
            // Narrow screen: TagFilter at top, then top-bottom split
            return Column(
              children: [
                // Top: DingQ title
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'DingQ',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                
                // TagFilter
                const TagFilter(),
                
                // Bottom: Main content area
                Expanded(
                  child: Column(
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
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
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
                                    
                                    // GenAI button (bottom right)
                                    const Positioned(
                                      right: 20,
                                      bottom: 20,
                                      child: FloatingGenAIButton(),
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