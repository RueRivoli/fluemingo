class WeekProgress {
  final String weekArticlesReadCount;
  final String weekAudiobooksReadCount;
  final String weekAudiobooksChaptersReadCount;
  final String weekFlashcardsAchievedCount;
  final String weekQuizzesCompletedCount;
  final int weekXP;

  const WeekProgress({
    required this.weekArticlesReadCount,
    required this.weekAudiobooksReadCount,
    required this.weekFlashcardsAchievedCount,
    required this.weekQuizzesCompletedCount,
    required this.weekAudiobooksChaptersReadCount,
    required this.weekXP,
  });

  @override
  String toString() {
    return 'WeekProgress('
        'weekArticlesReadCount: $weekArticlesReadCount, '
        'weekAudiobooksReadCount: $weekAudiobooksReadCount, '
        'weekAudiobooksChaptersReadCount: $weekAudiobooksChaptersReadCount, '
        'weekFlashcardsAchievedCount: $weekFlashcardsAchievedCount, '
        'weekQuizzesCompletedCount: $weekQuizzesCompletedCount, '
        'weekXP: $weekXP'
        ')';
  }
}
