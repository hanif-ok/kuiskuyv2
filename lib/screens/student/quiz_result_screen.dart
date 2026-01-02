import 'package:flutter/material.dart';
import '../../models/submission_model.dart';
import '../../models/quiz_model.dart';

class QuizResultScreen extends StatelessWidget {
  final SubmissionModel submission;
  final QuizModel quiz;

  const QuizResultScreen({
    super.key,
    required this.submission,
    required this.quiz,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Result'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quiz: ${quiz.title}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (!submission.isGraded)
                    const Text(
                      'Your submission is being graded.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.orange,
                      ),
                    )
                  else if (quiz.showScoresAfterTest && submission.score != null)
                    Text(
                      'Score: ${submission.score!.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: submission.score! >= 70 ? Colors.green : Colors.red,
                      ),
                    )
                  else
                    const Text(
                      'Quiz submitted successfully!',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.green,
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (quiz.showCorrectionsAfterTest) ...[
            const SizedBox(height: 16),
            Text(
              'Review',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            ...quiz.questions.asMap().entries.map((entry) {
              final index = entry.key;
              final question = entry.value;
              final answer = submission.answers[question.id];

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
                        Image.network(question.imageUrl!, height: 150),
                      ],
                      const SizedBox(height: 16),
                      if (question.type == QuestionType.mcq) ...[
                        Text(
                          'Your Answer: ${answer?.selectedOption ?? "Not answered"}',
                          style: const TextStyle(fontStyle: FontStyle.italic),
                        ),
                        if (answer?.isCorrect != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                answer!.isCorrect! ? Icons.check_circle : Icons.cancel,
                                color: answer.isCorrect! ? Colors.green : Colors.red,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                answer.isCorrect! ? 'Correct' : 'Incorrect',
                                style: TextStyle(
                                  color: answer.isCorrect! ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          if (!answer.isCorrect! &&
                              question.correctOptionIndex != null &&
                              question.options != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Correct Answer: ${question.options![question.correctOptionIndex!]}',
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                        const SizedBox(height: 8),
                        Text('Points: ${answer?.pointsAwarded ?? 0}/${question.points}'),
                      ] else ...[
                        Text(
                          'Your Answer:',
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
                        if (answer?.pointsAwarded != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Points: ${answer!.pointsAwarded}/${question.points}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                        if (answer?.teacherFeedback != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Teacher Feedback:',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(answer!.teacherFeedback!),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              );
            }),
          ] else if (!quiz.showScoresAfterTest || !submission.isGraded)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Results will be available after the teacher releases them.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
        ],
      ),
    );
  }
}
