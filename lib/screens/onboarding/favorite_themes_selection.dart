import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/library_themes.dart';
import '../../widgets/theme_chip.dart';
import 'registration_page.dart';
import 'weekly_goal_selection.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FavoriteThemesSelectionPage extends StatefulWidget {
  final String targetLanguage;
  final String nativeLanguage;
  final VoidCallback? onComplete;

  const FavoriteThemesSelectionPage({
    super.key,
    required this.targetLanguage,
    required this.nativeLanguage,
    this.onComplete,
  });

  @override
  State<FavoriteThemesSelectionPage> createState() =>
      _FavoriteThemesSelectionPageState();
}

class _FavoriteThemesSelectionPageState extends State<FavoriteThemesSelectionPage> {
  static const int _maxSelections = 5;

  final Set<String> _selectedThemes = {};

  List<String> get _allThemeOptions => THEMES;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Favorite Themes',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Select up to $_maxSelections themes that you are interested in (${_selectedThemes.length}/$_maxSelections)',
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
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _allThemeOptions.map((theme) {
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
                    color: _hasSelection ? AppColors.secondary : Colors.white.withOpacity(1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _hasSelection ? Colors.black : Colors.white.withOpacity(1),
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
                        'Continue',
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
