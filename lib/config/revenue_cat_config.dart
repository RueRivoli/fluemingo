import 'dart:io';

import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

/// RevenueCat API keys loaded from --dart-define environment variables.
/// Example: flutter run --dart-define=REVENUECAT_API_KEY_IOS=your_key --dart-define=REVENUECAT_API_KEY_ANDROID=your_key
const String _revenueCatApiKeyIOS =
    String.fromEnvironment('REVENUECAT_API_KEY_IOS');
const String _revenueCatApiKeyAndroid =
    String.fromEnvironment('REVENUECAT_API_KEY_ANDROID');

/// Initializes the RevenueCat SDK. Call this once at app startup (e.g. in [main]).
Future<void> initializeRevenueCat() async {
  String apiKey;
  if (Platform.isIOS) {
    apiKey = _revenueCatApiKeyIOS;
  } else if (Platform.isAndroid) {
    apiKey = _revenueCatApiKeyAndroid;
  } else {
    // No-op on web, macOS, etc. RevenueCat is only supported on iOS and Android.
    return;
  }
  if (apiKey.isEmpty) return;
  await Purchases.configure(PurchasesConfiguration(apiKey));
}

/// Presents the RevenueCat paywall as a modal. Use from a button or when you need
/// to gate content. Returns when the user dismisses or completes a purchase.
/// On non-iOS/Android platforms this is a no-op and returns immediately.
Future<void> presentPaywall() async {
  if (!Platform.isIOS && !Platform.isAndroid) return;
  await RevenueCatUI.presentPaywall();
}
