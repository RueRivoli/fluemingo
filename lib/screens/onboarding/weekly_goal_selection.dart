import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/weekly_goals.dart';
import '../../l10n/app_localizations.dart';
import 'registration_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class WeeklyGoalSelectionPage extends StatefulWidget {
  final String targetLanguage;
  final String nativeLanguage;
  final String avatar;
  final List<String> favoriteThemes;
  final VoidCallback? onComplete;

  const WeeklyGoalSelectionPage({
    super.key,
    required this.targetLanguage,
    required this.nativeLanguage,
    required this.avatar,
    required this.favoriteThemes,
    this.onComplete,
  });

  @override
  State<WeeklyGoalSelectionPage> createState() =>
      _WeeklyGoalSelectionPageState();
}

/// Onboarding step index (1-based). Weekly goal = step 6 of 7.
const int _onboardingTotalSteps = 7;
const int _weeklyGoalStep = 6;

class _WeeklyGoalSelectionPageState extends State<WeeklyGoalSelectionPage> {
  @override
  Widget build(BuildContext context) {
    final progress = _weeklyGoalStep / _onboardingTotalSteps;
    return Scaffold(
      backgroundColor: AppColors.primary,
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
                    color: Colors.white,
                    iconSize: 22,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          FractionallySizedBox(
                            widthFactor: progress,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
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

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                AppLocalizations.of(context)!.dailyGoal,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                  height: 1.3,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                AppLocalizations.of(context)!.selectGoal,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.white.withOpacity(0.7),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Goal options list (card style: icon + title + subtitle)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ListView.separated(
                  itemCount: DAILY_PRACTICE_GOALS.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final goal = DAILY_PRACTICE_GOALS[index];
                    final l10n = AppLocalizations.of(context)!;
                    final duration =
                        l10n.goalDuration(goal['duration'] as String? ?? '');
                    final xp = goal['xp'] as int? ?? 0;
                    final week = l10n.week;
                    final iconKey = goal['icon'] as String? ?? 'bolt';
                    return _WeeklyGoalCard(
                      icon: goalIconData(iconKey),
                      title: duration,
                      subtitle: '$xp XP/$week',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => RegistrationPage.onboarding(
                              targetLanguage: widget.targetLanguage,
                              nativeLanguage: widget.nativeLanguage,
                              avatar: widget.avatar,
                              favoriteThemes: widget.favoriteThemes,
                              weeklyGoalXP: xp,
                              onComplete: widget.onComplete,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

/// Card-style option: icon on the left, title + subtitle on the right (screenshot style).
class _WeeklyGoalCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _WeeklyGoalCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.22),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              width: 44,
              height: 44,
              child: Icon(
                icon,
                size: 28,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
