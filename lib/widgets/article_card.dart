import 'package:flutter/material.dart';
import '../models/article.dart';
import '../screens/article_overview_page.dart';
import '../constants/app_colors.dart';
import 'content_status_badge.dart';
import 'content_category_chip.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ArticleCard extends StatelessWidget {
  final Article article;
  final Function() onFavoriteToggle;

  /// When true, displays a thin compact layout for horizontal scrolling:
  /// no image, single-line title, no description, fixed narrow width.
  final bool minified;

  /// When false, the content status badge is hidden (e.g. on "Your content in progress").
  final bool showStatusBadge;
  final bool showLocker;
  final bool stackChipsAtBottom;

  const ArticleCard({
    super.key,
    required this.article,
    required this.onFavoriteToggle,
    this.minified = false,
    this.showStatusBadge = true,
    this.showLocker = false,
    this.stackChipsAtBottom = false,
  });

  Widget _buildChipsWrap(BuildContext context, {double? chipMaxWidth}) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.95),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            article.level,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        ContentCategoryChip(
          category: article.category1,
          horizontalPadding: 10,
          verticalPadding: 6,
          borderRadius: 6,
          maxWidth: chipMaxWidth ?? MediaQuery.of(context).size.width - 120,
        ),
        if (article.category2 != null && article.category2!.isNotEmpty)
          ContentCategoryChip(
            category: article.category2!,
            horizontalPadding: 10,
            verticalPadding: 6,
            borderRadius: 6,
            maxWidth: chipMaxWidth ?? MediaQuery.of(context).size.width - 120,
          ),
        if (article.category3 != null && article.category3!.isNotEmpty)
          ContentCategoryChip(
            category: article.category3!,
            horizontalPadding: 10,
            verticalPadding: 6,
            borderRadius: 6,
            maxWidth: chipMaxWidth ?? MediaQuery.of(context).size.width - 120,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final minifiedWidth = 168.0;
    final imageHeight = minified ? 128.0 : 200.0;
    final contentPadding = minified ? 0.0 : 16.0;
    final borderRadius = minified ? 10.0 : 16.0;
    final cardMargin = minified
        ? const EdgeInsets.only(right: 12)
        : const EdgeInsets.only(bottom: 16);
    if (minified) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ArticleOverviewPage(
                  article: article,
                  showLocker: showLocker,
                  onFavoriteToggle: onFavoriteToggle),
            ),
          );
        },
        child: Container(
          margin: cardMargin,
          width: minifiedWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Picture with level + category overlaid
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(borderRadius),
                    child: Image.network(
                      article.imageUrl,
                      height: imageHeight,
                      width: minifiedWidth,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: imageHeight,
                          width: minifiedWidth,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(borderRadius),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.image_outlined,
                              size: 32,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: imageHeight,
                          width: minifiedWidth,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(borderRadius),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: () {
                        onFavoriteToggle();
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          showLocker
                              ? FontAwesomeIcons.lock
                              : (article.isFavorite
                                  ? FontAwesomeIcons.solidHeart
                                  : FontAwesomeIcons.lightHeart),
                          size: 16,
                          color: showLocker
                              ? Colors.white
                              : (article.isFavorite
                                  ? AppColors.secondary
                                  : Colors.white),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 6,
                    left: 6,
                    right: 6,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (showStatusBadge &&
                            article.readingStatus != null) ...[
                          ContentStatusBadge(
                            status: article.readingStatus,
                            compact: true,
                          ),
                          Text(
                            article.readingStatus!,
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Expanded(
                          child: Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.95),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  article.level,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 40,
                child: Text(
                  article.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
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

    // Full card
    final card = GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArticleOverviewPage(
                article: article,
                showLocker: showLocker,
                onFavoriteToggle: onFavoriteToggle),
          ),
        );
      },
      child: Container(
        margin: cardMargin,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
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
          mainAxisSize:
              stackChipsAtBottom ? MainAxisSize.max : MainAxisSize.min,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(borderRadius),
                  ),
                  child: Image.network(
                    article.imageUrl,
                    height: imageHeight,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: imageHeight,
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(
                            Icons.image_outlined,
                            size: 48,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: imageHeight,
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 14,
                  right: 14,
                  child: GestureDetector(
                    onTap: () {
                      onFavoriteToggle();
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        showLocker
                            ? FontAwesomeIcons.lock
                            : (article.isFavorite
                                ? FontAwesomeIcons.solidHeart
                                : FontAwesomeIcons.lightHeart),
                        size: 20,
                        color: showLocker
                            ? Colors.white
                            : (article.isFavorite
                                ? AppColors.secondary
                                : Colors.white),
                      ),
                    ),
                  ),
                ),
                if (showStatusBadge)
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: ContentStatusBadge(
                      status: article.readingStatus,
                      compact: true,
                    ),
                  ),
              ],
            ),
            if (stackChipsAtBottom)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(contentPadding),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final chipMaxWidth = constraints.maxWidth;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            article.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            article.description,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[600],
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          _buildChipsWrap(
                            context,
                            chipMaxWidth: chipMaxWidth,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              )
            else
              Padding(
                padding: EdgeInsets.all(contentPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      article.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      article.description,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 14),
                    _buildChipsWrap(context),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
    return card;
  }
}
