import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/quiz_question.dart';
import 'language_table_resolver.dart';

class QuizService {
  final SupabaseClient _supabase;

  QuizService(this._supabase);

  String _table(String name) => LanguageTableResolver.table(name);

  // Fetch quiz questions for a specific content (article) ID
  Future<List<QuizQuestion>> getQuizQuestionsForArticleContent(int contentId) async {
    try {
      final response = await _supabase
          .from(_table('quiz_models'))
          .select()
          .eq('reference_id', contentId)
          .order('id', ascending: true);

      return (response as List)
          .map((json) => QuizQuestion.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching quiz questions: $e');
      rethrow;
    }
  }

    Future<List<QuizQuestion>> getQuizQuestionsForChapterContent(String chapterId) async {
    try {
      final response = await _supabase
          .from(_table('quiz_models'))
          .select()
          .eq('type', 2)
          .eq('chapter_id', int.parse(chapterId))
          .order('id', ascending: true);
      return (response as List)
          .map((json) => QuizQuestion.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching quiz questions for chapter: $e');
      rethrow;
    }
  }

  /// Create a quiz result entry when user starts a quiz
  /// Returns the quiz result with id and filled_out status
  Future<Map<String, dynamic>?> createQuizResultForArticle({
    required int quizId,
    required String userId,
    required int referenceId,
  }) async {
    try {
        final existingQuiz = await _supabase
          .from(_table('quiz_results'))
          .select('id, number_correct_answers, filled_out')
          .eq('reference_id', referenceId)
          .eq('type', 1)
          .limit(1)
          .maybeSingle();
      if (existingQuiz != null && existingQuiz['id'] != null) return existingQuiz;

      final newQuiz = await _supabase.from(_table('quiz_results')).insert({
        'quiz_id': quizId,
        'user_id': userId,
        'reference_id': referenceId,
        'number_correct_answers': 0,
        'type': 1,
      }).select('id, filled_out').single();

      return newQuiz;
    } catch (e) {
      print('Error creating quiz result: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> createQuizResultForChapter({
    required int quizId,
    required String userId,
    required int chapterId,
  }) async {
    try {
        final existingQuiz = await _supabase
          .from(_table('quiz_results'))
          .select('id, number_correct_answers, filled_out')
          .eq('reference_id', chapterId)
          .eq('type', 2)
          .limit(1)
          .maybeSingle();
      if (existingQuiz != null && existingQuiz['id'] != null) return existingQuiz;
      final newQuiz = await _supabase.from(_table('quiz_results')).insert({
        'quiz_id': quizId,
        'user_id': userId,
        'reference_id': chapterId,
        'number_correct_answers': 0,
        'type': 2,
      }).select('id, filled_out').single();
      return newQuiz;
    } catch (e) {
      print('Error creating chapter quiz result: $e');
      return null;
    }
  }

  /// Update quiz result with the number of correct answers
  Future<void> updateQuizResult({
    required int resultId,
    required int numberCorrectAnswers,
  }) async {
    try {
      await _supabase.from(_table('quiz_results')).update({
        'number_correct_answers': numberCorrectAnswers,
        'finished_datetime': DateTime.now().toIso8601String(),
        'filled_out': true,
      }).eq('id', resultId);
    } catch (e) {
      print('Error updating quiz result: $e');
      rethrow;
    }
  }

  /// Get existing quiz result for a user and quiz
  Future<Map<String, dynamic>?> getExistingQuizResult({
    required int quizId,
    required String userId,
  }) async {
    try {
      final response = await _supabase
          .from(_table('quiz_results'))
          .select()
          .eq('quiz_id', quizId)
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      return response;
    } catch (e) {
      print('Error fetching quiz result: $e');
      return null;
    }
  }
}
