import 'package:flutter/material.dart';
import '../../models/quiz_model.dart';
import '../../models/class_model.dart';
import '../../models/submission_model.dart';
import '../../services/submission_service.dart';
import '../../services/quiz_service.dart';
import 'grade_submission_screen.dart';

class QuizDetailScreen extends StatelessWidget {
  final QuizModel quiz;
  final ClassModel classModel;

  const QuizDetailScreen({
    super.key,
    required this.quiz,
    required this.classModel,
  });

  @override
  Widget build(BuildContext context) {
    final submissionService = SubmissionService();

    return Scaffold(
      appBar: AppBar(
        title: Text(quiz.title),
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
                    'Quiz Settings',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text('Questions: ${quiz.questions.length}'),
                  Text('Show scores after test: ${quiz.showScoresAfterTest ? "Yes" : "No"}'),
                  Text('Show corrections: ${quiz.showCorrectionsAfterTest ? "Yes" : "No"}'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _showVisibilitySettings(context),
                    child: const Text('Update Visibility Settings'),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Submissions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(
            child: StreamBuilder<List<SubmissionModel>>(
              stream: submissionService.getQuizSubmissions(quiz.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No submissions yet'),
                  );
                }

                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final submission = snapshot.data![index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text('Student ID: ${submission.studentId}'),
                        subtitle: Text(
                          submission.isGraded
                              ? 'Score: ${submission.score?.toStringAsFixed(1)}%'
                              : 'Pending grading',
                        ),
                        trailing: submission.isGraded
                            ? const Icon(Icons.check_circle, color: Colors.green)
                            : const Icon(Icons.pending, color: Colors.orange),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GradeSubmissionScreen(
                                submission: submission,
                                quiz: quiz,
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

  void _showVisibilitySettings(BuildContext context) {
    bool showScores = quiz.showScoresAfterTest;
    bool showCorrections = quiz.showCorrectionsAfterTest;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Visibility Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: const Text('Show scores after test'),
                value: showScores,
                onChanged: (value) {
                  setState(() => showScores = value);
                },
              ),
              SwitchListTile(
                title: const Text('Show corrections after test'),
                value: showCorrections,
                onChanged: (value) {
                  setState(() => showCorrections = value);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final quizService = QuizService();
                await quizService.updateQuizVisibilitySettings(
                  quizId: quiz.id,
                  showScoresAfterTest: showScores,
                  showCorrectionsAfterTest: showCorrections,
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Settings updated')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
