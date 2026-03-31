import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../constants/app_colors.dart';
import 'content_status_badge.dart';

/// Shared header image with back button and status badge,
/// used by ArticleOverviewPage and AudiobookOverviewPage.
class ContentHeaderImage extends StatelessWidget {
  final String imageUrl;
  final String? status;
  final bool showStatusMenu;
  final void Function(String newStatus)? onStatusChange;

  const ContentHeaderImage({
    super.key,
    required this.imageUrl,
    this.status,
    this.showStatusMenu = false,
    this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedPath = imageUrl.startsWith('file://')
        ? imageUrl.replaceFirst('file://', '')
        : imageUrl;
    final isLocal = normalizedPath.startsWith('/');

    return Stack(
      children: [
        isLocal
            ? Image.file(
                File(normalizedPath),
                height: 280,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildPlaceholder(),
              )
            : Image.network(
                normalizedPath,
                height: 280,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildPlaceholder(),
              ),
        // Back button
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 16,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
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
        ),
        // Status badge
        Positioned(
          bottom: 12,
          left: 16,
          child: ContentStatusBadge(
            status: status,
            compact: false,
            showStatusMenu: showStatusMenu,
            onStatusChange: onStatusChange,
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 280,
      color: Colors.grey[300],
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          size: 48,
          color: Colors.grey,
        ),
      ),
    );
  }
}
