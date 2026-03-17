const String _openPeepsBaseUrl = 'https://api.dicebear.com/9.x/open-peeps/svg';

String buildOpenPeepsAvatarUrl(String seed) {
  final normalizedSeed = seed.trim();
  if (normalizedSeed.isEmpty) {
    return _openPeepsBaseUrl;
  }
  final encodedSeed = Uri.encodeQueryComponent(normalizedSeed);
  return '$_openPeepsBaseUrl?seed=$encodedSeed';
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
