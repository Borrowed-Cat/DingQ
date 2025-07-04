import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/drawing_canvas.dart';
import '../widgets/floating_undo_button.dart';
import '../widgets/floating_clear_button.dart';
import '../widgets/dingbat_grid.dart';

/// 메인 홈 페이지
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
          // 화면 너비에 따라 레이아웃 결정
          final isWideScreen = constraints.maxWidth > 800;
          
          if (isWideScreen) {
            // 넓은 화면: 좌우 분할
            return Row(
              children: [
                // 좌측: 딩벳 그리드 (절반)
                Expanded(
                  flex: 1,
                  child: const DingbatGrid(),
                ),
                
                // 우측: 드로잉 캔버스 (절반)
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Stack(
                      children: [
                        // 드로잉 캔버스 영역
                        const DrawingCanvas(),
                        
                        // Undo 버튼 (좌하단)
                        const Positioned(
                          left: 20,
                          bottom: 20,
                          child: FloatingUndoButton(),
                        ),
                        
                        // Clear 버튼 (Undo 버튼 바로 옆)
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
            // 좁은 화면: 상하 분할
            return Column(
              children: [
                // 상단: 딩벳 그리드 (절반)
                Expanded(
                  flex: 1,
                  child: const DingbatGrid(),
                ),
                
                // 하단: 드로잉 캔버스 (절반)
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Stack(
                      children: [
                        // 드로잉 캔버스 영역
                        const DrawingCanvas(),
                        
                        // Undo 버튼 (좌하단)
                        const Positioned(
                          left: 20,
                          bottom: 20,
                          child: FloatingUndoButton(),
                        ),
                        
                        // Clear 버튼 (Undo 버튼 바로 옆)
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