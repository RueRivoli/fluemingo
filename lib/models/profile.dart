import '../models/article.dart';
import '../models/audiobook.dart';

class Profile {
  final String fullName;
  final String email;
  final String? avatarUrl;
  final bool isPremium;
  final String nativeLanguage; // "en", "fr", "sp", "ge", "it", "nl", "pt", "ru", "tr", "zh"
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
}


