class QuizQuestion {
  final int id;
  final String question;
  final String answer1;
  final String answer2;
  final String answer3;
  final String answer4;
  final int correctAnswer; // 1, 2, 3, or 4
  final String? tip;
  final int? type;
  final int? quizId;
  final int? referenceId;
  final int? chapterId;

  QuizQuestion({
    required this.id,
    required this.question,
    required this.answer1,
    required this.answer2,
    required this.answer3,
    required this.answer4,
    required this.correctAnswer,
    this.tip,
    this.type,
    this.quizId,
    this.referenceId,
    this.chapterId,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] as int,
      question: json['question'] ?? '',
      answer1: json['answer_1'] ?? '',
      answer2: json['answer_2'] ?? '',
      answer3: json['answer_3'] ?? '',
      answer4: json['answer_4'] ?? '',
      correctAnswer: json['correct_answer'] as int,
      tip: json['tip'],
      type: json['type'],
      quizId: json['quiz_id'],
      referenceId: json['reference_id'],
      chapterId: json['chapter_id'],
    );
  }

  List<String> get answers => [answer1, answer2, answer3, answer4];
  
  bool isCorrectAnswer(int answerIndex) => answerIndex + 1 == correctAnswer;
}

