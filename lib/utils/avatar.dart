const String _openPeepsBaseUrl = 'https://api.dicebear.com/9.x/open-peeps/svg';

/// Composition tuning for circular framing:
/// - `scale` (0-200, default 100): Open Peeps figures fill the square viewBox
///   at 100, so scaling down leaves margin inside the circle.
/// - `translateY` (-100..100): the figure is bottom-anchored in the viewBox,
///   which leaves headroom at the top and clips the shoulders at the bottom.
///   A negative value lifts it so the head is vertically centered.
const String _openPeepsParams = 'scale=70&translateY=-8';

String buildOpenPeepsAvatarUrl(String seed) {
  final normalizedSeed = seed.trim();
  if (normalizedSeed.isEmpty) {
    return '$_openPeepsBaseUrl?$_openPeepsParams';
  }
  final encodedSeed = Uri.encodeQueryComponent(normalizedSeed);
  return '$_openPeepsBaseUrl?seed=$encodedSeed&$_openPeepsParams';
}

String? resolveAvatarUrl({
  String? avatar,
  String? avatarUrl,
}) {
  final normalizedAvatar = avatar?.trim();
  if (normalizedAvatar != null && normalizedAvatar.isNotEmpty) {
    if (normalizedAvatar.startsWith('http://') ||
        normalizedAvatar.startsWith('https://')) {
      return normalizedAvatar;
    }
    return buildOpenPeepsAvatarUrl(normalizedAvatar);
  }

  final normalizedAvatarUrl = avatarUrl?.trim();
  if (normalizedAvatarUrl != null && normalizedAvatarUrl.isNotEmpty) {
    return normalizedAvatarUrl;
  }

  return null;
}
