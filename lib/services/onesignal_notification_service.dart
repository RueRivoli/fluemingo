import 'package:flutter/foundation.dart';
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
    if (appId.isEmpty) {
      debugPrint(
          'OneSignal init skipped: missing --dart-define=ONESIGNAL_APP_ID');
      return;
    }

    try {
      OneSignal.initialize(appId);
      _isInitialized = true;
      _observeSubscriptionChanges();
    } catch (e) {
      debugPrint('OneSignal initialization failed: $e');
    }
  }

  Future<void> loginWithSupabaseUserId(String userId) async {
    final normalized = userId.trim();
    if (!_isInitialized || normalized.isEmpty) return;

    try {
      OneSignal.login(normalized);
    } catch (e) {
      debugPrint('OneSignal login failed: $e');
    }
  }

  Future<void> requestPermission() async {
    if (!_isInitialized) return;
    try {
      await OneSignal.Notifications.requestPermission(true);
    } catch (e) {
      debugPrint('OneSignal permission request failed: $e');
    }
  }

  Future<void> syncSubscriptionIdToProfile() async {
    if (!_isInitialized) return;
    try {
      final subscriptionId = OneSignal.User.pushSubscription.id;
      await _persistAndSync(subscriptionId);
    } catch (e) {
      debugPrint('OneSignal subscription sync failed: $e');
    }
  }

  Future<void> logout() async {
    if (!_isInitialized) return;
    try {
      OneSignal.logout();
    } catch (e) {
      debugPrint('OneSignal logout failed: $e');
    }
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
    } catch (e) {
      debugPrint('Failed to persist OneSignal subscription id locally: $e');
    }

    try {
      await _profileService.registerNotificationToken(normalized);
    } catch (e) {
      debugPrint('Failed to sync OneSignal subscription id to profile: $e');
    }
  }
}
