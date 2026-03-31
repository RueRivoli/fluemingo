import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../constants/app_colors.dart';

/// Shared lock/heart toggle button used across article cards,
/// audiobook cards, and overview pages.
class FavoriteToggleButton extends StatelessWidget {
  final bool isFavorite;
  final bool showLocker;
  final VoidCallback onTap;

  /// Icon size. Defaults to 20.
  final double iconSize;

  /// Padding around the icon. Defaults to EdgeInsets.all(6).
  final EdgeInsetsGeometry padding;

  const FavoriteToggleButton({
    super.key,
    required this.isFavorite,
    required this.onTap,
    this.showLocker = false,
    this.iconSize = 20,
    this.padding = const EdgeInsets.all(6),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          showLocker
              ? FontAwesomeIcons.lock
              : (isFavorite
                  ? FontAwesomeIcons.solidHeart
                  : FontAwesomeIcons.lightHeart),
          size: iconSize,
          color: showLocker
              ? Colors.white
              : (isFavorite ? AppColors.secondary : Colors.white),
        ),
      ),
    );
  }
}
