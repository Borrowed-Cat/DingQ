import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/dingbat_provider.dart';

/// Tag filter widget
class TagFilter extends ConsumerWidget {
  const TagFilter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTag = ref.watch(selectedTagProvider);
    final notifier = ref.read(dingbatsProvider.notifier);
    final allTags = notifier.getAllTags();

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: allTags.length + 1, // +1 for "All" option
        itemBuilder: (context, index) {
          if (index == 0) {
            // "All" tag
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

  /// Tag chip widget
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
        selectedColor: Colors.purple.shade600,
        checkmarkColor: Colors.white,
        showCheckmark: false,
        elevation: 0,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  /// Capitalize first letter
  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
} 