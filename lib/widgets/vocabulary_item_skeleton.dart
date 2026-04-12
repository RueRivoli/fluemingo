import 'package:flutter/material.dart';
import 'shimmer.dart';

/// Skeleton placeholder that mimics the layout of [VocabularyItemCard].
class VocabularyItemSkeleton extends StatelessWidget {
  const VocabularyItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Row(
        children: [
          // Play button placeholder
          ShimmerBox(width: 40, height: 40, borderRadius: 20),
          const SizedBox(width: 14),
          // Word + translation placeholders
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: 120, height: 16, borderRadius: 4),
                const SizedBox(height: 6),
                ShimmerBox(width: 160, height: 16, borderRadius: 4),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Action icon placeholder
          ShimmerBox(width: 22, height: 22, borderRadius: 11),
        ],
      ),
    );
  }
}

/// Shows a list of [VocabularyItemSkeleton] placeholders.
class VocabularyListSkeleton extends StatelessWidget {
  final int itemCount;

  const VocabularyListSkeleton({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(itemCount, (_) => const VocabularyItemSkeleton()),
    );
  }
}
