import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// A yellow dismissible filter chip used in Library and Audiobooks pages.
class DismissibleFilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onDismiss;
  final Widget? closeIcon;

  const DismissibleFilterChip({
    super.key,
    required this.label,
    required this.onDismiss,
    this.closeIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 12, top: 6, bottom: 6, right: 4),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        border: Border.all(color: AppColors.borderBlack),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          GestureDetector(
            onTap: onDismiss,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: closeIcon ??
                  const Icon(
                    Icons.close,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
