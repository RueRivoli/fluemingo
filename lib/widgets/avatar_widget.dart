import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/app_colors.dart';
import '../utils/avatar.dart' as avatar_utils;

/// Reusable user avatar that shows a profile image or initials.
/// Pass [avatarUrl] and [fullName] when available; otherwise falls back to
/// Supabase auth user metadata (e.g. OAuth avatar_url, picture, full_name).
class UserAvatar extends StatelessWidget {
  /// Optional avatar seed or URL from `profiles.avatar`.
  final String? avatar;

  /// Optional avatar URL (profile or OAuth). If null/empty, uses auth metadata.
  final String? avatarUrl;

  /// Optional display name for initials. If null/empty, uses auth metadata.
  final String? fullName;

  /// Circle radius. Defaults to 28.
  final double radius;

  const UserAvatar({
    super.key,
    this.avatar,
    this.avatarUrl,
    this.fullName,
    this.radius = 28,
  });

  /// Resolves avatar URL from [avatar] / [avatarUrl] or Supabase auth user metadata.
  static String? resolveAvatarImageUrl(String? avatar, String? avatarUrl) {
    final fromProfile = avatar_utils.resolveAvatarUrl(
      avatar: avatar,
      avatarUrl: avatarUrl,
    );
    if (fromProfile != null && fromProfile.isNotEmpty) return fromProfile;
    final metadata = Supabase.instance.client.auth.currentUser?.userMetadata;
    if (metadata == null) return null;
    return metadata['avatar_url'] ??
        metadata['picture'] ??
        metadata['picture_url'];
  }

  static bool _looksLikeSvgUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    final path = uri.path.toLowerCase();
    return path.endsWith('.svg') || path.endsWith('/svg');
  }

  /// Builds initials from full name (e.g. "John Doe" -> "JD").
  static String initials(String fullName) {
    final parts =
        fullName.trim().split(RegExp(r'\s+')).where((s) => s.isNotEmpty);
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final url = resolveAvatarImageUrl(avatar, avatarUrl);
    final name = fullName?.trim().isNotEmpty == true
        ? fullName!
        : (Supabase.instance.client.auth.currentUser?.userMetadata?['full_name']
                as String? ??
            '');
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
      final avatarChild = _looksLikeSvgUrl(url)
          ? SvgPicture.network(
              url,
              width: radius * 2,
              height: radius * 2,
              fit: BoxFit.cover,
              placeholderBuilder: (_) => initialsAvatar,
            )
          : Image.network(
              url,
              width: radius * 2,
              height: radius * 2,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => initialsAvatar,
            );
      return CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.neutral,
        child: ClipOval(
          child: avatarChild,
        ),
      );
    }
    return initialsAvatar;
  }
}
