import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/drawing_canvas.dart';
import '../widgets/floating_undo_button.dart';
import '../widgets/floating_clear_button.dart';
import '../widgets/dingbat_grid.dart';

/// Main home page
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                
                // Right: drawing canvas (half)
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Stack(
                      children: [
                        // Drawing canvas area
                        const DrawingCanvas(),
                        
                        // Undo button (bottom left)
                        const Positioned(
                          left: 20,
                          bottom: 20,
                          child: FloatingUndoButton(),
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
                
                // Bottom: drawing canvas (half)
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Stack(
                      children: [
                        // Drawing canvas area
                        const DrawingCanvas(),
                        
                        // Undo button (bottom left)
                        const Positioned(
                          left: 20,
                          bottom: 20,
                          child: FloatingUndoButton(),
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
                ),
              ],
            );
          }
        },
      ),
    );
  }
} 