import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../models/class_model.dart';
import '../../models/quiz_model.dart';
import '../../services/quiz_service.dart';
import 'take_quiz_screen.dart';
import 'quiz_result_screen.dart';

class StudentClassDetailScreen extends StatelessWidget {
  final ClassModel classModel;
  final UserModel user;

  const StudentClassDetailScreen({
    super.key,
    required this.classModel,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final quizService = QuizService();

    return Scaffold(
      appBar: AppBar(
        title: Text(classModel.name),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Class Information',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text('Students: ${classModel.studentIds.length}'),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Available Quizzes',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<QuizModel>>(
              stream: quizService.getClassQuizzes(classModel.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No quizzes available yet'),
                  );
                }

                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final quiz = snapshot.data![index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(quiz.title),
                        subtitle: Text('${quiz.questions.length} questions'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TakeQuizScreen(
                                quiz: quiz,
                                studentId: user.id,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
