import 'package:flutter/material.dart';
import '../models/vocabulary_item.dart';
import '../constants/app_colors.dart';

class VocabularyItemCard extends StatelessWidget {
  final VocabularyItem item;
  final VoidCallback onBookmarkToggle;

  const VocabularyItemCard({
    super.key,
    required this.item,
    required this.onBookmarkToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Play button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: item.isSaved ? AppColors.primary : Colors.grey[600],
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.play_arrow,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          // Word and translation
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item.word} (${item.type})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.translation}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // Bookmark button
          GestureDetector(
            onTap: onBookmarkToggle,
            child: Icon(
              item.isSaved ? Icons.bookmark : Icons.bookmark_border,
              size: 26,
              color: item.isSaved ? AppColors.primary : Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }
}