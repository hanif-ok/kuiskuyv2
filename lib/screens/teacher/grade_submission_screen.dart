import 'package:flutter/material.dart';
import '../../models/submission_model.dart';
import '../../models/quiz_model.dart';
import '../../services/submission_service.dart';

class GradeSubmissionScreen extends StatefulWidget {
  final SubmissionModel submission;
  final QuizModel quiz;

  const GradeSubmissionScreen({
    super.key,
    required this.submission,
    required this.quiz,
  });

  @override
  State<GradeSubmissionScreen> createState() => _GradeSubmissionScreenState();
}

class _GradeSubmissionScreenState extends State<GradeSubmissionScreen> {
  final Map<String, TextEditingController> _pointsControllers = {};
  final Map<String, TextEditingController> _feedbackControllers = {};

  @override
  void initState() {
    super.initState();
    for (var question in widget.quiz.questions) {
      if (question.type == QuestionType.essay) {
        final answer = widget.submission.answers[question.id];
        _pointsControllers[question.id] = TextEditingController(
          text: answer?.pointsAwarded?.toString() ?? '',
        );
        _feedbackControllers[question.id] = TextEditingController(
          text: answer?.teacherFeedback ?? '',
        );
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _pointsControllers.values) {
      controller.dispose();
    }
    for (var controller in _feedbackControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _gradeEssay(String questionId, int maxPoints) async {
    final points = double.tryParse(_pointsControllers[questionId]!.text);
    if (points == null || points < 0 || points > maxPoints) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid score (0-$maxPoints)')),
      );
      return;
    }

    try {
      final submissionService = SubmissionService();
      await submissionService.gradeEssay(
        submissionId: widget.submission.id,
        questionId: questionId,
        pointsAwarded: points,
        teacherFeedback: _feedbackControllers[questionId]!.text.trim().isEmpty
            ? null
            : _feedbackControllers[questionId]!.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Essay graded successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to grade essay: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grade Submission'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: widget.quiz.questions.length,
        itemBuilder: (context, index) {
          final question = widget.quiz.questions[index];
          final answer = widget.submission.answers[question.id];

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Question ${index + 1}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(question.text),
                  if (question.imageUrl != null) ...[
                    const SizedBox(height: 8),
                    Image.network(question.imageUrl!, height: 200),
                  ],
                  const SizedBox(height: 16),
                  if (question.type == QuestionType.mcq) ...[
                    Text(
                      'Student Answer: ${answer?.selectedOption ?? "Not answered"}',
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Correct: ${answer?.isCorrect ?? false ? "Yes" : "No"}',
                      style: TextStyle(
                        color: (answer?.isCorrect ?? false)
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('Points: ${answer?.pointsAwarded ?? 0}/${question.points}'),
                  ] else ...[
                    Text(
                      'Essay Answer:',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(answer?.essayText ?? 'Not answered'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _pointsControllers[question.id],
                      decoration: InputDecoration(
                        labelText: 'Points (max ${question.points})',
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _feedbackControllers[question.id],
                      decoration: const InputDecoration(
                        labelText: 'Feedback (optional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => _gradeEssay(question.id, question.points),
                      child: const Text('Grade Essay'),
                    ),
                    if (answer?.pointsAwarded != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Current Score: ${answer!.pointsAwarded}/${question.points}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
