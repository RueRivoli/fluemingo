import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/week_progress.dart';
import 'language_table_resolver.dart';

const int XP_PER_ARTICLE = 10;
const int XP_PER_AUDIOBOOK_CHAPTER = 10;
const int XP_PER_FLASHCARD = 1;
const int XP_PER_QUIZ = 4;

class WeekProgressService {
  final SupabaseClient _supabase;

  WeekProgressService(this._supabase);

  String _table(String name) => LanguageTableResolver.table(name);

  static DateTime _rollingWeekStart(DateTime anchor) {
    final now = DateTime.now().toUtc();
    final anchorDay = DateTime.utc(anchor.year, anchor.month, anchor.day);
    final daysSinceAnchor = now.difference(anchorDay).inDays;
    final weekStart =
        anchorDay.add(Duration(days: (daysSinceAnchor ~/ 7) * 7));
    return weekStart;
  }

  static int _daysRemaining(DateTime weekStart) {
    final now = DateTime.now().toUtc();
    final weekEnd = weekStart.add(const Duration(days: 7));
    final days = weekEnd.difference(now).inDays.clamp(0, 7);
    return days;
  }

  static int _calculateWeekXP(int articlesReadCount,
      int audiobooksChaptersReadCount,
      int flashcardsAchievedCount, int quizzesCompletedCount) {
    return articlesReadCount * XP_PER_ARTICLE +
        audiobooksChaptersReadCount * XP_PER_AUDIOBOOK_CHAPTER +
        flashcardsAchievedCount * XP_PER_FLASHCARD +
        quizzesCompletedCount * XP_PER_QUIZ;
  }

  Future<DateTime?> _fetchAnchor() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;
      final res = await _supabase
          .from('profiles')
          .select('created_at')
          .eq('id', user.id)
          .single();
      final str = res['created_at']?.toString();
      final parsed = str != null ? DateTime.tryParse(str)?.toUtc() : null;
      return parsed;
    } catch (_) {
      return null;
    }
  }

  /// Returns week progress for the current user for the rolling personal week.
  Future<WeekProgress> getWeekProgress({DateTime? anchorDate}) async {
    final user = _supabase.auth.currentUser;
    const empty = WeekProgress(
      weekArticlesReadCount: '0',
      weekAudiobooksReadCount: '0',
      weekAudiobooksChaptersReadCount: '0',
      weekFlashcardsAchievedCount: '0',
      weekQuizzesCompletedCount: '0',
      weekXP: 0,
      daysRemainingInWeek: 7,
    );
    if (user == null) return empty;

    final fetched = anchorDate ?? await _fetchAnchor();
    final anchor = fetched ?? DateTime.now().toUtc();
    final weekStart = _rollingWeekStart(anchor);
    final startOfWeek = weekStart.toIso8601String();
    final daysLeft = _daysRemaining(weekStart);
    try {
      final results = await Future.wait([
        _supabase
            .from(_table('progress'))
            .select('id')
            .eq('user_id', user.id)
            .eq('content_type', 1)
            .eq('reading_status', 'finished')
            .gte('finished_datetime', startOfWeek),
        _supabase
            .from(_table('progress'))
            .select('id')
            .eq('user_id', user.id)
            .eq('content_type', 2)
            .isFilter('chapter_id', null)
            .eq('reading_status', 'finished')
            .gte('finished_datetime', startOfWeek),
        _supabase
            .from(_table('progress'))
            .select('id')
            .eq('user_id', user.id)
            .eq('content_type', 2)
            .not('chapter_id', 'is', null)
            .eq('reading_status', 'finished')
            .gte('finished_datetime', startOfWeek),
        _supabase
            .from(_table('flashcards'))
            .select('id')
            .eq('user_id', user.id)
            .eq('status', 'mastered')
            .gte('finished_datetime', startOfWeek),
        _supabase
            .from(_table('quiz_results'))
            .select('id')
            .eq('user_id', user.id)
            .eq('filled_out', true)
            .gte('finished_datetime', startOfWeek),
      ]);
      final articlesRes = results[0] as List;
      final audiobooksRes = results[1] as List;
      final audiobooksChaptersRes = results[2] as List;
      final flashcardsRes = results[3] as List;
      final quizzesRes = results[4] as List;
      final weekXP = _calculateWeekXP(articlesRes.length,
          audiobooksChaptersRes.length, flashcardsRes.length, quizzesRes.length);

      return WeekProgress(
        weekArticlesReadCount: articlesRes.length.toString(),
        weekAudiobooksReadCount: audiobooksRes.length.toString(),
        weekAudiobooksChaptersReadCount:
            audiobooksChaptersRes.length.toString(),
        weekFlashcardsAchievedCount: flashcardsRes.length.toString(),
        weekQuizzesCompletedCount: quizzesRes.length.toString(),
        weekXP: weekXP,
        daysRemainingInWeek: daysLeft,
      );
    } catch (_) {
      return empty;
    }
  }

  /// Returns overall (all-time) progress for the current user since the start.
  Future<WeekProgress> getOverallProgress() async {
    final user = _supabase.auth.currentUser;
    const empty = WeekProgress(
      weekArticlesReadCount: '0',
      weekAudiobooksReadCount: '0',
      weekAudiobooksChaptersReadCount: '0',
      weekFlashcardsAchievedCount: '0',
      weekQuizzesCompletedCount: '0',
      weekXP: 0,
    );
    if (user == null) return empty;

    try {
      final results = await Future.wait([
        _supabase
            .from(_table('progress'))
            .select('id')
            .eq('user_id', user.id)
            .eq('content_type', 1)
            .eq('reading_status', 'finished'),
        _supabase
            .from(_table('progress'))
            .select('id')
            .eq('user_id', user.id)
            .eq('content_type', 2)
            .isFilter('chapter_id', null)
            .eq('reading_status', 'finished'),
        _supabase
            .from(_table('progress'))
            .select('id')
            .eq('user_id', user.id)
            .eq('content_type', 2)
            .not('chapter_id', 'is', null)
            .eq('reading_status', 'finished'),
        _supabase
            .from(_table('flashcards'))
            .select('id')
            .eq('user_id', user.id)
            .eq('status', 'mastered'),
        _supabase
            .from(_table('quiz_results'))
            .select('id')
            .eq('user_id', user.id)
            .eq('filled_out', true),
      ]);

      final articlesCount = (results[0] as List).length;
      final audiobooksCount = (results[1] as List).length;
      final audiobooksChaptersCount = (results[2] as List).length;
      final flashcardsCount = (results[3] as List).length;
      final quizzesCount = (results[4] as List).length;
      final totalXP = _calculateWeekXP(
          articlesCount, audiobooksCount, flashcardsCount, quizzesCount);

      return WeekProgress(
        weekArticlesReadCount: articlesCount.toString(),
        weekAudiobooksReadCount: audiobooksCount.toString(),
        weekAudiobooksChaptersReadCount: audiobooksChaptersCount.toString(),
        weekFlashcardsAchievedCount: flashcardsCount.toString(),
        weekQuizzesCompletedCount: quizzesCount.toString(),
        weekXP: totalXP,
      );
    } catch (_) {
      return empty;
    }
  }
}
