import 'package:shared_preferences/shared_preferences.dart';

import 'profile_service.dart';

/// Syncs a device push token into profiles.notification_tokens when available.
///
/// Token sources (in order):
/// 1) Compile-time define: --dart-define=ONESIGNAL_SUBSCRIPTION_ID=...
/// 2) SharedPreferences: onesignal_subscription_id
/// 3) SharedPreferences: push_notification_token (legacy)
/// 4) SharedPreferences: fcm_token (legacy; ignored when it looks like an FCM token)
class NotificationTokenSyncService {
  static const String _prefsOneSignalSubscriptionIdKey =
      'onesignal_subscription_id';
  static const String _prefsPushTokenKey = 'push_notification_token';
  static const String _prefsFcmTokenKey = 'fcm_token';
  static const String _envOneSignalSubscriptionId =
      String.fromEnvironment('ONESIGNAL_SUBSCRIPTION_ID');

  final ProfileService _profileService;

  const NotificationTokenSyncService(this._profileService);

  bool _looksLikeLegacyFcmToken(String token) {
    final value = token.trim();
    return value.contains(':') || value.length > 80;
  }

  Future<String?> _resolveToken() async {
    final envToken = _envOneSignalSubscriptionId.trim();
    if (envToken.isNotEmpty) return envToken;

    final prefs = await SharedPreferences.getInstance();
    final oneSignalToken =
        (prefs.getString(_prefsOneSignalSubscriptionIdKey) ?? '').trim();
    if (oneSignalToken.isNotEmpty) return oneSignalToken;

    final pushToken = (prefs.getString(_prefsPushTokenKey) ?? '').trim();
    if (pushToken.isNotEmpty && !_looksLikeLegacyFcmToken(pushToken)) {
      return pushToken;
    }

    final fcmToken = (prefs.getString(_prefsFcmTokenKey) ?? '').trim();
    if (fcmToken.isNotEmpty && !_looksLikeLegacyFcmToken(fcmToken)) {
      return fcmToken;
    }

    return null;
  }

  Future<void> syncIfAvailable() async {
    final token = await _resolveToken();
    if (token == null || token.isEmpty) return;
    await _profileService.registerNotificationToken(token);
  }
}
