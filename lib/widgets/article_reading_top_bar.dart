import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../constants/app_colors.dart';
import '../constants/number_icons.dart';

/// Top bar for the article/chapter reading page with back button and title.
class ArticleReadingTopBar extends StatelessWidget {
  final String title;
  final int contentType;
  final int? orderId;
  final VoidCallback onBack;

  const ArticleReadingTopBar({
    super.key,
    required this.title,
    required this.contentType,
    required this.orderId,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                FontAwesomeIcons.chevronLeft,
                color: AppColors.textPrimary,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 12),
          if (contentType == 2)
            Expanded(
              child: Row(
                children: [
                  Icon(
                    figureToFontAwesomeIcon(orderId ?? 1) ??
                        FontAwesomeIcons.hashtag,
                    size: 24,
                    color: AppColors.textPrimary,
                  ),
                  const Text(
                    '.',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            )
          else
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }
}
