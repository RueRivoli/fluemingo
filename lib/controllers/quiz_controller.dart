import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/quiz_question.dart';
import '../services/quiz_service.dart';

class QuizController extends ChangeNotifier {
  final QuizService _quizService;
  final String articleId;
  
  List<QuizQuestion> questions = [];
  bool isLoading = true;
  int? quizResultId;
  bool isCompleted = false;
  int correctAnswersCount = 0;
  Map<int, int> userAnswers = {}; // questionIndex -> answerIndex

  QuizController({
    required QuizService quizService,
    required this.articleId,
  }) : _quizService = quizService;

  /// Initialize quiz by fetching questions and creating quiz result
  Future<void> initializeQuiz(bool retry) async {
    try {
      isLoading = true;
      notifyListeners();

      final contentId = int.tryParse(articleId);
      if (contentId == null) {
        isLoading = false;
        notifyListeners();
        return;
      }

      // Fetch quiz questions for this content
      final fetchedQuestions = await _quizService.getQuizQuestionsForContent(contentId);
      
      if (fetchedQuestions.isNotEmpty) {
        // Get current user
        final user = Supabase.instance.client.auth.currentUser;
        
        if (user != null) {
          // Create a quiz result entry using the first question's quiz_id
          final quizId = fetchedQuestions.first.quizId ?? fetchedQuestions.first.id;
          final result = await _quizService.createQuizResult(
            referenceId: contentId,
            quizId: quizId,
            userId: user.id,
            type: 1,
          );
          
          if (result != null && result['filled_out'] == true) {
            questions = fetchedQuestions;
            quizResultId = result['id'] as int?;
            correctAnswersCount = result['number_correct_answers'] as int? ?? 0;
            isCompleted = retry ? false : true;
            isLoading = false;
            notifyListeners();
          } else {
            questions = fetchedQuestions;
            quizResultId = result?['id'] as int?;
            isLoading = false;
            notifyListeners();
          }
        } else {
          questions = fetchedQuestions;
          isLoading = false;
          notifyListeners();
        }
      } else {
        isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      print('Error initializing quiz: $e');
      isLoading = false;
      notifyListeners();
    }
  }

  /// Handle quiz completion
  Future<void> onQuizComplete(int correctAnswers, Map<int, int> answers) async {
    isCompleted = true;
    correctAnswersCount = correctAnswers;
    userAnswers = answers;
    notifyListeners();

    // Update quiz result in database
    if (quizResultId != null) {
      try {
        await _quizService.updateQuizResult(
          resultId: quizResultId!,
          numberCorrectAnswers: correctAnswers,
        );
      } catch (e) {
        print('Error updating quiz result: $e');
      }
    }
  }

  /// Reset quiz for retry
  void resetQuiz() {
    isCompleted = false;
    correctAnswersCount = 0;
    userAnswers = {};
    notifyListeners();
    // Create new quiz result for retry
    initializeQuiz(true);
  }

  /// Check if quiz has questions
  bool get hasQuestions => questions.isNotEmpty;
  
  /// Get total number of questions
  int get totalQuestions => questions.length;
  
  /// Get percentage score
  int get percentageScore {
    if (totalQuestions == 0) return 0;
    return (correctAnswersCount / totalQuestions * 100).round();
  }
}

