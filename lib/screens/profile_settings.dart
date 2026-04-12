import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/revenue_cat_config.dart';
import '../constants/app_colors.dart';
import '../services/app_review_service.dart';
import '../l10n/app_localizations.dart';
import '../models/profile.dart';
import '../services/profile_service.dart';
import '../stores/profile_store.dart';
import '../utils/avatar.dart';
import '../widgets/avatar_widget.dart';
import '../widgets/edit_themes_bottom_sheet.dart';
import '../widgets/theme_chip.dart';
import '../constants/languages.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/week_progress_service.dart';
import '../services/onesignal_notification_service.dart';
import 'onboarding/registration_page.dart';
import 'onboarding/welcome_page.dart';

class ProfileSettingsPage extends StatefulWidget {
  final bool isVisible;

  const ProfileSettingsPage({super.key, this.isVisible = true});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  late final ProfileService profileService =
      ProfileService(Supabase.instance.client);
  late final WeekProgressService weekProgressService =
      WeekProgressService(Supabase.instance.client);
  late final OneSignalNotificationService _oneSignalNotificationService =
      OneSignalNotificationService(profileService);
  Profile? profile;
  bool isLoading = true;
  List<String> _interestThemes = [];

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    if (mounted) setState(() => isLoading = true);
    try {
      final profileData = await profileService.getProfileData();
      final weeklyProgress = await weekProgressService.getWeekProgress();
      final interestThemes = await profileService.getThemeInterests();
      setState(() {
        this._interestThemes = interestThemes;
      });
      if (mounted) {
        final avatarSeed = profileData['avatar']?.toString();
        final avatarUrl = resolveAvatarUrl(
          avatar: avatarSeed,
          avatarUrl: profileData['avatar_url']?.toString(),
        );
        setState(() {
          profile = Profile(
            fullName: profileData['full_name'] ?? '',
            email: profileData['email'] ?? '',
            avatar: avatarSeed,
            avatarUrl: avatarUrl,
            isPremium: profileData['is_premium'] ?? false,
            nativeLanguage: profileData['native_language'] ?? '',
            targetLanguage: profileData['target_language'] ?? '',
            weeklyGoalXP: profileData['weekly_goal'] != null
                ? (profileData['weekly_goal'] as num).toInt()
                : null,
            weekXP: profileData['week_xp'] != null
                ? (profileData['week_xp'] as num).toInt()
                : null,
            lastWeekXP: profileData['last_week_xp'] != null
                ? (profileData['last_week_xp'] as num).toInt()
                : null,
            weeklyArticlesRead:
                int.tryParse(weeklyProgress.weekArticlesReadCount) ?? 0,
            weeklyAudiobooksRead:
                int.tryParse(weeklyProgress.weekAudiobooksReadCount) ?? 0,
            weeklyFlashcardsAchieved:
                int.tryParse(weeklyProgress.weekFlashcardsAchievedCount) ?? 0,
            weeklyQuizzesCompleted:
                int.tryParse(weeklyProgress.weekQuizzesCompletedCount) ?? 0,
          );
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _saveWeeklyGoal(int xp) async {
    try {
      await profileService.updateWeeklyGoal(xp);
      if (mounted) {
        setState(() {
          profile = profile?.copyWith(weeklyGoalXP: xp);
        });
        ProfileStoreScope.of(context).setProfile(profile);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update goal: $e')),
        );
      }
    }
  }

  Future<void> _saveTargetLanguage(String code) async {
    try {
      await profileService.updateTargetLanguage(code);
      if (mounted) {
        setState(() {
          profile = profile?.copyWith(targetLanguage: code);
        });
        ProfileStoreScope.of(context).setProfile(profile);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update target language: $e')),
        );
      }
    }
  }

  Future<void> _saveNativeLanguage(String code) async {
    try {
      await profileService.updateNativeLanguage(code);
      if (mounted) {
        setState(() {
          profile = profile?.copyWith(nativeLanguage: code);
        });
        // Update global store so app locale (MyApp) refreshes to the new reference language
        ProfileStoreScope.of(context).setProfile(profile);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update reference language: $e')),
        );
      }
    }
  }

  void _showTargetLanguageModal() {
    final current = profile?.targetLanguage ?? 'en';
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => _buildLanguagePickerModal(
        title: AppLocalizations.of(context)!.yourTargetLanguage,
        languages: getTargetLanguages(context),
        currentCode: current,
        onSelect: (code) {
          if (code == current) {
            Navigator.of(modalContext).pop();
            return;
          }
          _showLanguageChangeConfirmModal(
            context: modalContext,
            isReference: false,
            languageName: getLanguageName(modalContext, code),
            onConfirm: () {
              _saveTargetLanguage(code);
              Navigator.of(modalContext).pop();
            },
          );
        },
      ),
    );
  }

