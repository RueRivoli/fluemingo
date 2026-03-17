import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'shimmer.dart';

/// Skeleton placeholder that matches the article list area on [LibraryPage].
/// Shows a list of card-shaped placeholders with shimmer.
class LibraryPageSkeleton extends StatelessWidget {
  const LibraryPageSkeleton({super.key});

  static const double _horizontalPadding = 20;
  static const double _cardBorderRadius = 16;
  static const double _cardImageHeight = 200;
  static const double _cardContentPadding = 16;
  static const double _cardMarginBottom = 16;
  static const int _cardCount = 4;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
      itemCount: _cardCount,
      itemBuilder: (context, index) => _buildArticleCardSkeleton(context),
    );
  }

  Widget _buildArticleCardSkeleton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: _cardMarginBottom),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Image placeholder
          Shimmer(
            baseColor: _skeletonBase,
            highlightColor: _skeletonHighlight,
            child: Container(
              height: _cardImageHeight,
              decoration: BoxDecoration(
                color: _skeletonBase,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(_cardBorderRadius),
                ),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(_cardContentPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                ShimmerBox(
                  width: double.infinity,
                  height: 22,
                  borderRadius: 6,
                  baseColor: _skeletonBase,
                  highlightColor: _skeletonHighlight,
                ),
                const SizedBox(height: 8),
                ShimmerBox(
                  width: 220,
                  height: 22,
                  borderRadius: 6,
                  baseColor: _skeletonBase,
                  highlightColor: _skeletonHighlight,
                ),
                const SizedBox(height: 6),
                // Description lines
                ShimmerBox(
                  width: double.infinity,
                  height: 16,
                  borderRadius: 6,
                  baseColor: _skeletonBase,
                  highlightColor: _skeletonHighlight,
                ),
                const SizedBox(height: 6),
                ShimmerBox(
                  width: 180,
                  height: 16,
                  borderRadius: 6,
                  baseColor: _skeletonBase,
                  highlightColor: _skeletonHighlight,
                ),
                const SizedBox(height: 14),
                // Chips row
                Row(
                  children: [
                    ShimmerBox(
                      width: 52,
                      height: 34,
                      borderRadius: 6,
                      baseColor: _skeletonBase,
                      highlightColor: _skeletonHighlight,
                    ),
                    const SizedBox(width: 8),
                    ShimmerBox(
                      width: 80,
                      height: 34,
                      borderRadius: 8,
                      baseColor: _skeletonBase,
                      highlightColor: _skeletonHighlight,
                    ),
                    const SizedBox(width: 8),
                    ShimmerBox(
                      width: 70,
                      height: 34,
                      borderRadius: 8,
                      baseColor: _skeletonBase,
                      highlightColor: _skeletonHighlight,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Color get _skeletonBase => AppColors.neutral;
  static Color get _skeletonHighlight => Colors.white;
}
