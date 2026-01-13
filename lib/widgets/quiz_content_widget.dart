import 'package:flutter/material.dart';
import '../models/quiz_question.dart';
import '../constants/app_colors.dart';

class QuizContentWidget extends StatefulWidget {
  final List<QuizQuestion> questions;
  final Function(int correctAnswers, Map<int, int> userAnswers) onQuizComplete;
  final VoidCallback? onPreviousQuestion;
  final VoidCallback? onNextQuestion;

  const QuizContentWidget({
    super.key,
    required this.questions,
    required this.onQuizComplete,
    this.onPreviousQuestion,
    this.onNextQuestion,
  });

  @override
  State<QuizContentWidget> createState() => _QuizContentWidgetState();
}

class _QuizContentWidgetState extends State<QuizContentWidget> {
  int _currentQuestionIndex = 0;
  int? _selectedAnswerIndex;
  final Map<int, int> _userAnswers = {}; // questionIndex -> answerIndex
  final Map<int, Set<int>> _disabledAnswers = {}; // questionIndex -> Set of disabled answer indices

  QuizQuestion get currentQuestion => widget.questions[_currentQuestionIndex];
  int get totalQuestions => widget.questions.length;
  bool get isLastQuestion => _currentQuestionIndex == totalQuestions - 1;
  bool get isFirstQuestion => _currentQuestionIndex == 0;
  
  bool get isFiftyFiftyUsed => _disabledAnswers.containsKey(_currentQuestionIndex);

  void _selectAnswer(int answerIndex) {
    // Don't allow selection of disabled answers
    if (_disabledAnswers[_currentQuestionIndex]?.contains(answerIndex) ?? false) {
      return;
    }
    setState(() {
      _selectedAnswerIndex = answerIndex;
      _userAnswers[_currentQuestionIndex] = answerIndex;
    });
  }
  
  void _useFiftyFifty() {
    if (isFiftyFiftyUsed) return; // Already used for this question
    
    // Get the correct answer index (0-based)
    final correctAnswerIndex = currentQuestion.correctAnswer - 1;
    
    // Get all wrong answer indices
    final wrongAnswers = List.generate(4, (index) => index)
        .where((index) => index != correctAnswerIndex)
        .toList();
    
    // Shuffle and take 2 random wrong answers
    wrongAnswers.shuffle();
    final answersToDisable = wrongAnswers.take(2).toSet();
    
    setState(() {
      _disabledAnswers[_currentQuestionIndex] = answersToDisable;
    });
  }