  void _showReferenceLanguageModal() {
    final current = profile?.nativeLanguage ?? 'en';
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => _buildLanguagePickerModal(
        title: AppLocalizations.of(context)!.yourReferenceLanguage,
        languages: getReferenceLanguages(context),
        currentCode: current,
        onSelect: (code) {
          if (code == current) {
            Navigator.of(modalContext).pop();
            return;
          }
          _showLanguageChangeConfirmModal(
            context: modalContext,
            isReference: true,
            languageName: getLanguageName(modalContext, code),
            onConfirm: () {
              _saveNativeLanguage(code);
              Navigator.of(modalContext).pop();
            },
          );
        },
      ),
    );
  }

  void _showLanguageChangeConfirmModal({
    required BuildContext context,
    required bool isReference,
    required String languageName,
    required VoidCallback onConfirm,
  }) {
    final message = isReference
        ? AppLocalizations.of(context)!
            .areYouSureYouWantToDeleteReferenceLanguage(languageName)
        : AppLocalizations.of(context)!
            .areYouSureYouWantToDeleteTargetLanguage(languageName);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.changeLanguage),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              onConfirm();
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text(AppLocalizations.of(context)!.confirm),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguagePickerModal({
    required String title,
    required List<Map<String, String>> languages,
    required String currentCode,
    required ValueChanged<String> onSelect,
  }) {
    final bottomPadding = 32 + MediaQuery.of(context).padding.bottom;
    final maxModalHeight = MediaQuery.of(context).size.height * 0.7;
    return Container(
      height: maxModalHeight,
      padding: EdgeInsets.fromLTRB(24, 24, 24, bottomPadding),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              shrinkWrap: true,
              children: languages.map((lang) {
                final code = lang['code']!;
                final name = lang['name']!;
                final isSelected = code == currentCode;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.15)
                        : AppColors.neutral,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () => onSelect(code),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              getLanguageIconPath(code),
                              width: 28,
                              height: 28,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (isSelected) ...[
                              const Spacer(),
                              Icon(
                                FontAwesomeIcons.circleCheck,
                                size: 22,
                                color: AppColors.primary,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditWeeklyGoalModal() {
    final controller = TextEditingController(
      text: (profile?.weeklyGoalXP ?? 90).toString(),
    );
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppLocalizations.of(context)!.yourWeeklyGoal,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.setHowManyXpYouWant,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.xpPerWeek,
                  hintText: 'e.g. 90',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: AppColors.neutral,
                ),
                onSubmitted: (value) {
                  final xp = int.tryParse(value);
                  if (xp != null && xp > 0) {
                    _saveWeeklyGoal(xp);
                    Navigator.of(context).pop();
                  }
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(AppLocalizations.of(context)!.cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        final xp = int.tryParse(controller.text);
                        if (xp != null && xp > 0) {
                          _saveWeeklyGoal(xp);
                          Navigator.of(context).pop();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(AppLocalizations.of(context)!
                                  .pleaseEnterValidNumber),
                            ),
                          );
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(AppLocalizations.of(context)!.save),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditThemesBottomSheet() {
    EditThemesBottomSheet.show(
      context,
      initialSelectedThemes: _interestThemes,
      onSave: (selected) async {
        await profileService.updateThemeInterests(selected);
        if (mounted) {
          setState(() => _interestThemes = selected);
        }
      },
    );
  }

  Future<void> _restorePurchases() async {
    try {
      await Purchases.restorePurchases();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.purchasesRestored),
        ),
      );
      _loadProfileData();
      ProfileStoreScope.of(context).load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.restorePurchasesFailed),
        ),
      );
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteAccount),
        content: Text(
          AppLocalizations.of(context)!.deleteAccountConfirmation,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await profileService.deleteAccount();
      await _oneSignalNotificationService.logout();
      if (!mounted) return;
      ProfileStoreScope.of(context).clear();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.accountDeleted),
        ),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const WelcomePage()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.deleteAccountError),
        ),
      );
    }
  }

  Future<void> _logout() async {
    try {
      await _oneSignalNotificationService.logout();
      await Supabase.instance.client.auth.signOut();
      if (!mounted) return;
      ProfileStoreScope.of(context).clear();
      final prefs = await SharedPreferences.getInstance();
      final hasSeenWelcome = prefs.getBool('has_seen_welcome') ?? false;
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => hasSeenWelcome
              ? const RegistrationPage.loginOnly()
              : const WelcomePage(),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to log out: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Yellow header: close button, avatar, fullname (SafeArea only for top)
                SafeArea(
                  bottom: false,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            UserAvatar(
                              avatar: profile?.avatar,
                              avatarUrl: profile?.avatarUrl,
                              fullName: profile?.fullName,
                              radius: 44,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              profile?.fullName ?? 'FullName',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (profile?.email != null &&
                                profile!.email.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  '${profile?.email}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.textPrimary.withOpacity(0.6),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 16,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => Navigator.of(context).pop(),
                            customBorder: const CircleBorder(),
                            child: const Padding(
                              padding: EdgeInsets.all(8),
                              child: Icon(
                                FontAwesomeIcons.thinCircleX,
                                size: 40,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // White section: fills all remaining space to bottom
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      border: Border.all(color: AppColors.borderBlack),
                    ),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        24,
                        28,
                        24,
                        32 + MediaQuery.of(context).padding.bottom,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Your target language
                          Text(
                            AppLocalizations.of(context)!.targetLanguage,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildLanguageRow(
                            profile?.targetLanguage ?? 'en',
                            target: true,
                            onTap: _showTargetLanguageModal,
                          ),
                          const SizedBox(height: 24),
                          // Your reference language
                          Text(
                            AppLocalizations.of(context)!.sourceLanguage,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildLanguageRow(
                            profile?.nativeLanguage ?? 'en',
                            target: false,
                            onTap: _showReferenceLanguageModal,
                          ),
                          const SizedBox(height: 24),
                          // Subscription / Upgrade
                          Text(
                            AppLocalizations.of(context)!.subscription,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: profile?.isPremium == true
                                  ? AppColors.primary
                                  : AppColors.neutral,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: profile?.isPremium == true
                                    ? AppColors.primary
                                    : AppColors.borderBlack,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              profile?.isPremium == true
                                  ? 'Premium'
                                  : 'Free',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: profile?.isPremium == true
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () async {
                                await presentPaywall();
                                if (mounted) {
                                  _loadProfileData();
                                  ProfileStoreScope.of(context).load();
                                }
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.neutral,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.textGrey.withOpacity(0.5),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      FontAwesomeIcons.crown,
                                      size: 22,
                                      color: profile?.isPremium == true
                                          ? AppColors.primary
                                          : AppColors.textPrimary,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        profile?.isPremium == true
                                            ? AppLocalizations.of(context)!
                                                .manageSubscription
                                            : AppLocalizations.of(context)!
                                                .upgradeToPremium,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      FontAwesomeIcons.chevronRight,
                                      size: 24,
                                      color: AppColors.textSecondary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          if (Platform.isIOS || Platform.isAndroid) ...[
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: GestureDetector(
                                onTap: _restorePurchases,
                                child: Text(
                                  AppLocalizations.of(context)!
                                      .restorePurchases,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          // Your weekly goal + edit button
                          Text(
                            AppLocalizations.of(context)!.weekGoal,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.neutral,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color:
                                          AppColors.textGrey.withOpacity(0.5),
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'XP',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${profile?.weeklyGoalXP ?? 90}',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Material(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: const BorderSide(color: Colors.black),
                                ),
                                child: InkWell(
                                  onTap: _showEditWeeklyGoalModal,
                                  borderRadius: BorderRadius.circular(8),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          FontAwesomeIcons.pencil,
                                          size: 20,
                                          color: Colors.black,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          AppLocalizations.of(context)!.edit,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Your weekly goal + edit button
                          Text(
                            AppLocalizations.of(context)!.favoriteThemes,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: _interestThemes
                                        .map((theme) => ThemeChip(
                                            label: theme, isSelected: true))
                                        .toList(),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Material(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: const BorderSide(color: Colors.black),
                                  ),
                                  child: InkWell(
                                    onTap: _showEditThemesBottomSheet,
                                    borderRadius: BorderRadius.circular(8),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 10,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            FontAwesomeIcons.pencil,
                                            size: 20,
                                            color: Colors.black,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            AppLocalizations.of(context)!.edit,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black,
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
                          const SizedBox(height: 24),
                          // Rate the app
                          Text(
                            AppLocalizations.of(context)!.rateTheApp,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () async {
                                final opened = await AppReviewService.instance
                                    .openStoreListing();
                                if (mounted && !opened) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        AppLocalizations.of(context)!
                                            .rateTheAppStoreUnavailable,
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.neutral,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.textGrey.withOpacity(0.5),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      FontAwesomeIcons.solidStar,
                                      size: 22,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        AppLocalizations.of(context)!
                                            .rateTheApp,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      FontAwesomeIcons.chevronRight,
                                      size: 24,
                                      color: AppColors.textSecondary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Privacy Policy & Terms of Service
                          _buildSettingsLink(
                            icon: FontAwesomeIcons.shieldHalved,
                            label: AppLocalizations.of(context)!.privacyPolicy,
                            onTap: () => launchUrl(
                              Uri.parse(
                                  'https://fluemingo-app.com/privacy-policy/'),
                              mode: LaunchMode.externalApplication,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildSettingsLink(
                            icon: FontAwesomeIcons.fileContract,
                            label:
                                AppLocalizations.of(context)!.termsOfService,
                            onTap: () => launchUrl(
                              Uri.parse(
                                  'https://fluemingo-app.com/terms/'),
                              mode: LaunchMode.externalApplication,
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _logout,
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                side: const BorderSide(
                                  color: AppColors.error,
                                ),
                                foregroundColor: AppColors.error,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(
                                FontAwesomeIcons.rightFromBracket,
                                size: 18,
                              ),
                              label: Text(
                                AppLocalizations.of(context)!.logout,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: TextButton.icon(
                              onPressed: _deleteAccount,
                              style: TextButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                foregroundColor: AppColors.error,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(
                                FontAwesomeIcons.trash,
                                size: 16,
                              ),
                              label: Text(
                                AppLocalizations.of(context)!.deleteAccount,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSettingsLink({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.neutral,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.textGrey.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppColors.textPrimary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Icon(
                FontAwesomeIcons.chevronRight,
                size: 24,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageRow(String code,
      {required bool target, VoidCallback? onTap}) {
    final name = getLanguageName(context, code);
    final path = getLanguageIconPath(code);
    final content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.neutral,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.textGrey.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            path,
            width: 28,
            height: 28,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 12),
          Text(
            name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          if (onTap != null) ...[
            const Spacer(),
            Icon(FontAwesomeIcons.chevronRight,
                size: 24, color: AppColors.textSecondary),
          ],
        ],
      ),
    );
    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: content,
        ),
      );
    }
    return content;
  }
}
