/// Supabase and OAuth configuration.
/// Keys are loaded from --dart-define environment variables at build time.
/// Example: flutter run --dart-define=SUPABASE_URL=your_url --dart-define=SUPABASE_ANON_KEY=your_key ...
class SupabaseConfig {
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY');

  // Google OAuth Client IDs
  static const String googleWebClientId =
      String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');
  static const String iosClientId = String.fromEnvironment('IOS_CLIENT_ID');

  // App Store Connect Shared Secret
  static const String appSpecificSharedSecret =
      String.fromEnvironment('APP_SPECIFIC_SHARED_SECRET');

  static bool get hasSupabaseConfig =>
      supabaseUrl.trim().isNotEmpty && supabaseAnonKey.trim().isNotEmpty;
}
