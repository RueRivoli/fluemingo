import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/week_progress.dart';

const int XP_PER_ARTICLE = 10;
const int XP_PER_AUDIOBOOK = 20;
const int XP_PER_FLASHCARD = 1;
const int XP_PER_QUIZ = 4;

class WeekProgressService {
  final SupabaseClient _supabase;

  WeekProgressService(this._supabase);

  /// Start of current week (Monday 00:00 UTC) as ISO string.
  static String _startOfWeekIso() {
    final now = DateTime.now().toUtc();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final start = DateTime.utc(monday.year, monday.month, monday.day);
    return start.toIso8601String();
  }

   static int _calculateWeekXP(int articlesReadCount, int audiobooksReadCount, int flashcardsAchievedCount, int quizzesCompletedCount) {
    return articlesReadCount * XP_PER_ARTICLE + audiobooksReadCount * XP_PER_AUDIOBOOK + flashcardsAchievedCount * XP_PER_FLASHCARD + quizzesCompletedCount * XP_PER_QUIZ;
  }
  /// Returns week progress for the current user since the beginning of this week.
  Future<WeekProgress> getWeekProgress() async {
    print('-- getWeekProgress -- ');
    final user = _supabase.auth.currentUser;
    const empty = WeekProgress(
      weekArticlesReadCount: '0',
      weekAudiobooksReadCount: '0',
      weekFlashcardsAchievedCount: '0',
      weekQuizzesCompletedCount: '0',
      weekXP: 0,
    );
    if (user == null) return empty;

    final startOfWeek = _startOfWeekIso();
    try {
      final articlesRes = await _supabase
          .from('progress_fr')
          .select('id')
          .eq('user_id', user.id)
          .eq('content_type', 1)
          .eq('reading_status', 'finished')
          .gte('finished_datetime', startOfWeek);
      final audiobooksRes = await _supabase
          .from('progress_fr')
          .select('id')
          .eq('user_id', user.id)
          .eq('content_type', 2)
          .isFilter('chapter_id', null)
          .eq('reading_status', 'finished')
          .gte('finished_datetime', startOfWeek);
      final flashcardsRes = await _supabase
          .from('flashcards_fr')
          .select('id')
          .eq('user_id', user.id)
          .eq('status', 'mastered')
          .gte('finished_datetime', startOfWeek);
      final quizzesRes = await _supabase
          .from('quiz_results_fr')
          .select('id')
          .eq('user_id', user.id)
          .eq('filled_out', true)
          .gte('finished_datetime', startOfWeek);

      final weekXP = _calculateWeekXP(articlesRes.length, audiobooksRes.length, flashcardsRes.length, quizzesRes.length);

      print('articlesRes: ${articlesRes.length}');
      print('audiobooksRes: ${audiobooksRes.length}');
      print('flashcardsRes: ${flashcardsRes.length}');
      print('quizzesRes: ${quizzesRes.length}');
      return WeekProgress(
        weekArticlesReadCount: (articlesRes as List).length.toString(),
        weekAudiobooksReadCount: (audiobooksRes as List).length.toString(),
        weekFlashcardsAchievedCount: (flashcardsRes as List).length.toString(),
        weekQuizzesCompletedCount: (quizzesRes as List).length.toString(),
        weekXP: weekXP,
      );
    } catch (e) {
      print('Error fetching week progress: $e');
      return empty;
    }
  }

  /// Returns overall (all-time) progress for the current user since the start.
  Future<WeekProgress> getOverallProgress() async {
    final user = _supabase.auth.currentUser;
    const empty = WeekProgress(
      weekArticlesReadCount: '0',
      weekAudiobooksReadCount: '0',
      weekFlashcardsAchievedCount: '0',
      weekQuizzesCompletedCount: '0',
      weekXP: 0,
    );
    if (user == null) return empty;

    try {
      final articlesRes = await _supabase
          .from('progress_fr')
          .select('id')
          .eq('user_id', user.id)
          .eq('content_type', 1)
          .eq('reading_status', 'finished');
      final audiobooksRes = await _supabase
          .from('progress_fr')
          .select('id')
          .eq('user_id', user.id)
          .eq('content_type', 2)
          .isFilter('chapter_id', null)
          .eq('reading_status', 'finished');
      final flashcardsRes = await _supabase
          .from('flashcards_fr')
          .select('id')
          .eq('user_id', user.id)
          .eq('status', 'mastered');
      final quizzesRes = await _supabase
          .from('quiz_results_fr')
          .select('id')
          .eq('user_id', user.id)
          .eq('filled_out', true);

      final articlesCount = (articlesRes as List).length;
      final audiobooksCount = (audiobooksRes as List).length;
      final flashcardsCount = (flashcardsRes as List).length;
      final quizzesCount = (quizzesRes as List).length;
      final totalXP = _calculateWeekXP(articlesCount, audiobooksCount, flashcardsCount, quizzesCount);

      return WeekProgress(
        weekArticlesReadCount: articlesCount.toString(),
        weekAudiobooksReadCount: audiobooksCount.toString(),
        weekFlashcardsAchievedCount: flashcardsCount.toString(),
        weekQuizzesCompletedCount: quizzesCount.toString(),
        weekXP: totalXP,
      );
    } catch (e) {
      print('Error fetching overall progress: $e');
      return empty;
    }
  }
}

