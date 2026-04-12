import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'shimmer.dart';

/// Skeleton placeholder that mimics the layout of a chapter row
/// in [AudiobookOverviewPage].
class ChapterItemSkeleton extends StatelessWidget {
  const ChapterItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.neutral,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: const Row(
        children: [
          ShimmerBox(width: 20, height: 14, borderRadius: 4),
          SizedBox(width: 8),
          Expanded(
            child: ShimmerBox(width: double.infinity, height: 16, borderRadius: 4),
          ),
          SizedBox(width: 12),
          ShimmerBox(width: 60, height: 26, borderRadius: 10),
        ],
      ),
    );
  }
}

/// Shows a list of [ChapterItemSkeleton] placeholders.
class ChapterListSkeleton extends StatelessWidget {
  final int itemCount;

  const ChapterListSkeleton({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(itemCount, (_) => const ChapterItemSkeleton()),
    );
  }
}
