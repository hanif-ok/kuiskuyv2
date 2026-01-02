import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/quiz_model.dart';

class QuizService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadFile(File file, String path) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  Future<QuizModel> createQuiz({
    required String title,
    required String classId,
    required String teacherId,
    required List<QuestionModel> questions,
    required bool showScoresAfterTest,
    required bool showCorrectionsAfterTest,
  }) async {
    final quizModel = QuizModel(
      id: '',
      title: title,
      classId: classId,
      teacherId: teacherId,
      questions: questions,
      showScoresAfterTest: showScoresAfterTest,
      showCorrectionsAfterTest: showCorrectionsAfterTest,
      createdAt: DateTime.now(),
    );

    final docRef = await _firestore.collection('quizzes').add(quizModel.toMap());

    return QuizModel(
      id: docRef.id,
      title: title,
      classId: classId,
      teacherId: teacherId,
      questions: questions,
      showScoresAfterTest: showScoresAfterTest,
      showCorrectionsAfterTest: showCorrectionsAfterTest,
      createdAt: quizModel.createdAt,
    );
  }

  Future<QuizModel?> getQuiz(String quizId) async {
    final doc = await _firestore.collection('quizzes').doc(quizId).get();
    if (!doc.exists) return null;
    return QuizModel.fromMap(doc.data()!, quizId);
  }

  Stream<List<QuizModel>> getClassQuizzes(String classId) {
    return _firestore
        .collection('quizzes')
        .where('classId', isEqualTo: classId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => QuizModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> updateQuizVisibilitySettings({
    required String quizId,
    required bool showScoresAfterTest,
    required bool showCorrectionsAfterTest,
  }) async {
    await _firestore.collection('quizzes').doc(quizId).update({
      'showScoresAfterTest': showScoresAfterTest,
      'showCorrectionsAfterTest': showCorrectionsAfterTest,
    });
  }
}
