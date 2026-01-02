import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../models/quiz_model.dart';
import '../../models/submission_model.dart';
import '../../services/submission_service.dart';
import 'quiz_result_screen.dart';

class TakeQuizScreen extends StatefulWidget {
  final QuizModel quiz;
  final String studentId;

  const TakeQuizScreen({
    super.key,
    required this.quiz,
    required this.studentId,
  });

  @override
  State<TakeQuizScreen> createState() => _TakeQuizScreenState();
}

class _TakeQuizScreenState extends State<TakeQuizScreen> {
  final Map<String, AnswerModel> _answers = {};
  final Map<String, TextEditingController> _essayControllers = {};
  int _currentQuestionIndex = 0;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _checkExistingSubmission();
    for (var question in widget.quiz.questions) {
      if (question.type == QuestionType.essay) {
        _essayControllers[question.id] = TextEditingController();
      }
    }
  }

  Future<void> _checkExistingSubmission() async {
    final submissionService = SubmissionService();
    final existing = await submissionService.getStudentSubmission(
      widget.quiz.id,
      widget.studentId,
    );

    if (existing != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => QuizResultScreen(
            submission: existing,
            quiz: widget.quiz,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    for (var controller in _essayControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _selectMcqOption(String questionId, String option) {
    setState(() {
      _answers[questionId] = AnswerModel(
        questionId: questionId,
        selectedOption: option,
      );
    });
  }

  void _updateEssay(String questionId) {
    _answers[questionId] = AnswerModel(
      questionId: questionId,
      essayText: _essayControllers[questionId]!.text,
    );
  }

  Future<void> _submitQuiz() async {
    for (var question in widget.quiz.questions) {
      if (question.type == QuestionType.essay) {
        _updateEssay(question.id);
      }
    }

    if (_answers.length < widget.quiz.questions.length) {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Incomplete Quiz'),
          content: const Text(
            'You have not answered all questions. Do you want to submit anyway?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Submit'),
            ),
          ],
        ),
      );

      if (result != true) return;
    }

    setState(() => _isSubmitting = true);

    try {
      final submissionService = SubmissionService();
      final submission = await submissionService.submitQuiz(
        quizId: widget.quiz.id,
        studentId: widget.studentId,
        answers: _answers,
        quiz: widget.quiz,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => QuizResultScreen(
              submission: submission,
              quiz: widget.quiz,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit quiz: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.quiz.questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / widget.quiz.questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quiz.title),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(value: progress),
        ),
      ),
      body: _isSubmitting
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Question ${_currentQuestionIndex + 1} of ${widget.quiz.questions.length}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    question.text,
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (question.imageUrl != null) ...[
                    const SizedBox(height: 16),
                    Image.network(
                      question.imageUrl!,
                      height: 200,
                      fit: BoxFit.contain,
                    ),
                  ],
                  if (question.audioUrl != null) ...[
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final player = AudioPlayer();
                        await player.play(UrlSource(question.audioUrl!));
                      },
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Play Audio'),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Expanded(
                    child: question.type == QuestionType.mcq
                        ? _buildMcqOptions(question)
                        : _buildEssayInput(question),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_currentQuestionIndex > 0)
                        ElevatedButton(
                          onPressed: () {
                            setState(() => _currentQuestionIndex--);
                          },
                          child: const Text('Previous'),
                        )
                      else
                        const SizedBox(),
                      if (_currentQuestionIndex < widget.quiz.questions.length - 1)
                        ElevatedButton(
                          onPressed: () {
                            setState(() => _currentQuestionIndex++);
                          },
                          child: const Text('Next'),
                        )
                      else
                        ElevatedButton(
                          onPressed: _submitQuiz,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: const Text('Submit Quiz'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildMcqOptions(QuestionModel question) {
    return ListView.builder(
      itemCount: question.options?.length ?? 0,
      itemBuilder: (context, index) {
        final option = question.options![index];
        final isSelected = _answers[question.id]?.selectedOption == option;

        return Card(
          color: isSelected ? Colors.blue.shade50 : null,
          child: RadioListTile<String>(
            title: Text(option),
            value: option,
            groupValue: _answers[question.id]?.selectedOption,
            onChanged: (value) {
              if (value != null) {
                _selectMcqOption(question.id, value);
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildEssayInput(QuestionModel question) {
    return TextField(
      controller: _essayControllers[question.id],
      decoration: const InputDecoration(
        hintText: 'Type your answer here...',
        border: OutlineInputBorder(),
      ),
      maxLines: null,
      expands: true,
      textAlignVertical: TextAlignVertical.top,
    );
  }
}
