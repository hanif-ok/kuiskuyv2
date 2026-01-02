class SubmissionModel {
  final String id;
  final String quizId;
  final String studentId;
  final Map<String, AnswerModel> answers;
  final double? score;
  final bool isGraded;
  final DateTime submittedAt;

  SubmissionModel({
    required this.id,
    required this.quizId,
    required this.studentId,
    required this.answers,
    this.score,
    required this.isGraded,
    required this.submittedAt,
  });

  factory SubmissionModel.fromMap(Map<String, dynamic> map, String id) {
    final answersMap = <String, AnswerModel>{};
    if (map['answers'] != null) {
      (map['answers'] as Map<String, dynamic>).forEach((key, value) {
        answersMap[key] = AnswerModel.fromMap(value);
      });
    }

    return SubmissionModel(
      id: id,
      quizId: map['quizId'] ?? '',
      studentId: map['studentId'] ?? '',
      answers: answersMap,
      score: map['score']?.toDouble(),
      isGraded: map['isGraded'] ?? false,
      submittedAt: DateTime.parse(map['submittedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'quizId': quizId,
      'studentId': studentId,
      'answers': answers.map((key, value) => MapEntry(key, value.toMap())),
      'score': score,
      'isGraded': isGraded,
      'submittedAt': submittedAt.toIso8601String(),
    };
  }
}

class AnswerModel {
  final String questionId;
  final String? selectedOption;
  final String? essayText;
  final bool? isCorrect;
  final double? pointsAwarded;
  final String? teacherFeedback;

  AnswerModel({
    required this.questionId,
    this.selectedOption,
    this.essayText,
    this.isCorrect,
    this.pointsAwarded,
    this.teacherFeedback,
  });

  factory AnswerModel.fromMap(Map<String, dynamic> map) {
    return AnswerModel(
      questionId: map['questionId'] ?? '',
      selectedOption: map['selectedOption'],
      essayText: map['essayText'],
      isCorrect: map['isCorrect'],
      pointsAwarded: map['pointsAwarded']?.toDouble(),
      teacherFeedback: map['teacherFeedback'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'questionId': questionId,
      'selectedOption': selectedOption,
      'essayText': essayText,
      'isCorrect': isCorrect,
      'pointsAwarded': pointsAwarded,
      'teacherFeedback': teacherFeedback,
    };
  }
}