  void _goToNextQuestion() {
    if (_selectedAnswerIndex == null) return;

    if (isLastQuestion) {
      // Calculate total correct answers
      int correctAnswers = 0;
      _userAnswers.forEach((questionIndex, answerIndex) {
        if (widget.questions[questionIndex].isCorrectAnswer(answerIndex)) {
          correctAnswers++;
        }
      });
      widget.onQuizComplete(correctAnswers, Map.from(_userAnswers));
    } else {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswerIndex = _userAnswers[_currentQuestionIndex];
      });
    }
  }

  void _goToPreviousQuestion() {
    if (isFirstQuestion) return;

    setState(() {
      _currentQuestionIndex--;
      _selectedAnswerIndex = _userAnswers[_currentQuestionIndex];
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.questions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'No quiz questions available',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        // Question counter and progress
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Question ${_currentQuestionIndex + 1}/$totalQuestions',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 12),
              // Progress bar
              _buildProgressBar(),
            ],
          ),
        ),

        // Main content area
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 16),
                // Quiz image
                Container(
                  width: double.infinity,
                  height: 120,
                //   decoration: BoxDecoration(
                //     color: AppColors.white,
                //     borderRadius: BorderRadius.circular(16),
                //   ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/logo/quizlogo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Question text
                Text(
                  currentQuestion.question,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // "Choose your answer" label
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Choose your answer',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.white,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Answer options grid
                _buildAnswerGrid(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),

        // Bottom navigation buttons
        _buildBottomNavigation(),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Row(
      children: List.generate(totalQuestions, (index) {
        final isCompleted = index < _currentQuestionIndex;
        final isCurrent = index == _currentQuestionIndex;
        final hasAnswer = _userAnswers.containsKey(index);

        Color barColor;
        if (isCompleted || (isCurrent && hasAnswer)) {
          barColor = AppColors.white;
        } else if (isCurrent) {
          barColor = AppColors.white.withOpacity(0.7);
        } else {
          barColor = AppColors.white.withOpacity(0.3);
        }

        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: index < totalQuestions - 1 ? 6 : 0),
            decoration: BoxDecoration(
              color: barColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildAnswerGrid() {
    final answers = currentQuestion.answers;
    final labels = ['A', 'B', 'C', 'D'];

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildAnswerButton(
                label: labels[0],
                answer: answers[0],
                index: 0,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildAnswerButton(
                label: labels[1],
                answer: answers[1],
                index: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildAnswerButton(
                label: labels[2],
                answer: answers[2],
                index: 2,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildAnswerButton(
                label: labels[3],
                answer: answers[3],
                index: 3,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnswerButton({
    required String label,
    required String answer,
    required int index,
  }) {
    final isSelected = _selectedAnswerIndex == index;
    final isDisabled = _disabledAnswers[_currentQuestionIndex]?.contains(index) ?? false;

    return GestureDetector(
      onTap: isDisabled ? null : () => _selectAnswer(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        constraints: const BoxConstraints(minHeight: 80),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isDisabled 
              ? AppColors.neutral.withOpacity(0.3)
              : (isSelected ? AppColors.secondary : AppColors.neutral),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? AppColors.borderBlack : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            isDisabled ? '' : '$label. $answer',
            style: TextStyle(
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isDisabled 
                  ? AppColors.textPrimary.withOpacity(0.3)
                  : AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.clip,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Previous button
            Expanded(
              child: GestureDetector(
                onTap: isFirstQuestion ? null : _goToPreviousQuestion,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.neutral,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: AppColors.borderBlack,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chevron_left,
                        color: isFirstQuestion
                            ? AppColors.textSecondary.withOpacity(0.5)
                            : AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Previous',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isFirstQuestion
                              ? AppColors.textSecondary.withOpacity(0.5)
                              : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Hand/Help button
            Builder(
              builder: (context) {
                final hasTip = currentQuestion.tip != null &&
                    currentQuestion.tip!.isNotEmpty;
                final isJokerDisabled = !hasTip && isFiftyFiftyUsed;
                
                return GestureDetector(
                  onTap: () {
                    if (hasTip) {
                      // Show tip if available
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(currentQuestion.tip!),
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    } else if (!isFiftyFiftyUsed) {
                      // Use 50/50 joker (only if not already used)
                      _useFiftyFifty();
                    }
                  },
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: isJokerDisabled
                          ? const Color(0xFF4A90D9).withOpacity(0.5)
                          : const Color(0xFF4A90D9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      hasTip ? Icons.lightbulb_outline : Icons.percent,
                      color: isJokerDisabled
                          ? AppColors.white.withOpacity(0.5)
                          : AppColors.white,
                      size: 24,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 12),

            // Next button
            Expanded(
              child: GestureDetector(
                onTap: _selectedAnswerIndex != null ? _goToNextQuestion : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: _selectedAnswerIndex != null
                        ? AppColors.white
                        : AppColors.neutral,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: AppColors.borderBlack,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isLastQuestion ? 'Finish' : 'Next',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _selectedAnswerIndex != null
                              ? AppColors.textPrimary
                              : AppColors.textSecondary.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right,
                        color: _selectedAnswerIndex != null
                            ? AppColors.textPrimary
                            : AppColors.textSecondary.withOpacity(0.5),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

