import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../models/quiz_model.dart';
import '../../services/quiz_service.dart';

class CreateQuizScreen extends StatefulWidget {
  final String classId;
  final String teacherId;

  const CreateQuizScreen({
    super.key,
    required this.classId,
    required this.teacherId,
  });

  @override
  State<CreateQuizScreen> createState() => _CreateQuizScreenState();
}

class _CreateQuizScreenState extends State<CreateQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final List<QuestionModel> _questions = [];
  bool _showScoresAfterTest = false;
  bool _showCorrectionsAfterTest = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _createQuiz() async {
    if (!_formKey.currentState!.validate()) return;

    if (_questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one question')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final quizService = QuizService();
      await quizService.createQuiz(
        title: _titleController.text.trim(),
        classId: widget.classId,
        teacherId: widget.teacherId,
        questions: _questions,
        showScoresAfterTest: _showScoresAfterTest,
        showCorrectionsAfterTest: _showCorrectionsAfterTest,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quiz created successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create quiz: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _addQuestion() {
    showDialog(
      context: context,
      builder: (context) => AddQuestionDialog(
        onQuestionAdded: (question) {
          setState(() {
            _questions.add(question);
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Quiz'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _isLoading ? null : _createQuiz,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Quiz Title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a quiz title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Show scores after test'),
                    value: _showScoresAfterTest,
                    onChanged: (value) {
                      setState(() => _showScoresAfterTest = value);
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Show corrections after test'),
                    value: _showCorrectionsAfterTest,
                    onChanged: (value) {
                      setState(() => _showCorrectionsAfterTest = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Questions (${_questions.length})',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      ElevatedButton.icon(
                        onPressed: _addQuestion,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Question'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ..._questions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final question = entry.value;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text('Q${index + 1}: ${question.text}'),
                        subtitle: Text(
                          '${question.type.toString().split('.').last.toUpperCase()} - ${question.points} points',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              _questions.removeAt(index);
                            });
                          },
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
    );
  }
}

class AddQuestionDialog extends StatefulWidget {
  final Function(QuestionModel) onQuestionAdded;

  const AddQuestionDialog({super.key, required this.onQuestionAdded});

  @override
  State<AddQuestionDialog> createState() => _AddQuestionDialogState();
}

class _AddQuestionDialogState extends State<AddQuestionDialog> {
  final _textController = TextEditingController();
  final _pointsController = TextEditingController(text: '1');
  QuestionType _type = QuestionType.mcq;
  final List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  int _correctOptionIndex = 0;
  File? _imageFile;
  File? _audioFile;

  @override
  void dispose() {
    _textController.dispose();
    _pointsController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickAudio() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );
    if (result != null) {
      setState(() {
        _audioFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _addQuestion() async {
    if (_textController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter question text')),
      );
      return;
    }

    final quizService = QuizService();
    String? imageUrl;
    String? audioUrl;

    if (_imageFile != null) {
      imageUrl = await quizService.uploadFile(
        _imageFile!,
        'quiz_images/${const Uuid().v4()}.jpg',
      );
    }

    if (_audioFile != null) {
      audioUrl = await quizService.uploadFile(
        _audioFile!,
        'quiz_audio/${const Uuid().v4()}.mp3',
      );
    }

    final question = QuestionModel(
      id: const Uuid().v4(),
      text: _textController.text,
      type: _type,
      imageUrl: imageUrl,
      audioUrl: audioUrl,
      options: _type == QuestionType.mcq
          ? _optionControllers.map((c) => c.text).toList()
          : null,
      correctOptionIndex: _type == QuestionType.mcq ? _correctOptionIndex : null,
      points: int.tryParse(_pointsController.text) ?? 1,
    );

    widget.onQuestionAdded(question);
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Question'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: [
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: 'Question Text',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _pointsController,
              decoration: const InputDecoration(
                labelText: 'Points',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<QuestionType>(
              value: _type,
              decoration: const InputDecoration(
                labelText: 'Question Type',
                border: OutlineInputBorder(),
              ),
              items: QuestionType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.toString().split('.').last.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _type = value!);
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image),
                    label: Text(_imageFile == null ? 'Add Image' : 'Image Added'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickAudio,
                    icon: const Icon(Icons.audio_file),
                    label: Text(_audioFile == null ? 'Add Audio' : 'Audio Added'),
                  ),
                ),
              ],
            ),
            if (_type == QuestionType.mcq) ...[
              const SizedBox(height: 16),
              const Text('Options:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...List.generate(4, (index) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Radio<int>(
                        value: index,
                        groupValue: _correctOptionIndex,
                        onChanged: (value) {
                          setState(() => _correctOptionIndex = value!);
                        },
                      ),
                      Expanded(
                        child: TextField(
                          controller: _optionControllers[index],
                          decoration: InputDecoration(
                            labelText: 'Option ${index + 1}',
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _addQuestion,
          child: const Text('Add'),
        ),
      ],
    );
  }
}
