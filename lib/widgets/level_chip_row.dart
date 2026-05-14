import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/levels.dart';
import '../l10n/app_localizations.dart';

/// Horizontally scrollable row of level-filter chips (All, A1, A2, ...).
class LevelChipRow extends StatelessWidget {
  final String selectedLevel;
  final ValueChanged<String> onLevelChanged;

  const LevelChipRow({
    super.key,
    required this.selectedLevel,
    required this.onLevelChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: LEVELS.map((level) {
          final isSelected = selectedLevel == level;
          final isAll = level == 'All';
          final accent = isAll ? AppColors.secondary : levelColor(level);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onLevelChanged(level),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? accent : Colors.white,
                  border: Border.all(
                    color: isSelected
                        ? (isAll ? AppColors.borderBlack : accent)
                        : Colors.white,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isAll ? AppLocalizations.of(context)!.allLevels : level,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? (isAll ? AppColors.textPrimary : Colors.white)
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
