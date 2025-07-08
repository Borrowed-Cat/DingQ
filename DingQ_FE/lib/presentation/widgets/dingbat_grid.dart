import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/dingbat.dart';
import '../providers/dingbat_provider.dart';
import 'dingbat_item.dart';

/// Dingbat grid widget
class DingbatGrid extends ConsumerWidget {
  const DingbatGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dingbats = ref.watch(filteredDingbatsProvider);

    return _buildDingbatGrid(context, dingbats);
  }

  /// Dingbat grid widget
  Widget _buildDingbatGrid(BuildContext context, List<Dingbat> dingbats) {
    if (dingbats.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No dingbats found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Icon size (fixed)
        const double iconSize = 80.0;
        // Icon spacing
        const double spacing = 10.0;
        // Left-right padding
        const double padding = 16.0;
        
        // Determine if it's a wide screen
        final isWideScreen = constraints.maxWidth > 800;
        
        // Calculate available width
        final availableWidth = constraints.maxWidth - (padding * 2);
        
        // Calculate number of icons per row
        final crossAxisCount = (availableWidth / (iconSize + spacing)).floor();
        
        // Limit to minimum 3, maximum 8
        final adjustedCrossAxisCount = crossAxisCount.clamp(3, 8);

        return GridView.builder(
          padding: EdgeInsets.fromLTRB(
            padding, 
            8, 
            isWideScreen ? 8 : padding, 
            padding
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: adjustedCrossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: 1, // Square
          ),
          itemCount: dingbats.length,
          itemBuilder: (context, index) {
            final dingbat = dingbats[index];
            return DingbatItem(dingbat: dingbat);
          },
        );
      },
    );
  }
} 