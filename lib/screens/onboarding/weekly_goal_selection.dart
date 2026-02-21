import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/weekly_goals.dart';
import '../../widgets/theme_chip.dart';
import 'registration_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class WeeklyGoalSelectionPage extends StatefulWidget {
  final String targetLanguage;
  final String nativeLanguage;
  final List<String> favoriteThemes;
  final VoidCallback? onComplete;

  const WeeklyGoalSelectionPage({
    super.key,
    required this.targetLanguage,
    required this.nativeLanguage,
    required this.favoriteThemes,
    this.onComplete,
  });

  @override
  State<WeeklyGoalSelectionPage> createState() =>
      _WeeklyGoalSelectionPageState();
}

class _WeeklyGoalSelectionPageState extends State<WeeklyGoalSelectionPage> {
  int? _selectedGoalIndex;

  bool get _hasSelection => _selectedGoalIndex != null;

  int? get _selectedGoalXP =>
      _selectedGoalIndex != null
          ? (DAILY_PRACTICE_GOALS[_selectedGoalIndex!]['xp'] as int)
          : null;

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
                'Daily Goal',
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
                'Select a weekly goal to gain momentum',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Goal options list
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ListView.separated(
                  itemCount: DAILY_PRACTICE_GOALS.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final goal = DAILY_PRACTICE_GOALS[index];
                    final intensity =
                        (goal['intensity'] as String? ?? '')
                            .isNotEmpty
                            ? '${(goal['intensity'] as String).substring(0, 1).toUpperCase()}${(goal['intensity'] as String).substring(1)} — '
                            : '';
                    final duration = goal['duration'] as String? ?? '';
                    final xp = goal['xp'] as int? ?? 0;
                    final isSelected = _selectedGoalIndex == index;
                    final label = '$intensity$duration • $xp XP';
                    return ThemeChip(
                      label: label,
                      isSelected: isSelected,
                      onTap: () {
                        setState(() {
                          _selectedGoalIndex = _selectedGoalIndex == index
                              ? null
                              : index;
                        });
                      },
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
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => RegistrationPage(
                              targetLanguage: widget.targetLanguage,
                              nativeLanguage: widget.nativeLanguage,
                              favoriteThemes: widget.favoriteThemes,
                              weeklyGoalXP: _selectedGoalXP,
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
