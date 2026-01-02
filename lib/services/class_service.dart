import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/class_model.dart';

class ClassService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _generateJoinCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(6, (index) => chars[random.nextInt(chars.length)]).join();
  }

  Future<ClassModel> createClass({
    required String name,
    required String teacherId,
    required String password,
  }) async {
    String joinCode;
    bool codeExists = true;

    // Generate unique join code
    while (codeExists) {
      joinCode = _generateJoinCode();
      final existingClass = await _firestore
          .collection('classes')
          .where('joinCode', isEqualTo: joinCode)
          .get();
      codeExists = existingClass.docs.isNotEmpty;
    }

    final classModel = ClassModel(
      id: '',
      name: name,
      teacherId: teacherId,
      joinCode: joinCode,
      password: password,
      studentIds: [],
      createdAt: DateTime.now(),
    );

    final docRef = await _firestore.collection('classes').add(classModel.toMap());

    return ClassModel(
      id: docRef.id,
      name: name,
      teacherId: teacherId,
      joinCode: joinCode,
      password: password,
      studentIds: [],
      createdAt: classModel.createdAt,
    );
  }

  Future<ClassModel?> getClassByJoinCode(String joinCode) async {
    final snapshot = await _firestore
        .collection('classes')
        .where('joinCode', isEqualTo: joinCode)
        .get();

    if (snapshot.docs.isEmpty) return null;

    return ClassModel.fromMap(snapshot.docs.first.data(), snapshot.docs.first.id);
  }

  Future<void> joinClass({
    required String classId,
    required String studentId,
    required String password,
  }) async {
    final doc = await _firestore.collection('classes').doc(classId).get();
    final classData = ClassModel.fromMap(doc.data()!, classId);

    if (classData.password != password) {
      throw Exception('Incorrect password');
    }

    if (!classData.studentIds.contains(studentId)) {
      await _firestore.collection('classes').doc(classId).update({
        'studentIds': FieldValue.arrayUnion([studentId])
      });
    }
  }

  Stream<List<ClassModel>> getTeacherClasses(String teacherId) {
    return _firestore
        .collection('classes')
        .where('teacherId', isEqualTo: teacherId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ClassModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<ClassModel>> getStudentClasses(String studentId) {
    return _firestore
        .collection('classes')
        .where('studentIds', arrayContains: studentId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ClassModel.fromMap(doc.data(), doc.id))
            .toList());
  }
}
