import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/dingbat.dart';
import '../providers/dingbat_provider.dart';
import 'dingbat_item.dart';

/// 딩벳 그리드 위젯
class DingbatGrid extends ConsumerWidget {
  const DingbatGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dingbats = ref.watch(filteredDingbatsProvider);
    final selectedTag = ref.watch(selectedTagProvider);
    final notifier = ref.read(dingbatsProvider.notifier);
    final allTags = notifier.getAllTags();

    return Column(
      children: [
        // 태그 필터
        _buildTagFilter(context, ref, allTags, selectedTag),
        
        // 딩벳 그리드
        Expanded(
          child: _buildDingbatGrid(context, dingbats),
        ),
      ],
    );
  }

  /// 태그 필터 위젯
  Widget _buildTagFilter(
    BuildContext context,
    WidgetRef ref,
    List<String> allTags,
    String selectedTag,
  ) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: allTags.length + 1, // +1 for "All" option
        itemBuilder: (context, index) {
          if (index == 0) {
            // "All" 태그
            return _buildTagChip(
              context,
              ref,
              'All',
              selectedTag.isEmpty,
              () => ref.read(selectedTagProvider.notifier).state = '',
            );
          }
          
          final tag = allTags[index - 1];
          final isSelected = selectedTag == tag;
          
          return _buildTagChip(
            context,
            ref,
            _capitalizeFirst(tag),
            isSelected,
            () => ref.read(selectedTagProvider.notifier).state = tag,
          );
        },
      ),
    );
  }

  /// 태그 칩 위젯
  Widget _buildTagChip(
    BuildContext context,
    WidgetRef ref,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: Colors.white.withOpacity(0.9),
        selectedColor: Colors.blue.shade600,
        checkmarkColor: Colors.white,
        side: BorderSide(
          color: isSelected ? Colors.blue.shade600 : Colors.grey.shade300,
        ),
        elevation: isSelected ? 4 : 2,
        shadowColor: Colors.black.withOpacity(0.2),
      ),
    );
  }

  /// 딩벳 그리드 위젯
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
        // 아이콘 크기 (고정)
        const double iconSize = 80.0;
        // 아이콘 간격
        const double spacing = 12.0;
        // 좌우 패딩
        const double padding = 16.0;
        
        // 사용 가능한 너비 계산
        final availableWidth = constraints.maxWidth - (padding * 2);
        
        // 한 줄에 들어갈 수 있는 아이콘 개수 계산
        final crossAxisCount = (availableWidth / (iconSize + spacing)).floor();
        
        // 최소 3개, 최대 8개로 제한
        final adjustedCrossAxisCount = crossAxisCount.clamp(3, 8);

        return GridView.builder(
          padding: const EdgeInsets.all(padding),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: adjustedCrossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: 1, // 정사각형
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

  /// 첫 글자 대문자 변환
  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
} 