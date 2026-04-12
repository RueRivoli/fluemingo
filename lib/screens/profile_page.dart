import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../services/profile_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile.dart';
import '../widgets/avatar_widget.dart';
import '../services/week_progress_service.dart';
import '../models/week_progress.dart';
import '../screens/profile_content.dart';
import '../screens/profile_settings.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../l10n/app_localizations.dart';
import '../stores/profile_store.dart';

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
  WeekProgress? _weekProgress;
  WeekProgress? _overallProgress;
  ContentMenu _selectedMenu = ContentMenu.inProgress;
  bool _showOverallProgress = false;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final results = await Future.wait([
      weekProgressService.getWeekProgress(),
      weekProgressService.getOverallProgress(),
    ]);
    if (!mounted) return;
    setState(() {
      _weekProgress = results[0];
      _overallProgress = results[1];
    });
  }

  @override
  void didUpdateWidget(covariant ProfilePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload profile and progress every time the user switches to this tab
    if (widget.isVisible && !oldWidget.isVisible) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ProfileStoreScope.of(context).load();
          _loadProgress();
        }
      });
    }
  }

  Widget _buildWeeklyProgressCard({
    required int value,
    required String label,
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required Color textColor,
    int? xpPerItem,
  }) {
    return Container(
      height: 120,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: AppColors.borderBlack, width: 1),
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // Background watermark icon
          Positioned(
            right: -10,
            bottom: -14,
            child: FaIcon(
              icon,
              size: 76,
              color: iconColor.withOpacity(0.12),
            ),
          ),
          // Foreground content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                      letterSpacing: -0.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (xpPerItem != null) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: textColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '+$xpPerItem XP',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: textColor.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    value.toString(),
                    style: TextStyle(
                      fontSize: 46,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                      height: 1.0,
                      letterSpacing: -2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  FaIcon(
                    icon,
                    size: 20,
                    color: iconColor,
                  ),
                ],
              ),
            ],
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
                icon: FontAwesomeIcons.thinFileLines,
                iconColor: AppColors.textPrimary,
                backgroundColor: AppColors.secondary,
                textColor: AppColors.textPrimary,
                xpPerItem: XP_PER_ARTICLE,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildWeeklyProgressCard(
                value:
                    int.parse(progress?.weekAudiobooksChaptersReadCount ?? '0'),
                label: AppLocalizations.of(context)!.finishedChaptersAudiobooks,
                icon: FontAwesomeIcons.thinHeadphones,
                iconColor: AppColors.textPrimary,
                backgroundColor: AppColors.primary,
                textColor: AppColors.textPrimary,
                xpPerItem: XP_PER_AUDIOBOOK_CHAPTER,
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
                icon: FontAwesomeIcons.thinCardsBlank,
                iconColor: AppColors.textPrimary,
                backgroundColor: const Color(0xFFC8E6C9),
                textColor: AppColors.textPrimary,
                xpPerItem: XP_PER_FLASHCARD,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildWeeklyProgressCard(
                value: int.parse(progress?.weekQuizzesCompletedCount ?? '0'),
                label: AppLocalizations.of(context)!.completedQuizzes,
                icon: FontAwesomeIcons.thinBlockQuestion,
                iconColor: AppColors.textPrimary,
                backgroundColor: const Color(0xFFFFD6C0),
                textColor: AppColors.textPrimary,
                xpPerItem: XP_PER_QUIZ,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeeklyProgressSection() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.neutral,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: [
              _buildProgressSegment(
                label: l10n.yourWeekProgress,
                icon: FontAwesomeIcons.solidCalendar,
                isSelected: !_showOverallProgress,
                onTap: () {
                  if (mounted) setState(() => _showOverallProgress = false);
                },
                bgColor: AppColors.secondary,
                textColor: AppColors.textPrimary,
              ),
              _buildProgressSegment(
                label: l10n.yourProgress,
                icon: FontAwesomeIcons.solidInfinity,
                isSelected: _showOverallProgress,
                onTap: () {
                  if (mounted) setState(() => _showOverallProgress = true);
                },
                bgColor: AppColors.primary,
                textColor: AppColors.textPrimary,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _showOverallProgress
            ? _buildProgressCards(_overallProgress)
            : _buildProgressCards(_weekProgress),
      ],
    );
  }

  Widget _buildProgressSegment({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required Color bgColor,
    required Color textColor,
  }) {
    final color = isSelected ? textColor : AppColors.textPrimary;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? bgColor : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
            border: isSelected
                ? Border.all(color: AppColors.borderBlack, width: 1)
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeekProgress(Profile? profile) {
    final goal = profile?.weeklyGoalXP ?? 500;
    final current = _weekProgress?.weekXP ?? 0;
    final progress = goal > 0 ? (current / goal).clamp(0.0, 1.0) : 0.0;
    final goalReached = goal > 0 && current >= goal;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.weekProgress,
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
                  Icon(FontAwesomeIcons.solidShrimp,
                      size: 22, color: AppColors.secondary),
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
        if (goalReached)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderBlack, width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(FontAwesomeIcons.solidTrophy,
                    size: 18, color: AppColors.textPrimary),
                const SizedBox(width: 8),
                Text(
                  l10n.weeklyGoalReached,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              const trackHeight = 14.0;
              const fillHeight = 12.0;
              final fillWidth = (constraints.maxWidth * progress)
                  .clamp(0.0, constraints.maxWidth);
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
                        width: fillWidth.clamp(
                            fillHeight, constraints.maxWidth - 2),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                l10n.weeklyGoal(goal),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (_weekProgress != null)
              _buildDaysRemainingBadge(_weekProgress!.daysRemainingInWeek),
          ],
        ),
      ],
    );
  }

  Widget _buildDaysRemainingBadge(int days) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.neutral,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(FontAwesomeIcons.solidClock,
              size: 12, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            l10n.daysRemaining(days),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalMenuButton(
    String label,
    ContentMenu menu, {
    IconData? icon,
    required Color iconColor,
  }) {
    final isSelected = _selectedMenu == menu;

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
          if (mounted)
            setState(() {
              _selectedMenu = menu;
            });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.black,
              width: 1,
            ),
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
                          children: [
                            Icon(icon, size: 20, color: iconColor),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                label,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.chipText,
                                ),
                                textAlign: TextAlign.left,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          label,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: AppColors.chipText,
                          ),
                          textAlign: TextAlign.left,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                ),
              ),
              Icon(FontAwesomeIcons.chevronRight,
                  size: 24, color: AppColors.chipText),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = ProfileStoreScope.of(context);
    final profile = store.profile;
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
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: (_weekProgress != null &&
                                (profile?.weeklyGoalXP ?? 0) > 0 &&
                                (_weekProgress!.weekXP) >=
                                    (profile?.weeklyGoalXP ?? 0))
                            ? Border.all(color: AppColors.secondary, width: 3)
                            : null,
                      ),
                      padding: const EdgeInsets.all(2),
                      child: UserAvatar(
                          avatar: profile?.avatar,
                          avatarUrl: profile?.avatarUrl,
                          fullName: profile?.fullName),
                    ),
                    const SizedBox(width: 16),
                    Expanded(child: _buildWeekProgress(profile)),
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
                                builder: (context) =>
                                    const ProfileSettingsPage(),
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
                child: Row(
                  children: [
                    Flexible(
                      child: Text.rich(
                        TextSpan(
                          style: const TextStyle(
                            fontSize: 22,
                            color: AppColors.textPrimary,
                          ),
                          children: [
                            TextSpan(
                              text: '${AppLocalizations.of(context)!.greetings}, ',
                              style: const TextStyle(fontWeight: FontWeight.normal),
                            ),
                            TextSpan(
                              text: profile?.fullName ??
                                  Supabase.instance.client.auth.currentUser
                                      ?.userMetadata?['full_name'] ??
                                  '',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (profile?.isPremium == true) ...[
                      const SizedBox(width: 8),
                      FaIcon(
                        FontAwesomeIcons.solidCrown,
                        size: 22,
                        color: AppColors.secondary,
                      ),
                    ],
                  ],
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
                    _buildVerticalMenuButton(
                      AppLocalizations.of(context)!.contentInProgress,
                      ContentMenu.inProgress,
                      icon: FontAwesomeIcons.barProgressHalf,
                      iconColor: AppColors.textPrimary,
                    ),
                    const SizedBox(height: 12),
                    _buildVerticalMenuButton(
                        AppLocalizations.of(context)!.favoriteContent,
                        ContentMenu.favorite,
                        icon: FontAwesomeIcons.solidHeart,
                        iconColor: AppColors.primary),
                    const SizedBox(height: 12),
                    _buildVerticalMenuButton(
                      AppLocalizations.of(context)!.forYou,
                      ContentMenu.interesting,
                      icon: FontAwesomeIcons.solidBolt,
                      iconColor: AppColors.secondary,
                    ),
                    const SizedBox(height: 70),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
