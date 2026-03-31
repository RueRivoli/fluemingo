import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Handles in-app review prompt and opening store listing.
///
/// - [requestReviewIfAppropriate]: use after a positive moment (e.g. finished
///   reading an article). Throttled (once per 60 days) so the system prompt
///   is not wasted. iOS/Android enforce their own quotas.
/// - [openStoreListing]: opens App Store / Play Store. Use for a permanent
///   "Rate the app" button in settings (no quota).
class AppReviewService {
  AppReviewService._();
  static final AppReviewService instance = AppReviewService._();

  static const String _keyLastRequestDate = 'app_review_last_request_date';
  static const int _daysBetweenPrompts = 30;

  final InAppReview _inAppReview = InAppReview.instance;

  /// App Store ID (iOS/macOS). Loaded from --dart-define=APPLE_APP_STORE_ID=...
  /// Find in App Store Connect > App > General > App Information > Apple ID.
  static const String appStoreId =
      String.fromEnvironment('APPLE_APP_STORE_ID');

  /// Opens the store listing (App Store / Play Store). Use for a "Rate the app" button.
  /// Returns true if the call succeeded, false if ID is not set or opening failed (e.g. on simulator).
  Future<bool> openStoreListing() async {
    if (appStoreId.isEmpty) {
      return false;
    }
    try {
      await _inAppReview.openStoreListing(appStoreId: appStoreId);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Requests the system in-app review dialog if appropriate.
  /// Call after a positive moment (e.g. user finished reading an article).
  /// Throttled to at most once every [_daysBetweenPrompts] days.
  Future<void> requestReviewIfAppropriate() async {
    final available = await _inAppReview.isAvailable();
    if (!available) return;

    final prefs = await SharedPreferences.getInstance();
    final lastStr = prefs.getString(_keyLastRequestDate);
    if (lastStr != null) {
      final last = DateTime.tryParse(lastStr);
      if (last != null &&
          DateTime.now().difference(last).inDays < _daysBetweenPrompts) {
        return; // Too soon
      }
    }

    await _inAppReview.requestReview();
    await prefs.setString(_keyLastRequestDate, DateTime.now().toIso8601String());
  }
}
