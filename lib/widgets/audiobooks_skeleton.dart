import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'shimmer.dart';

/// Skeleton placeholder that matches the audiobooks list area on [AudiobooksPage].
/// Shows category headers and horizontal rows of audiobook card placeholders with shimmer.
class AudiobooksPageSkeleton extends StatelessWidget {
  const AudiobooksPageSkeleton({super.key});

  static const double _horizontalPadding = 20;
  static const double _cardWidth = 120;
  static const double _cardCoverHeight = 160;
  static const double _cardMarginRight = 16;
  static const double _cardTitleGap = 8;
  static const double _sectionRowHeight = 220;
  static const double _categoryHeaderBottomPadding = 12;
  static const double _sectionBottomGap = 24;
  static const int _sectionCount = 3;
  static const int _cardsPerSection = 4;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
      itemCount: _sectionCount,
      itemBuilder: (context, index) => _buildSectionSkeleton(context),
    );
  }

  Widget _buildSectionSkeleton(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category header
        Padding(
          padding: const EdgeInsets.only(bottom: _categoryHeaderBottomPadding),
          child: ShimmerBox(
            width: 140,
            height: 20,
            borderRadius: 6,
            baseColor: _skeletonBase,
            highlightColor: _skeletonHighlight,
          ),
        ),
        // Horizontal row of audiobook cards
        SizedBox(
          height: _sectionRowHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _cardsPerSection,
            itemBuilder: (context, index) => _buildAudiobookCardSkeleton(context),
          ),
        ),
        const SizedBox(height: _sectionBottomGap),
      ],
    );
  }

  Widget _buildAudiobookCardSkeleton(BuildContext context) {
    return Container(
      width: _cardWidth,
      margin: const EdgeInsets.only(right: _cardMarginRight),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover
          Shimmer(
            baseColor: _skeletonBase,
            highlightColor: _skeletonHighlight,
            child: Container(
              width: _cardWidth,
              height: _cardCoverHeight,
              decoration: BoxDecoration(
                color: _skeletonBase,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: _cardTitleGap),
          // Title (2 lines)
          ShimmerBox(
            width: double.infinity,
            height: 14,
            borderRadius: 4,
            baseColor: _skeletonBase,
            highlightColor: _skeletonHighlight,
          ),
          const SizedBox(height: 6),
          ShimmerBox(
            width: 80,
            height: 14,
            borderRadius: 4,
            baseColor: _skeletonBase,
            highlightColor: _skeletonHighlight,
          ),
        ],
      ),
    );
  }

  static Color get _skeletonBase => AppColors.neutral;
  static Color get _skeletonHighlight => Colors.white;
}
