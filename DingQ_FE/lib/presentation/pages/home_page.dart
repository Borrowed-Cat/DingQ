import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/drawing_canvas.dart';
import '../widgets/floating_undo_button.dart';
import '../widgets/floating_clear_button.dart';
import '../widgets/dingbat_grid.dart';
import '../widgets/recommended_dingbats_display.dart';
import '../widgets/floating_genai_button.dart';
import '../widgets/ai_generation_modal.dart';
import '../providers/stroke_provider.dart';
import '../providers/genai_provider.dart';
import '../widgets/tag_filter.dart';
import '../widgets/gcs_image_grid.dart';

/// Main home page
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  GlobalKey? _canvasKey;
  int _selectedTab = 0; // 0: 딩벳찾기, 1: AI 라이브러리

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Stack(
        children: [
          LayoutBuilder(
        builder: (context, constraints) {
          final isWideScreen = constraints.maxWidth > 800;
          
          // --- 상단 투탭 UI ---
          Widget topTabBar = Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() { _selectedTab = 0; });
                  },
                  child: Text(
                    '딩벳찾기',
                    style: TextStyle(
                      fontFamily: 'LGEIHeadline',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: _selectedTab == 0 ? Colors.black : Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () {
                    setState(() { _selectedTab = 1; });
                  },
                  child: Text(
                    'AI 라이브러리',
                    style: TextStyle(
                      fontFamily: 'LGEIHeadline',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: _selectedTab == 1 ? Colors.black : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          );

          // --- 탭별 화면 ---
          Widget mainContent;
          if (_selectedTab == 0) {
            // 기존 딩벳찾기 화면
            if (isWideScreen) {
              mainContent = Column(
                children: [
                  // TagFilter
                  const TagFilter(),
                  // Main content area
                  Expanded(
                    child: Row(
                      children: [
                        // Left: dingbat grid
                        Expanded(
                          flex: 1,
                          child: const DingbatGrid(),
                        ),
                        // Right: drawing canvas and recommendations
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
                                      Positioned(
                                        right: 20,
                                        bottom: 20,
                                        child: Consumer(
                                          builder: (context, ref, child) {
                                            final strokes = ref.watch(strokesProvider);
                                            return FloatingGenAIButton(
                                              canvasKey: _canvasKey,
                                              strokes: strokes,
                                            );
                                          },
                                        ),
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
              mainContent = Column(
                children: [
                  // TagFilter
                  const TagFilter(),
                  // Main content area
                  Expanded(
                    child: Column(
                      children: [
                        // Top: dingbat grid
                        Expanded(
                          flex: 1,
                          child: const DingbatGrid(),
                        ),
                        // Bottom: drawing canvas and recommendations
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
                                      Positioned(
                                        right: 20,
                                        bottom: 20,
                                        child: Consumer(
                                          builder: (context, ref, child) {
                                            final strokes = ref.watch(strokesProvider);
                                            return FloatingGenAIButton(
                                              canvasKey: _canvasKey,
                                              strokes: strokes,
                                            );
                                          },
                                        ),
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
          } else {
            // AI 라이브러리 탭: GCS 이미지 그리드
            mainContent = const GcsImageGrid();
          }

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                topTabBar,
                Expanded(
                  child: mainContent,
                ),
              ],
            ),
          );
        },
      ),
          
          // AI Generation Modal
          Consumer(
            builder: (context, ref, child) {
              final genAIState = ref.watch(genAIProvider);
              
              if (genAIState.showModal && genAIState.result != null) {
                return AIGenerationModal(
                  icons: genAIState.result!.icons,
                  onClose: () {
                    ref.read(genAIProvider.notifier).hideModal();
                  },
                );
              }
              
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
} 