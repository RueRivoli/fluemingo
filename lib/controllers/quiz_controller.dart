import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/quiz_question.dart';
import '../services/quiz_service.dart';

class QuizController extends ChangeNotifier {
  final QuizService _quizService;
  final String? articleId;
  final String? chapterId;
  final int contentType;
  
  List<QuizQuestion> questions = [];
  bool isLoading = true;
  int? quizResultId;
  bool isCompleted = false;
  int correctAnswersCount = 0;
  Map<int, int> userAnswers = {}; // questionIndex -> answerIndex

  QuizController({
    required QuizService quizService,
    this.articleId,
    this.chapterId,
    required this.contentType,
  }) : _quizService = quizService;

  /// Initialize quiz by fetching questions and creating quiz result
  Future<void> initializeQuiz(bool retry) async {
    print('Initializing quiz for content type: $contentType');
    try {
      isLoading = true;
      notifyListeners();
      final contentId = contentType == 1 ? int.tryParse(articleId!) : int.tryParse(chapterId!);
       print('CHAPTER ID: $chapterId');
      if (contentType == 1 && contentId == null) {
        isLoading = false;
        notifyListeners();
        return;
      }
      print('TRY');
      if (contentType == 2 && chapterId == null) {
        isLoading = false;
        notifyListeners();
        return;
      }
      print('Cezfzezfe');
      // Fetch quiz questions for this content
      final fetchedQuestions = contentType == 1 
          ? await _quizService.getQuizQuestionsForArticleContent(contentId!) 
          : await _quizService.getQuizQuestionsForChapterContent(chapterId!);
      print('Fetched questions: $fetchedQuestions');
      if (fetchedQuestions.isNotEmpty) {
        // Get current user
        final user = Supabase.instance.client.auth.currentUser;
        
        if (user != null) {
          // Create a quiz result entry using the first question's quiz_id
          final quizId = fetchedQuestions.first.quizId ?? fetchedQuestions.first.id;
          final result = contentType == 1 ? await _quizService.createQuizResultForArticle(
            referenceId: contentId!,
              quizId: quizId,
              userId: user.id,
            ) : await _quizService.createQuizResultForChapter(
              chapterId: int.parse(chapterId!),
              quizId: quizId,
              userId: user.id,
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

