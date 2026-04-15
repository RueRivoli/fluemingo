import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/content.dart';
import '../../widgets/theme_chip.dart';
import 'weekly_goal_selection.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/label_localization.dart';

class FavoriteThemesSelectionPage extends StatefulWidget {
  final String targetLanguage;
  final String nativeLanguage;
  final String avatar;
  final VoidCallback? onComplete;

  const FavoriteThemesSelectionPage({
    super.key,
    required this.targetLanguage,
    required this.nativeLanguage,
    required this.avatar,
    this.onComplete,
  });

  @override
  State<FavoriteThemesSelectionPage> createState() =>
      _FavoriteThemesSelectionPageState();
}

/// Onboarding step index (1-based). Favorite themes = step 5 of 7.
const int _onboardingTotalSteps = 7;
const int _favoriteThemesStep = 5;

class _FavoriteThemesSelectionPageState
    extends State<FavoriteThemesSelectionPage> {
  static const int _maxSelections = 5;
  static const double _chipSpacing = 12;
  static const double _rowIndent = 28;

  final Set<String> _selectedThemes = {};

  List<String> get _allThemeOptions => THEMES.map((e) => e.id).toList();

  bool get _hasSelection => _selectedThemes.isNotEmpty;

  void _onThemeTap(String theme) {
    setState(() {
      if (_selectedThemes.contains(theme)) {
        _selectedThemes.remove(theme);
      } else if (_selectedThemes.length < _maxSelections) {
        _selectedThemes.add(theme);
      }
    });
  }

  bool _isSelected(String theme) {
    return _selectedThemes.contains(theme);
  }

  double _rowHorizontalShift(int rowIndex) {
    if (rowIndex == 0) return 0;
    return rowIndex.isOdd ? _rowIndent / 2 : -_rowIndent / 2;
  }

  double _estimateChipWidth(BuildContext context, String themeId) {
    final label = getTranslatedLabel(context, themeId);
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      maxLines: 1,
      textDirection: Directionality.of(context),
    )..layout();

    // ThemeChip horizontal sizing:
    // padding (16 left + 16 right) + icon (15) + gap (8) + text width.
    return textPainter.width + 16 + 16 + 15 + 8;
  }

  List<List<String>> _buildThemeRows(BuildContext context, double maxWidth) {
    final rows = <List<String>>[];
    var currentRow = <String>[];
    var currentWidth = 0.0;

    for (final theme in _allThemeOptions) {
      final chipWidth = _estimateChipWidth(context, theme);
      final nextWidth = currentRow.isEmpty
          ? chipWidth
          : currentWidth + _chipSpacing + chipWidth;

      if (currentRow.isNotEmpty && nextWidth > maxWidth) {
        rows.add(currentRow);
        currentRow = <String>[theme];
        currentWidth = chipWidth;
      } else {
        currentRow.add(theme);
        currentWidth = nextWidth;
      }
    }

    if (currentRow.isNotEmpty) {
      rows.add(currentRow);
    }

    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final progress = _favoriteThemesStep / _onboardingTotalSteps;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top bar: back button + progress bar
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 24, 24),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(FontAwesomeIcons.leftLong),
                    color: AppColors.textPrimary,
                    iconSize: 22,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.textPrimary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          FractionallySizedBox(
                            widthFactor: progress,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.textPrimary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Title + selected count (X / 5)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(context)!.favoriteThemes,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                  Text(
                    '${_selectedThemes.length} / $_maxSelections',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                AppLocalizations.of(context)!.selectUpToThemes(_maxSelections),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Theme chips grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final rows = _buildThemeRows(context, constraints.maxWidth);
                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: List.generate(rows.length, (rowIndex) {
                          final rowThemes = rows[rowIndex];
                          final horizontalShift = _rowHorizontalShift(rowIndex);
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: rowIndex == rows.length - 1
                                  ? 0
                                  : _chipSpacing,
                            ),
                            child: Align(
                              alignment: Alignment.center,
                              child: Transform.translate(
                                offset: Offset(horizontalShift, 0),
                                child: Wrap(
                                  spacing: _chipSpacing,
                                  runSpacing: 0,
                                  children: rowThemes.map((theme) {
                                    final isSelected = _isSelected(theme);
                                    return ThemeChip(
                                      label: theme,
                                      isSelected: isSelected,
                                      onTap: () => _onThemeTap(theme),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Next button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
              child: GestureDetector(
                onTap: _hasSelection
                    ? () {
                        final themesToSave = _selectedThemes.toList();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => WeeklyGoalSelectionPage(
                              targetLanguage: widget.targetLanguage,
                              nativeLanguage: widget.nativeLanguage,
                              avatar: widget.avatar,
                              favoriteThemes: themesToSave,
                              onComplete: widget.onComplete,
                            ),
                          ),
                        );
                      }
                    : null,
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: _hasSelection
                        ? AppColors.secondary
                        : Colors.white.withOpacity(1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _hasSelection
                          ? Colors.black
                          : Colors.white.withOpacity(1),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        FontAwesomeIcons.lightArrowRight,
                        size: 22,
                        color: _hasSelection
                            ? AppColors.textPrimary
                            : AppColors.textPrimary.withOpacity(0.5),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context)!.next,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
