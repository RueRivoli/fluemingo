import 'package:flutter/material.dart';
import '../models/unit.dart';
import '../constants/app_colors.dart';

/// A tappable word chip used in article/chapter reading sentences.
/// Punctuation units are rendered without background and are not tappable.
class UnitChip extends StatelessWidget {
  final Unit unit;
  final bool isHighlighted;
  final double fontSize;
  final double rightMargin;
  final String trailingText;
  final VoidCallback? onTap;

  const UnitChip({
    super.key,
    required this.unit,
    required this.isHighlighted,
    required this.fontSize,
    this.rightMargin = 4,
    this.trailingText = '',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasPunctuation = unit.punctuation == true;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: hasPunctuation ? null : onTap,
      child: Container(
        margin: EdgeInsets.only(right: rightMargin, bottom: 2),
        padding: hasPunctuation
            ? EdgeInsets.zero
            : const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
        decoration: hasPunctuation
            ? null
            : BoxDecoration(
                color: isHighlighted
                    ? AppColors.primary.withValues(alpha: 0.30)
                    : Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
        child: Text(
          unit.text + trailingText,
          style: TextStyle(
            fontSize: fontSize,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.normal,
            height: 1.8,
          ),
        ),
      ),
    );
  }
}
