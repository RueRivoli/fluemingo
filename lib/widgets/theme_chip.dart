import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../l10n/label_localization.dart';

/// Reusable theme chip for onboarding (favorite themes), edit themes bottom sheet,
/// profile content, and profile settings.
class ThemeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final IconData? leadingIcon;

  const ThemeChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.leadingIcon,
  });

  @override
  Widget build(BuildContext context) {
    final translatedLabel = getTranslatedLabel(context, label);
    final child = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      // padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.secondary : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: isSelected
            ? Border.all(color: AppColors.borderBlack)
            : Border.all(color: Colors.white),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leadingIcon != null) ...[
            Icon(
              leadingIcon,
              size: 15,
              color: isSelected
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
          ],
          Text(
            translatedLabel,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) {
      return child;
    }
    return GestureDetector(
      onTap: onTap,
      child: child,
    );
  }
}
