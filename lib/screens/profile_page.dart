import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../services/profile_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/article.dart';
import '../models/profile.dart';
import '../widgets/article_card.dart';
import '../widgets/audiobook_card.dart';
import '../widgets/avatar_widget.dart';
import '../services/week_progress_service.dart';
import '../models/week_progress.dart';
import '../screens/profile_content.dart';
import '../screens/profile_settings.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../l10n/app_localizations.dart';

class ProfilePage extends StatefulWidget {
  final bool isVisible;

  const ProfilePage({super.key, this.isVisible = true});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}


class _ProfilePageState extends State<ProfilePage> {
  late final ProfileService profileService =
      ProfileService(Supabase.instance.client);
  late final WeekProgressService weekProgressService =
      WeekProgressService(Supabase.instance.client);
  Profile? profile;
  bool isLoading = true;
  WeekProgress? _weekProgress;
  WeekProgress? _overallProgress;
  ContentMenu _selectedMenu = ContentMenu.inProgress;
  bool _showOverallProgress = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    _loadWeekProgress();
    _loadOverallProgress();
  }

  Future<void> _loadWeekProgress() async {
    final weekProgress = await weekProgressService.getWeekProgress();
    setState(() {
      _weekProgress = weekProgress;
    });
  }

  Future<void> _loadOverallProgress() async {
    final overall = await weekProgressService.getOverallProgress();
    if (mounted) setState(() => _overallProgress = overall);
  }

  @override
  void didUpdateWidget(covariant ProfilePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload profile data every time the user switches to this tab
    if (widget.isVisible && !oldWidget.isVisible) {
      _loadProfileData();
      _loadWeekProgress();
      _loadOverallProgress();
    }
  }

  Widget _buildWeeklyProgressCard({
    required int value,
    required String label,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.black, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.black,
              letterSpacing: 0.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  child: FaIcon(icon, color: iconColor, size: 30),
                ),
                const Spacer(),
                Text(
                  value.toString(),
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w500,
                    color: AppColors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCards(WeekProgress? progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildWeeklyProgressCard(
                value: int.parse(progress?.weekArticlesReadCount ?? '0'),
                label: AppLocalizations.of(context)!.finishedArticles,
                icon: FontAwesomeIcons.solidFileLines,
                iconColor: AppColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildWeeklyProgressCard(
                value: int.parse(progress?.weekAudiobooksReadCount ?? '0'),
                label: AppLocalizations.of(context)!.finishedAudiobooks,
                icon: FontAwesomeIcons.solidHeadphones,
                iconColor: AppColors.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildWeeklyProgressCard(
                value: int.parse(progress?.weekFlashcardsAchievedCount ?? '0'),
                label: AppLocalizations.of(context)!.masteredFlashcards,
                icon: FontAwesomeIcons.solidCardsBlank,
                iconColor: AppColors.success,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildWeeklyProgressCard(
                value: int.parse(progress?.weekQuizzesCompletedCount ?? '0'),
                label: AppLocalizations.of(context)!.completedQuizzes,
                icon: FontAwesomeIcons.solidBlockQuestion,
                iconColor: AppColors.error,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeeklyProgressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => setState(() => _showOverallProgress = false),
              child: Text(
                AppLocalizations.of(context)!.yourWeekProgress,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _showOverallProgress ? AppColors.textSecondary : AppColors.textPrimary,
                  decoration: _showOverallProgress ? null : TextDecoration.underline,
                  decorationColor: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '|',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => setState(() => _showOverallProgress = true),
              child: Text(
                AppLocalizations.of(context)!.yourProgress,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _showOverallProgress ? AppColors.textPrimary : AppColors.textSecondary,
                  decoration: _showOverallProgress ? TextDecoration.underline : null,
                  decorationColor: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _showOverallProgress
            ? _buildProgressCards(_overallProgress)
            : _buildProgressCards(_weekProgress),
      ],
    );
  }

  Widget _buildWeekProgress() {
    final goal = profile?.weeklyGoalXP ?? 500;
    final current = _weekProgress?.weekXP ?? 0;
    final progress = goal > 0 ? (current / goal).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.weekProgress,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.borderBlack, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(FontAwesomeIcons.solidStar, size: 22, color: AppColors.secondary),
                  const SizedBox(width: 6),
                  Text(
                    '${_weekProgress?.weekXP ?? 0} XP',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            const trackHeight = 14.0;
            const fillHeight = 12.0;
            final fillWidth = (constraints.maxWidth * progress).clamp(0.0, constraints.maxWidth);
            return Container(
              height: trackHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(trackHeight / 2),
                color: Colors.grey[300],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  SizedBox(width: constraints.maxWidth, height: fillHeight),
                  if (progress > 0)
                    Container(
                      width: fillWidth.clamp(fillHeight, constraints.maxWidth - 2),
                      height: fillHeight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(fillHeight / 2),
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFFB0A8E8),
                            Color(0xFF8A8BDE),
                          ],
                        ),
                        border: Border.all(
                          color: const Color(0xFF5C5499),
                          width: 2,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 4),
        Text(
          AppLocalizations.of(context)!.weeklyGoal(goal),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }


  Widget _buildVerticalMenuButton(String label, ContentMenu menu, {IconData? icon}) {
    final isSelected = _selectedMenu == menu;
        final isInProgress = menu == ContentMenu.inProgress;
    final isFavorite = menu == ContentMenu.favorite;
    final textColor = isInProgress ? AppColors.white : AppColors.textPrimary;


    Color backgroundColor;
    BoxBorder? border;

      if (isInProgress) {
        backgroundColor = AppColors.primary.withOpacity(0.85);
        border = Border.all(color: Colors.black, width: 1);
      } else if (isFavorite) {
       backgroundColor = AppColors.secondary.withOpacity(0.85);
        border = Border.all(color: Colors.black, width: 1);
      } else {
       backgroundColor = Colors.white.withOpacity(0.85);
        border = Border.all(color: Colors.black, width: 1);
      }

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfileContent(
                category: menu.name,
              ),
            ),
          );
          setState(() {
            _selectedMenu = menu;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: border,
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: icon != null
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(icon, size: 20, color: textColor),
                            const SizedBox(width: 10),
                            Text(
                              label,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                color: textColor,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ],
                        )
                      : Text(
                          label,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: textColor,
                          ),
                          textAlign: TextAlign.left,
                        ),
                ),
              ),
              Icon(FontAwesomeIcons.chevronRight, size: 24, color: textColor),
            ],
          ),
        ),
      ),
    );
  }


  Future<void> _loadProfileData() async {
    if (mounted) setState(() => isLoading = true);
    final profileData = await profileService.getProfileData();
    final weeklyProgress = await profileService.getWeeklyProgress();

    if (mounted) {
      setState(() {
        profile = Profile(
          fullName: profileData['full_name'] ?? '',
          email: profileData['email'] ?? '',
          avatarUrl: profileData['avatar_url'],
          isPremium: profileData['is_premium'] ?? false,
          nativeLanguage: profileData['native_language'] ?? '',
          targetLanguage: profileData['target_language'] ?? '',
          weeklyGoalXP: profileData['weekly_goal'] != null ? (profileData['weekly_goal'] as num).toInt() : null,
          weekXP: profileData['week_xp'] != null ? (profileData['week_xp'] as num).toInt() : null,
          lastWeekXP: profileData['last_week_xp'] != null ? (profileData['last_week_xp'] as num).toInt() : null,
          weeklyArticlesRead: weeklyProgress['articles'],
          weeklyAudiobooksRead: weeklyProgress['audiobooks'],
          weeklyFlashcardsAchieved: weeklyProgress['flashcards'],
          weeklyQuizzesCompleted: weeklyProgress['quizzes'],
        );
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Header: avatar + week progress + settings icon
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  UserAvatar(avatarUrl: profile?.avatarUrl, fullName: profile?.fullName),
                  const SizedBox(width: 16),
                  Expanded(child: _buildWeekProgress()),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 56,
                    height: 56,
                    child: Material(
                      color: AppColors.neutral,
                      shape: const CircleBorder(),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfileSettingsPage(),
                            ),
                          );
                        },
                        customBorder: const CircleBorder(),
                        child: Icon(
                          FontAwesomeIcons.gear,
                          size: 22,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text.rich(
                TextSpan(
                  style: const TextStyle(
                    fontSize: 22,
                    color: AppColors.textPrimary,
                  ),
                  children: [
                    TextSpan(
                      text: AppLocalizations.of(context)!.greetings + ', ',
                      style: TextStyle(fontWeight: FontWeight.normal),
                    ),
                    TextSpan(
                      text: profile?.fullName ?? Supabase.instance.client.auth.currentUser?.userMetadata?['full_name'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
            // Your weekly Progress
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: _buildWeeklyProgressSection(),
            ),
            // Continue Reading to Earn XP
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  AppLocalizations.of(context)!.continueReadingToEarnXP,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            // Three vertical buttons: In Progress | Favorite | Content you may Like
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildVerticalMenuButton(AppLocalizations.of(context)!.contentInProgress, ContentMenu.inProgress, icon: FontAwesomeIcons.ellipsis),
                  const SizedBox(height: 12),
                  _buildVerticalMenuButton(AppLocalizations.of(context)!.favoriteContent, ContentMenu.favorite, icon: FontAwesomeIcons.solidHeart),
                  const SizedBox(height: 12),
                  _buildVerticalMenuButton(AppLocalizations.of(context)!.interestingContent, ContentMenu.interesting, icon: FontAwesomeIcons.bolt),
                ],
              ),
            ),
            // Content below the buttons (inline, no navigation)
            // ContentCategory(
            //   category: _selectedMenu.name,
            //   embedded: true,
            // ),
          ],
        ),
      ),
    ),
    );
  }
}
