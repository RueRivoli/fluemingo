import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Shared helper for constructing Supabase Storage public URLs.
///
/// All content files live in the `content` bucket. This class centralises the
/// path-cleaning logic that was previously duplicated across services.
class StorageUrlHelper {
  static const String _storageBucket = 'content';

  /// Get full public URL for a file stored in Supabase Storage.
  ///
  /// Handles paths that are already full URLs, leading slashes, and the
  /// redundant `content/` prefix.
  static String getStorageUrl(SupabaseClient supabase, String? path) {
    if (path == null || path.isEmpty) return '';

    if (path.startsWith('http://') || path.startsWith('https://')) return path;

    String cleanPath = path.startsWith('/') ? path.substring(1) : path;
    if (cleanPath.startsWith('content/')) {
      cleanPath = cleanPath.substring('content/'.length);
    }

    try {
      return supabase.storage.from(_storageBucket).getPublicUrl(cleanPath);
    } catch (e) {
      debugPrint('Error constructing storage URL: $e');
      return '';
    }
  }

  /// Alias for [getStorageUrl] -- semantic convenience for image paths.
  static String getImageUrl(SupabaseClient supabase, String? imgPath) {
    return getStorageUrl(supabase, imgPath);
  }

  /// Returns a public URL for an audio file, or `null` when the path is empty.
  static String? getAudioUrl(SupabaseClient supabase, String? audioPath) {
    if (audioPath == null || audioPath.isEmpty) return null;
    return getStorageUrl(supabase, audioPath);
  }
}
