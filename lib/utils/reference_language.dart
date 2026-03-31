import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Fetches the user's native/reference language code from the `profiles` table.
///
/// Returns `'en'` when the user is not authenticated or the profile has no
/// `native_language` value.
class ReferenceLanguage {
  static Future<String> getReferenceLanguageCode(
      SupabaseClient supabase) async {
    final user = supabase.auth.currentUser;
    if (user == null) return 'en';
    try {
      final profile = await supabase
          .from('profiles')
          .select('native_language')
          .eq('id', user.id)
          .maybeSingle();
      final referenceLanguage =
          (profile?['native_language'] ?? '').toString().trim().toLowerCase();
      if (referenceLanguage.isNotEmpty) return referenceLanguage;
    } catch (e) {
      debugPrint('Error fetching reference language: $e');
    }
    return 'en';
  }
}
