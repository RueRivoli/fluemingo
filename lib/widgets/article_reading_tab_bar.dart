import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../l10n/app_localizations.dart';

/// Three-tab bar (Article / Vocabulary / Quiz) for the reading page.
class ArticleReadingTabBar extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onTabSelected;

  const ArticleReadingTabBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.neutral,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              label: l10n.article,
              index: 0,
              selectedIndex: selectedIndex,
              selectedColor: AppColors.secondary,
              selectedTextColor: Colors.black,
              onTap: onTabSelected,
            ),
          ),
          Expanded(
            child: _TabButton(
              label: l10n.vocabulary,
              index: 1,
              selectedIndex: selectedIndex,
              selectedColor: AppColors.primary,
              selectedTextColor: Colors.white,
              onTap: onTabSelected,
            ),
          ),
          Expanded(
            child: _TabButton(
              label: l10n.quiz,
              index: 2,
              selectedIndex: selectedIndex,
              selectedColor: Colors.white,
              selectedTextColor: Colors.black,
              onTap: onTabSelected,
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final int index;
  final int selectedIndex;
  final Color selectedColor;
  final Color selectedTextColor;
  final void Function(int) onTap;

  const _TabButton({
    required this.label,
    required this.index,
    required this.selectedIndex,
    required this.selectedColor,
    required this.selectedTextColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
          border: isSelected
              ? Border.all(color: AppColors.borderBlack, width: 1)
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? selectedTextColor : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
