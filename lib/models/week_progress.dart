class WeekProgress {
  final String weekArticlesReadCount;
  final String weekAudiobooksReadCount;
  final String weekAudiobooksChaptersReadCount;
  final String weekFlashcardsAchievedCount;
  final String weekQuizzesCompletedCount;
  final int weekXP;
  /// Jours restants dans la semaine glissante personnelle (0–7).
  final int daysRemainingInWeek;

  const WeekProgress({
    required this.weekArticlesReadCount,
    required this.weekAudiobooksReadCount,
    required this.weekFlashcardsAchievedCount,
    required this.weekQuizzesCompletedCount,
    required this.weekAudiobooksChaptersReadCount,
    required this.weekXP,
    this.daysRemainingInWeek = 0,
  });

  @override
  String toString() {
    return 'WeekProgress('
        'weekArticlesReadCount: $weekArticlesReadCount, '
        'weekAudiobooksReadCount: $weekAudiobooksReadCount, '
        'weekAudiobooksChaptersReadCount: $weekAudiobooksChaptersReadCount, '
        'weekFlashcardsAchievedCount: $weekFlashcardsAchievedCount, '
        'weekQuizzesCompletedCount: $weekQuizzesCompletedCount, '
        'weekXP: $weekXP, '
        'daysRemainingInWeek: $daysRemainingInWeek'
        ')';
  }
}
