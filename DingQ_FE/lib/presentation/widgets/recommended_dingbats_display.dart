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
            color: Colors.grey.shade200,
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
                      style: TextStyle(
                        fontFamily: 'LGEIHeadline',
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
                          fontFamily: 'LGEIHeadline',
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
          color: Colors.grey.shade200,
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
                      fontFamily: 'LGEIHeadline',
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
                      fontFamily: 'LGEIHeadline',
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

    final top100 = recommendedDingbats['top100'] as List?;
    if (top100 == null || top100.isEmpty) {
      return _buildEmptyState();
    }

    // Sort by score in descending order (highest similarity first)
    final sortedResults = List<Map<String, dynamic>>.from(top100);
    sortedResults.sort((a, b) {
      final scoreA = a['score'] as double? ?? 0.0;
      final scoreB = b['score'] as double? ?? 0.0;
      return scoreB.compareTo(scoreA); // Descending order
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > 400;
        
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: const Text(
                      '유사도 높은 딩벳',
                      style: TextStyle(
                        fontFamily: 'LGEIHeadline',
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
              
              // Results - scrollable layout
              Expanded(
                child: isWideScreen
                    ? _buildWideScreenLayout(sortedResults)
                    : _buildNarrowScreenLayout(sortedResults),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Build wide screen layout with grid of dingbats
  Widget _buildWideScreenLayout(List top100) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Dynamic sizing based on screen width
        final screenWidth = constraints.maxWidth;
        
        // Calculate dynamic values based on screen size
        double iconSize, spacing, padding, fontSize;
        int minColumns, maxColumns;
        
        if (screenWidth < 600) {
          // Small screens
          iconSize = 32.0;
          spacing = 8.0;
          padding = 12.0;
          fontSize = 8.0;
          minColumns = 3;
          maxColumns = 6;
        } else if (screenWidth < 900) {
          // Medium screens
          iconSize = 36.0;
          spacing = 10.0;
          padding = 16.0;
          fontSize = 9.0;
          minColumns = 4;
          maxColumns = 7;
        } else if (screenWidth < 1200) {
          // Large screens
          iconSize = 40.0;
          spacing = 12.0;
          padding = 20.0;
          fontSize = 10.0;
          minColumns = 5;
          maxColumns = 8;
        } else {
          // Extra large screens
          iconSize = 44.0;
          spacing = 14.0;
          padding = 24.0;
          fontSize = 11.0;
          minColumns = 6;
          maxColumns = 10;
        }
        
        // Calculate available width
        final availableWidth = screenWidth - (padding * 2);
        
        // Calculate number of icons per row
        final crossAxisCount = (availableWidth / (iconSize + spacing)).floor();
        final adjustedCrossAxisCount = crossAxisCount.clamp(minColumns, maxColumns);

        return GridView.builder(
          padding: EdgeInsets.all(padding),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: adjustedCrossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: 1, // Square
          ),
          itemCount: top100.length,
          itemBuilder: (context, index) {
            final result = top100[index] as Map<String, dynamic>;
            final label = result['label'] as String? ?? 'Unknown';
            
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.all(padding * 0.5), // Dynamic padding
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // SVG Image - dynamic size
                    Expanded(
                      child: SvgPicture.asset(
                        'assets/dingbats/$label.svg',
                        width: iconSize,
                        height: iconSize,
                        fit: BoxFit.contain,
                        colorFilter: ColorFilter.mode(
                          Colors.grey.shade600,
                          BlendMode.srcIn,
                        ),
                        placeholderBuilder: (context) {
                          return Container(
                            width: iconSize,
                            height: iconSize,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.image,
                              color: Colors.grey.shade400,
                              size: iconSize * 0.5, // Dynamic icon size
                            ),
                          );
                        },
                      ),
                    ),
                    
                    // Label - dynamic font size
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: TextStyle(
                        fontFamily: 'LGEIHeadline',
                        fontSize: fontSize,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Build narrow screen layout with vertical list of dingbats
  Widget _buildNarrowScreenLayout(List top100) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Dynamic sizing based on screen width
        final screenWidth = constraints.maxWidth;
        
        // Calculate dynamic values based on screen size
        double iconSize, itemHeight, fontSize, margin, padding;
        
        if (screenWidth < 300) {
          // Very small screens
          iconSize = 20.0;
          itemHeight = 28.0;
          fontSize = 10.0;
          margin = 2.0;
          padding = 6.0;
        } else if (screenWidth < 400) {
          // Small screens
          iconSize = 24.0;
          itemHeight = 32.0;
          fontSize = 11.0;
          margin = 3.0;
          padding = 8.0;
        } else {
          // Medium screens
          iconSize = 28.0;
          itemHeight = 36.0;
          fontSize = 12.0;
          margin = 4.0;
          padding = 8.0;
        }
        
        return ListView.builder(
          itemCount: top100.length,
          itemBuilder: (context, index) {
            final result = top100[index] as Map<String, dynamic>;
            final label = result['label'] as String? ?? 'Unknown';
            
            return Container(
              height: itemHeight,
              margin: EdgeInsets.only(bottom: margin),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  // SVG Image - dynamic size
                  Container(
                    width: iconSize,
                    height: iconSize,
                    margin: EdgeInsets.all(margin),
                    child: SvgPicture.asset(
                      'assets/dingbats/$label.svg',
                      width: iconSize,
                      height: iconSize,
                      fit: BoxFit.contain,
                      colorFilter: ColorFilter.mode(
                        Colors.grey.shade600,
                        BlendMode.srcIn,
                      ),
                      placeholderBuilder: (context) {
                        return Container(
                          width: iconSize,
                          height: iconSize,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.image,
                            color: Colors.grey,
                            size: iconSize * 0.5, // Dynamic icon size
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // Label only - dynamic font size
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: padding),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontFamily: 'LGEIHeadline',
                          fontSize: fontSize,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}