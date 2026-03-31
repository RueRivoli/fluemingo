import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../controllers/quiz_controller.dart';
import '../l10n/app_localizations.dart';

/// Displays the quiz results with score, retry button, and per-question review.
class QuizCompletedView extends StatelessWidget {
  final QuizController quizController;

  const QuizCompletedView({super.key, required this.quizController});

  @override
  Widget build(BuildContext context) {
    final totalQuestions = quizController.totalQuestions;
    final percentage = quizController.percentageScore;

    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppLocalizations.of(context)!.quizCompleted,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${quizController.correctAnswersCount} / $totalQuestions',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$percentage% correct',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 40),
              GestureDetector(
                onTap: quizController.resetQuiz,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borderBlack, width: 1.5),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.tryAgain,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              if (quizController.hasQuestions &&
                  quizController.userAnswers.isNotEmpty) ...[
                Text(
                  AppLocalizations.of(context)!.answers,
                  style: TextStyle(
                    fontSize: 28,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 20),
                ...quizController.questions.asMap().entries.map((entry) {
                  return _QuizAnswerRow(
                    questionIndex: entry.key,
                    question: entry.value,
                    userAnswerIndex:
                        quizController.userAnswers[entry.key],
                  );
                }),
                const SizedBox(height: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _QuizAnswerRow extends StatelessWidget {
  final int questionIndex;
  final dynamic question;
  final int? userAnswerIndex;

  const _QuizAnswerRow({
    required this.questionIndex,
    required this.question,
    required this.userAnswerIndex,
  });

  @override
  Widget build(BuildContext context) {
    final isCorrect =
        userAnswerIndex != null && question.isCorrectAnswer(userAnswerIndex);
    const labels = ['A', 'B', 'C', 'D'];
    final userAnswerLabel =
        userAnswerIndex != null ? labels[userAnswerIndex!] : '';
    final correctAnswerIndex = question.correctAnswer - 1;
    final correctAnswerLabel = labels[correctAnswerIndex];
    final correctAnswerText = question.answers[correctAnswerIndex];
    final userAnswerText =
        userAnswerIndex != null ? question.answers[userAnswerIndex!] : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: isCorrect
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFF44336),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${questionIndex + 1}. ${question.question}',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (userAnswerIndex != null) ...[
                    const SizedBox(height: 8),
                    _AnswerBadge(
                      label: '$userAnswerLabel. $userAnswerText',
                      color: isCorrect
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFF44336),
                    ),
                    const SizedBox(height: 4),
                    if (!isCorrect)
                      _AnswerBadge(
                        label: '$correctAnswerLabel. $correctAnswerText',
                        color: const Color(0xFF4CAF50),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnswerBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _AnswerBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }
}
