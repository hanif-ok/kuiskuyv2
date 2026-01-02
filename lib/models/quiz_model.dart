class QuizModel {
  final String id;
  final String title;
  final String classId;
  final String teacherId;
  final List<QuestionModel> questions;
  final bool showScoresAfterTest;
  final bool showCorrectionsAfterTest;
  final DateTime createdAt;

  QuizModel({
    required this.id,
    required this.title,
    required this.classId,
    required this.teacherId,
    required this.questions,
    required this.showScoresAfterTest,
    required this.showCorrectionsAfterTest,
    required this.createdAt,
  });

  factory QuizModel.fromMap(Map<String, dynamic> map, String id) {
    return QuizModel(
      id: id,
      title: map['title'] ?? '',
      classId: map['classId'] ?? '',
      teacherId: map['teacherId'] ?? '',
      questions: (map['questions'] as List<dynamic>?)
              ?.map((q) => QuestionModel.fromMap(q))
              .toList() ??
          [],
      showScoresAfterTest: map['showScoresAfterTest'] ?? false,
      showCorrectionsAfterTest: map['showCorrectionsAfterTest'] ?? false,
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'classId': classId,
      'teacherId': teacherId,
      'questions': questions.map((q) => q.toMap()).toList(),
      'showScoresAfterTest': showScoresAfterTest,
      'showCorrectionsAfterTest': showCorrectionsAfterTest,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class QuestionModel {
  final String id;
  final String text;
  final QuestionType type;
  final String? imageUrl;
  final String? audioUrl;
  final List<String>? options;
  final int? correctOptionIndex;
  final int points;

  QuestionModel({
    required this.id,
    required this.text,
    required this.type,
    this.imageUrl,
    this.audioUrl,
    this.options,
    this.correctOptionIndex,
    required this.points,
  });

  factory QuestionModel.fromMap(Map<String, dynamic> map) {
    return QuestionModel(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      type: QuestionType.values.firstWhere(
        (e) => e.toString() == 'QuestionType.${map['type']}',
        orElse: () => QuestionType.mcq,
      ),
      imageUrl: map['imageUrl'],
      audioUrl: map['audioUrl'],
      options: map['options'] != null ? List<String>.from(map['options']) : null,
      correctOptionIndex: map['correctOptionIndex'],
      points: map['points'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'type': type.toString().split('.').last,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'options': options,
      'correctOptionIndex': correctOptionIndex,
      'points': points,
    };
  }
}

enum QuestionType {
  mcq,
  essay,
}
