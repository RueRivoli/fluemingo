import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'app_colors.dart';

/// Centralizes all flashcard status → color, icon, and background mappings.
class FlashcardStatusTheme {
  static Color color(String? status) {
    switch (status) {
      case 'saved':
        return AppColors.primary;
      case 'difficult':
        return AppColors.error;
      case 'training':
        return AppColors.secondary;
      case 'mastered':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  static IconData icon(String? status) {
    switch (status) {
      case 'saved':
        return FontAwesomeIcons.floppyDisk;
      case 'difficult':
        return FontAwesomeIcons.triangleExclamation;
      case 'training':
        return FontAwesomeIcons.dumbbell;
      case 'mastered':
        return FontAwesomeIcons.badgeCheck;
      default:
        return Icons.bookmark_border;
    }
  }

  static IconData solidIcon(String? status) {
    switch (status) {
      case 'saved':
        return FontAwesomeIcons.solidFloppyDisk;
      case 'difficult':
        return FontAwesomeIcons.solidTriangleExclamation;
      case 'training':
        return FontAwesomeIcons.solidDumbbell;
      case 'mastered':
        return FontAwesomeIcons.solidBadgeCheck;
      default:
        return Icons.bookmark_border;
    }
  }

  static Color backgroundColor(String? status) {
    switch (status) {
      case 'saved':
        return AppColors.primary.withOpacity(0.06);
      case 'difficult':
        return AppColors.error.withOpacity(0.06);
      case 'training':
        return AppColors.white;
      case 'mastered':
        return AppColors.success.withOpacity(0.06);
      default:
        return AppColors.white.withOpacity(0.06);
    }
  }

  static Color borderColor(String? status) {
    switch (status) {
      case 'saved':
        return AppColors.primary.withOpacity(0.2);
      case 'difficult':
        return AppColors.error.withOpacity(0.2);
      case 'training':
        return AppColors.secondary.withOpacity(0.2);
      case 'mastered':
        return AppColors.success.withOpacity(0.2);
      default:
        return Colors.black.withOpacity(0.2);
    }
  }
}
