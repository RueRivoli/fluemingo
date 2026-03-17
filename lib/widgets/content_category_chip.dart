import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/content.dart';
import '../l10n/label_localization.dart';

class ContentCategoryChip extends StatelessWidget {
  final String category;
  final bool useAudiobookTypeLabel;
  final double horizontalPadding;
  final double verticalPadding;
  final double borderRadius;
  final double iconSize;
  final double iconSpacing;
  final double? maxWidth;
  final int maxLines;
  final Color backgroundColor;
  final Color textColor;
  final FontWeight fontWeight;
  final double fontSize;

  const ContentCategoryChip({
    super.key,
    required this.category,
    this.useAudiobookTypeLabel = false,
    this.horizontalPadding = 10,
    this.verticalPadding = 6,
    this.borderRadius = 6,
    this.iconSize = 15,
    this.iconSpacing = 6,
    this.maxWidth,
    this.maxLines = 1,
    this.backgroundColor = AppColors.chipBackground,
    this.textColor = AppColors.chipText,
    this.fontWeight = FontWeight.w500,
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    var categoryKey = category.trim().toLowerCase();
    if (categoryKey == 'sports') {
      categoryKey = 'sport';
    }
    final themeIcon =
        THEMES.where((e) => e.id == categoryKey).firstOrNull?.icon;
    final label = useAudiobookTypeLabel
        ? audiobookTypeLabel(context, category)
        : getTranslatedLabel(context, category);

    final row = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (themeIcon != null) ...[
          Icon(themeIcon, size: iconSize, color: textColor),
          SizedBox(width: iconSpacing),
        ],
        if (maxWidth != null)
          Flexible(
            child: Text(
              label,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
              softWrap: maxLines > 1,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: fontWeight,
                color: textColor,
              ),
            ),
          )
        else
          Text(
            label,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            softWrap: maxLines > 1,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: fontWeight,
              color: textColor,
            ),
          ),
      ],
    );

    final chip = Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: row,
    );

    if (maxWidth == null) {
      return chip;
    }
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth!),
      child: chip,
    );
  }
}
