import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/app_colors.dart';

/// Reusable user avatar that shows a profile image or initials.
/// Pass [avatarUrl] and [fullName] when available; otherwise falls back to
/// Supabase auth user metadata (e.g. OAuth avatar_url, picture, full_name).
class UserAvatar extends StatelessWidget {
  /// Optional avatar URL (profile or OAuth). If null/empty, uses auth metadata.
  final String? avatarUrl;

  /// Optional display name for initials. If null/empty, uses auth metadata.
  final String? fullName;

  /// Circle radius. Defaults to 28.
  final double radius;

  const UserAvatar({
    super.key,
    this.avatarUrl,
    this.fullName,
    this.radius = 28,
  });

  /// Resolves avatar URL from [avatarUrl] or Supabase auth user metadata.
  static String? resolveAvatarUrl(String? fromProfile) {
    if (fromProfile != null && fromProfile.isNotEmpty) return fromProfile;
    final metadata = Supabase.instance.client.auth.currentUser?.userMetadata;
    if (metadata == null) return null;
    return metadata['avatar_url'] ?? metadata['picture'] ?? metadata['picture_url'];
  }

  /// Builds initials from full name (e.g. "John Doe" -> "JD").
  static String initials(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+')).where((s) => s.isNotEmpty);
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final url = resolveAvatarUrl(avatarUrl);
    final name = fullName?.trim().isNotEmpty == true
        ? fullName!
        : (Supabase.instance.client.auth.currentUser?.userMetadata?['full_name'] as String? ?? '');
    final initial = name.isNotEmpty ? initials(name) : '?';

    final initialsAvatar = CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primary,
      child: Text(
        initial,
        style: TextStyle(
          fontSize: radius * 0.8,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
      ),
    );

    if (url != null && url.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.neutral,
        child: ClipOval(
          child: Image.network(
            url,
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => initialsAvatar,
          ),
        ),
      );
    }
    return initialsAvatar;
  }
}
