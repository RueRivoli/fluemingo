import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/audiobook.dart';
import '../screens/audiobook_overview_page.dart';
import '../constants/app_colors.dart';
import 'favorite_toggle_button.dart';

// If showLocker is true, the locker icon is shown.
// otherwise, if showIsFavorite is true, the filled favorite icon is shown.
// otherwise, the empty favorite icon is shown.

class AudiobookCard extends StatelessWidget {
  final Audiobook audiobook;
  final bool showIsFavorite;
  final bool showLocker;
  final bool minified;
  final Function() onFavoriteToggled;

  const AudiobookCard({
    super.key,
    required this.audiobook,
    this.showIsFavorite = false,
    this.showLocker = false,
    this.minified = false,
    required this.onFavoriteToggled,
  });

  Widget _buildNewBadge() {
    return const Icon(
      FontAwesomeIcons.burstNew,
      size: 28,
      color: AppColors.secondary,
    );
  }

  void _navigateToOverview(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AudiobookOverviewPage(
            audiobook: audiobook,
            showLocker: showLocker,
            onFavoriteToggle: onFavoriteToggled),
      ),
    );
  }

  Widget _buildCover(double width, double height, double borderRadius) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: audiobook.imageUrl.isNotEmpty
          ? Image.network(
              audiobook.imageUrl,
              width: width,
              height: height,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildPlaceholder(width, height);
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: width,
                  height: height,
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              },
            )
          : _buildPlaceholder(width, height),
    );
  }

  Widget _buildPlaceholder(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF87CEEB), Color(0xFF1E3A8A)],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final book = audiobook;
    final cardWidth = 120.0;
    final imageHeight = 160.0;
    final borderRadius = 8.0;

    return GestureDetector(
      onTap: () => _navigateToOverview(context),
      child: Container(
        width: cardWidth,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                _buildCover(cardWidth, imageHeight, borderRadius),
                Positioned(
                  bottom: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      book.level,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                if (book.isNew)
                  Positioned(
                    bottom: 6,
                    right: 6,
                    child: _buildNewBadge(),
                  ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: FavoriteToggleButton(
                    isFavorite: showIsFavorite ? book.isFavorite : false,
                    showLocker: showLocker,
                    onTap: onFavoriteToggled,
                    padding: const EdgeInsets.all(4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 40,
              child: Text(
                book.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: minified ? 13 : 14,
                  fontWeight: minified ? FontWeight.w500 : FontWeight.w600,
                  color: AppColors.textPrimary,
                  letterSpacing: minified ? -0.2 : 0,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
