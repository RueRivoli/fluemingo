class Profile {
  final String fullName;
  final String email;
  final String? avatar;
  final String? avatarUrl;
  final bool isPremium;
  final String
      nativeLanguage; // "en", "fr", "sp", "ge", "it", "nl", "pt", "ru", "tr", "zh"
  final String targetLanguage; // "en", "fr", "sp", "ge", "it", "jp", "tk"
  int? weeklyGoalXP;
  int? weekXP;
  int? lastWeekXP;

  /// Weekly activity counts (this week)
  int? weeklyArticlesRead;
  int? weeklyAudiobooksRead;
  int? weeklyFlashcardsAchieved;
  int? weeklyQuizzesCompleted;

  Profile({
    required this.fullName,
    required this.email,
    this.avatar,
    this.avatarUrl,
    this.isPremium = false,
    required this.nativeLanguage,
    required this.targetLanguage,
    this.weeklyGoalXP,
    this.weekXP,
    this.lastWeekXP,
    this.weeklyArticlesRead,
    this.weeklyAudiobooksRead,
    this.weeklyFlashcardsAchieved,
    this.weeklyQuizzesCompleted,
  });

  Profile copyWith({
    String? fullName,
    String? email,
    String? avatar,
    String? avatarUrl,
    bool? isPremium,
    String? nativeLanguage,
    String? targetLanguage,
    int? weeklyGoalXP,
    int? weekXP,
    int? lastWeekXP,
    int? weeklyArticlesRead,
    int? weeklyAudiobooksRead,
    int? weeklyFlashcardsAchieved,
    int? weeklyQuizzesCompleted,
  }) {
    return Profile(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isPremium: isPremium ?? this.isPremium,
      nativeLanguage: nativeLanguage ?? this.nativeLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      weeklyGoalXP: weeklyGoalXP ?? this.weeklyGoalXP,
      weekXP: weekXP ?? this.weekXP,
      lastWeekXP: lastWeekXP ?? this.lastWeekXP,
      weeklyArticlesRead: weeklyArticlesRead ?? this.weeklyArticlesRead,
      weeklyAudiobooksRead: weeklyAudiobooksRead ?? this.weeklyAudiobooksRead,
      weeklyFlashcardsAchieved: weeklyFlashcardsAchieved ?? this.weeklyFlashcardsAchieved,
      weeklyQuizzesCompleted: weeklyQuizzesCompleted ?? this.weeklyQuizzesCompleted,
    );
  }
}
