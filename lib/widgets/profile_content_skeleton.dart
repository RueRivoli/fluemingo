import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'shimmer.dart';

/// Skeleton placeholder for the profile content page.
/// Shows a horizontal row of minified article card skeletons
/// and a horizontal row of audiobook card skeletons.
class ProfileContentSkeleton extends StatelessWidget {
  /// When true, shows theme chip placeholders before the cards.
  final bool showThemeChips;

  const ProfileContentSkeleton({super.key, this.showThemeChips = false});

  static Color get _base => AppColors.neutral;
  static Color get _highlight => Colors.white;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showThemeChips) ...[
          // Theme chip placeholders — match ThemeChip (padding 8×6, radius 8,
          // fontSize 16 → roughly 34px tall). Varying widths mimic labels.
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              ShimmerBox(width: 72, height: 34, borderRadius: 8,
                  baseColor: AppColors.neutral, highlightColor: Colors.white),
              ShimmerBox(width: 96, height: 34, borderRadius: 8,
                  baseColor: AppColors.neutral, highlightColor: Colors.white),
              ShimmerBox(width: 64, height: 34, borderRadius: 8,
                  baseColor: AppColors.neutral, highlightColor: Colors.white),
              ShimmerBox(width: 88, height: 34, borderRadius: 8,
                  baseColor: AppColors.neutral, highlightColor: Colors.white),
            ],
          ),
          const SizedBox(height: 16),
        ],
        // "Library" header placeholder
        ShimmerBox(
          width: 100,
          height: 18,
          borderRadius: 6,
          baseColor: _base,
          highlightColor: _highlight,
        ),
        const SizedBox(height: 8),
        // Minified article cards row (185 matches parent for favorite/interesting,
        // 180 for inProgress — 5px difference is imperceptible).
        SizedBox(
          height: 185,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, __) => _buildArticleCardSkeleton(),
          ),
        ),
        const SizedBox(height: 24),
        // "Audiobooks" header placeholder
        ShimmerBox(
          width: 120,
          height: 18,
          borderRadius: 6,
          baseColor: _base,
          highlightColor: _highlight,
        ),
        const SizedBox(height: 8),
        // Audiobook cards row
        SizedBox(
          height: 210,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 4,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (_, __) => _buildAudiobookCardSkeleton(),
          ),
        ),
      ],
    );
  }

  /// Minified article card: 168×128 image + short title below.
  Widget _buildArticleCardSkeleton() {
    return SizedBox(
      width: 168,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(
            width: 168,
            height: 128,
            borderRadius: 10,
            baseColor: _base,
            highlightColor: _highlight,
          ),
          const SizedBox(height: 6),
          ShimmerBox(
            width: 120,
            height: 14,
            borderRadius: 4,
            baseColor: _base,
            highlightColor: _highlight,
          ),
          const SizedBox(height: 4),
          ShimmerBox(
            width: 80,
            height: 12,
            borderRadius: 4,
            baseColor: _base,
            highlightColor: _highlight,
          ),
        ],
      ),
    );
  }

  /// Audiobook card: 120×160 cover (radius 8) + title below.
  Widget _buildAudiobookCardSkeleton() {
    return SizedBox(
      width: 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(
            width: 120,
            height: 160,
            borderRadius: 8,
            baseColor: _base,
            highlightColor: _highlight,
          ),
          const SizedBox(height: 8),
          ShimmerBox(
            width: 100,
            height: 14,
            borderRadius: 4,
            baseColor: _base,
            highlightColor: _highlight,
          ),
          const SizedBox(height: 4),
          ShimmerBox(
            width: 70,
            height: 12,
            borderRadius: 4,
            baseColor: _base,
            highlightColor: _highlight,
          ),
        ],
      ),
    );
  }
}
