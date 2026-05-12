import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'profile_service.dart';

/// OneSignal integration for push subscription sync with profiles.notification_tokens.
class OneSignalNotificationService {
  static const String _prefsOneSignalSubscriptionIdKey =
      'onesignal_subscription_id';
  static const String _envOneSignalAppId =
      String.fromEnvironment('ONESIGNAL_APP_ID');

  final ProfileService _profileService;
  static bool _isInitialized = false;

  OneSignalNotificationService(this._profileService);

  Future<void> initialize() async {
    if (_isInitialized) return;

    final appId = _envOneSignalAppId.trim();
    if (appId.isEmpty) return;

    try {
      OneSignal.initialize(appId);
      _isInitialized = true;
      _observeSubscriptionChanges();
    } catch (_) {}
  }

  Future<void> loginWithSupabaseUserId(String userId) async {
    final normalized = userId.trim();
    if (!_isInitialized || normalized.isEmpty) return;

    try {
      OneSignal.login(normalized);
    } catch (_) {}
  }

  Future<void> requestPermission() async {
    if (!_isInitialized) return;
    try {
      await OneSignal.Notifications.requestPermission(true);
    } catch (_) {}
  }

  Future<void> syncSubscriptionIdToProfile() async {
    if (!_isInitialized) return;
    try {
      final subscriptionId = OneSignal.User.pushSubscription.id;
      await _persistAndSync(subscriptionId);
    } catch (_) {}
  }

  Future<void> logout() async {
    if (!_isInitialized) return;
    try {
      OneSignal.logout();
    } catch (_) {}
  }

  void _observeSubscriptionChanges() {
    OneSignal.User.pushSubscription.addObserver((state) async {
      await _persistAndSync(state.current.id);
    });
  }

  Future<void> _persistAndSync(String? subscriptionId) async {
    final normalized = (subscriptionId ?? '').trim();
    if (normalized.isEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsOneSignalSubscriptionIdKey, normalized);
    } catch (_) {}

    try {
      await _profileService.registerNotificationToken(normalized);
    } catch (_) {}
  }
}
