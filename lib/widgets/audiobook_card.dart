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
  final Function() onFavoriteToggled;

  const AudiobookCard({
    super.key,
    required this.audiobook,
    this.showIsFavorite = false,
    this.showLocker = false,
    required this.onFavoriteToggled,
  });

  Widget _buildNewBadge() {
    return const Icon(
      FontAwesomeIcons.burstNew,
      size: 28,
      color: AppColors.secondary,
    );
  }

  @override
  Widget build(BuildContext context) {
    final book = audiobook;
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Book Cover with level label
          Stack(
            clipBehavior: Clip.none,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AudiobookOverviewPage(
                          audiobook: book,
                          showLocker: showLocker,
                          onFavoriteToggle: onFavoriteToggled),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: book.imageUrl.isNotEmpty
                      ? Image.network(
                          book.imageUrl,
                          width: 120,
                          height: 160,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 120,
                              height: 160,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    const Color(0xFF87CEEB), // Sky blue
                                    const Color(0xFF1E3A8A), // Dark blue
                                  ],
                                ),
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: 120,
                              height: 160,
                              color: Colors.grey[200],
                              child: const Center(
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                            );
                          },
                        )
                      : Container(
                          width: 120,
                          height: 160,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                const Color(0xFF87CEEB), // Sky blue
                                const Color(0xFF1E3A8A), // Dark blue
                              ],
                            ),
                          ),
                        ),
                ),
              ),
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
                  isFavorite: showIsFavorite
                      ? book.isFavorite
                      : false,
                  showLocker: showLocker,
                  onTap: onFavoriteToggled,
                  padding: const EdgeInsets.all(4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Book Title
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AudiobookOverviewPage(
                      audiobook: book,
                      showLocker: showLocker,
                      onFavoriteToggle: onFavoriteToggled),
                ),
              );
            },
            child: Text(
              book.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
