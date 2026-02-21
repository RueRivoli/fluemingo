import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/profile.dart';
import '../services/profile_service.dart';

/// Global store for the current user's profile.
/// Use [ProfileStoreScope] to provide it and [ProfileStoreScope.of] to read it.
/// Call [load] when the user is authenticated; then [profile] and [isSubscribed] are available.

class ProfileStore extends ChangeNotifier {
  ProfileStore(this._profileService);
  final ProfileService _profileService;

  Profile? _profile;
  bool _isLoading = false;
  Object? _loadError;

  Profile? get profile => _profile;
  bool get isLoading => _isLoading;
  Object? get loadError => _loadError;

  /// True when the user has an active subscription (is premium).
  bool get isSubscribed => _profile?.isPremium ?? false;

  /// Load profile from the backend. Call when the user is authenticated.
  Future<void> load() async {
    if (_isLoading) return;
    _isLoading = true;
    _loadError = null;
    notifyListeners();

    try {
      final profileData = await _profileService.getProfileData();
      final weeklyProgress = await _profileService.getWeeklyProgress();
      _profile = Profile(
        fullName: profileData['full_name'] ?? '',
        email: profileData['email'] ?? '',
        avatarUrl: profileData['avatar_url'],
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
        weeklyArticlesRead: weeklyProgress['articles'],
        weeklyAudiobooksRead: weeklyProgress['audiobooks'],
        weeklyFlashcardsAchieved: weeklyProgress['flashcards'],
        weeklyQuizzesCompleted: weeklyProgress['quizzes'],
      );
    } catch (e) {
      _loadError = e;
      _profile = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update the stored profile (e.g. after settings change) so UI stays in sync.
  void setProfile(Profile? value) {
    if (_profile == value) return;
    _profile = value;
    notifyListeners();
  }

  /// Clear profile (e.g. on logout).
  void clear() {
    _profile = null;
    _loadError = null;
    notifyListeners();
  }
}

/// Provides [ProfileStore] to the widget tree. Use [ProfileStoreScope.of] to read it.
class ProfileStoreScope extends InheritedNotifier<ProfileStore> {
  const ProfileStoreScope({
    super.key,
    required ProfileStore profileStore,
    required super.child,
  }) : super(notifier: profileStore);

  static ProfileStore of(BuildContext context) {
    final store = context.dependOnInheritedWidgetOfExactType<ProfileStoreScope>()?.notifier;
    assert(store != null, 'ProfileStoreScope not found. Wrap your app with ProfileStoreScope.');
    return store!;
  }
}

/// Call [ProfileStore.load] when mounted. Wrap the home content so profile is loaded once the user is in the app.
class ProfileLoader extends StatefulWidget {
  const ProfileLoader({super.key, required this.child});

  final Widget child;

  @override
  State<ProfileLoader> createState() => _ProfileLoaderState();
}

class _ProfileLoaderState extends State<ProfileLoader> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ProfileStoreScope.of(context).load();
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
