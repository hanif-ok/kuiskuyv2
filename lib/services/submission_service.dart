import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/submission_model.dart';
import '../models/quiz_model.dart';

class SubmissionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<SubmissionModel> submitQuiz({
    required String quizId,
    required String studentId,
    required Map<String, AnswerModel> answers,
    required QuizModel quiz,
  }) async {
    // Auto-grade MCQ questions
    double totalScore = 0;
    int totalPoints = 0;
    bool hasEssays = false;

    final gradedAnswers = <String, AnswerModel>{};

    for (final question in quiz.questions) {
      totalPoints += question.points;
      final answer = answers[question.id];

      if (answer != null) {
        if (question.type == QuestionType.mcq) {
          final isCorrect = answer.selectedOption != null &&
              question.options != null &&
              question.correctOptionIndex != null &&
              question.options![question.correctOptionIndex!] ==
                  answer.selectedOption;

          final pointsAwarded = isCorrect ? question.points.toDouble() : 0.0;
          totalScore += pointsAwarded;

          gradedAnswers[question.id] = AnswerModel(
            questionId: question.id,
            selectedOption: answer.selectedOption,
            essayText: answer.essayText,
            isCorrect: isCorrect,
            pointsAwarded: pointsAwarded,
            teacherFeedback: null,
          );
        } else {
          hasEssays = true;
          gradedAnswers[question.id] = answer;
        }
      }
    }

    final submission = SubmissionModel(
      id: '',
      quizId: quizId,
      studentId: studentId,
      answers: gradedAnswers,
      score: hasEssays ? null : (totalScore / totalPoints * 100),
      isGraded: !hasEssays,
      submittedAt: DateTime.now(),
    );

    final docRef = await _firestore.collection('submissions').add(submission.toMap());

    return SubmissionModel(
      id: docRef.id,
      quizId: quizId,
      studentId: studentId,
      answers: gradedAnswers,
      score: submission.score,
      isGraded: submission.isGraded,
      submittedAt: submission.submittedAt,
    );
  }

  Future<void> gradeEssay({
    required String submissionId,
    required String questionId,
    required double pointsAwarded,
    String? teacherFeedback,
  }) async {
    final submissionDoc = await _firestore.collection('submissions').doc(submissionId).get();
    final submission = SubmissionModel.fromMap(submissionDoc.data()!, submissionId);

    final updatedAnswers = Map<String, AnswerModel>.from(submission.answers);
    final answer = updatedAnswers[questionId]!;

    updatedAnswers[questionId] = AnswerModel(
      questionId: answer.questionId,
      selectedOption: answer.selectedOption,
      essayText: answer.essayText,
      isCorrect: null,
      pointsAwarded: pointsAwarded,
      teacherFeedback: teacherFeedback,
    );

    // Check if all essays are graded
    final quizDoc = await _firestore.collection('quizzes').doc(submission.quizId).get();
    final quiz = QuizModel.fromMap(quizDoc.data()!, submission.quizId);

    bool allGraded = true;
    double totalScore = 0;
    int totalPoints = 0;

    for (final question in quiz.questions) {
      totalPoints += question.points;
      final ans = updatedAnswers[question.id];
      if (ans != null && ans.pointsAwarded != null) {
        totalScore += ans.pointsAwarded!;
      } else if (question.type == QuestionType.essay) {
        allGraded = false;
      }
    }

    await _firestore.collection('submissions').doc(submissionId).update({
      'answers': updatedAnswers.map((key, value) => MapEntry(key, value.toMap())),
      'isGraded': allGraded,
      'score': allGraded ? (totalScore / totalPoints * 100) : null,
    });
  }

  Stream<List<SubmissionModel>> getQuizSubmissions(String quizId) {
    return _firestore
        .collection('submissions')
        .where('quizId', isEqualTo: quizId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SubmissionModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<SubmissionModel?> getStudentSubmission(String quizId, String studentId) async {
    final snapshot = await _firestore
        .collection('submissions')
        .where('quizId', isEqualTo: quizId)
        .where('studentId', isEqualTo: studentId)
        .get();

    if (snapshot.docs.isEmpty) return null;

    return SubmissionModel.fromMap(snapshot.docs.first.data(), snapshot.docs.first.id);
  }
}
