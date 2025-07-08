import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../providers/dingbat_provider.dart';

/// Widget to display recommended dingbats from API response
class RecommendedDingbatsDisplay extends ConsumerWidget {
  const RecommendedDingbatsDisplay({super.key});

  /// Build empty state container with guidance message
  Widget _buildEmptyState() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > 400;
        
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: isWideScreen ? MainAxisSize.min : MainAxisSize.max,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '유사도 높은 딩벳',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Empty state message - centered and takes remaining space
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.mouse,
                        color: Colors.grey.shade400,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '마우스로 그림을 그려\n딩벳을 찾아보세요',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendedDingbats = ref.watch(recommendedDingbatsProvider);
    final isLoading = ref.read(recommendedDingbatsProvider.notifier).isLoading;

    // Show loading state
    if (isLoading) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: const Text(
                    '유사도 높은 딩벳',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Loading indicator
            const Center(
              child: Column(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Searching...',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (recommendedDingbats == null) {
      return _buildEmptyState();
    }

    final top5 = recommendedDingbats['top5'] as List?;
    if (top5 == null || top5.isEmpty) {
      return _buildEmptyState();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > 400;
        
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: const Text(
                      '유사도 높은 딩벳',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Results - responsive layout
              if (isWideScreen) ...[
                // Wide screen: horizontal layout
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: top5.length,
                    itemBuilder: (context, index) {
                      final result = top5[index] as Map<String, dynamic>;
                      final label = result['label'] as String? ?? 'Unknown';
                      final score = result['score'] as double? ?? 0.0;
                      
                      return Container(
                        width: 70,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // SVG Image
                            Container(
                              width: 32,
                              height: 32,
                              margin: const EdgeInsets.all(4),
                              child: SvgPicture.asset(
                                'assets/dingbats/$label.svg',
                                width: 32,
                                height: 32,
                                fit: BoxFit.contain,
                                placeholderBuilder: (context) => Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons.image,
                                    color: Colors.grey,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                            
                            // Label and score
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      label,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 1),
                                    Text(
                                      '${(score * 100).toStringAsFixed(0)}%',
                                      style: TextStyle(
                                        fontSize: 8,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ] else ...[
                // Narrow screen: vertical layout
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    itemCount: top5.length,
                    itemBuilder: (context, index) {
                      final result = top5[index] as Map<String, dynamic>;
                      final label = result['label'] as String? ?? 'Unknown';
                      final score = result['score'] as double? ?? 0.0;
                      
                      return Container(
                        height: 36,
                        margin: const EdgeInsets.only(bottom: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            // SVG Image
                            Container(
                              width: 28,
                              height: 28,
                              margin: const EdgeInsets.all(4),
                              child: SvgPicture.asset(
                                'assets/dingbats/$label.svg',
                                width: 28,
                                height: 28,
                                fit: BoxFit.contain,
                                placeholderBuilder: (context) => Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons.image,
                                    color: Colors.grey,
                                    size: 14,
                                  ),
                                ),
                              ),
                            ),
                            
                            // Label and score
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        label,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      '${(score * 100).toStringAsFixed(0)}%',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
} 