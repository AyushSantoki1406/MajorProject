  import 'package:flutter/material.dart';
  import 'package:provider/provider.dart';
  import '../providers/auth_provider.dart';
  import '../providers/quiz_provider.dart';
  import '../models/quiz.dart';

  class QuizScreen extends StatefulWidget {
    final String quizId;
    const QuizScreen({Key? key, required this.quizId}) : super(key: key);

    @override
    _QuizScreenState createState() => _QuizScreenState();
  }

  class _QuizScreenState extends State<QuizScreen> {
    int _currentQuestion = 0;
    List<String> _answers = [];

    @override
    void initState() {
      super.initState();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<QuizProvider>(context, listen: false).fetchQuizzes();
      });
    }

    @override
    Widget build(BuildContext context) {
      final quizProvider = Provider.of<QuizProvider>(context);
      final authProvider = Provider.of<AuthProvider>(context);
      final Quiz? quiz = quizProvider.quizzes.firstWhere(
        (q) => q.id == widget.quizId,
        orElse: () => null as Quiz, // type-cast null to Quiz? (optional here)
      );

      if (quiz == null) return const Center(child: CircularProgressIndicator());

      if (_answers.isEmpty) _answers = List.filled(quiz.questions.length, '');

      final question = quiz.questions[_currentQuestion];

      return Scaffold(
        appBar: AppBar(title: Text(quiz.title)),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Question ${_currentQuestion + 1}: ${question.question}',
                style: const TextStyle(fontSize: 18),
              ),
              if (question.imageUrl != null)
                Image.network(question.imageUrl!, height: 200),
              const SizedBox(height: 20),
              if (question.type == 'mcq' || question.type == 'true_false')
                ...question.options!.map(
                  (option) => RadioListTile<String>(
                    title: Text(option),
                    value: option,
                    groupValue: _answers[_currentQuestion],
                    onChanged: (value) {
                      setState(() {
                        _answers[_currentQuestion] = value!;
                      });
                    },
                  ),
                ),
              if (question.type == 'short_answer')
                TextField(
                  onChanged: (value) {
                    _answers[_currentQuestion] = value;
                  },
                  decoration: const InputDecoration(labelText: 'Answer'),
                ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentQuestion > 0)
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _currentQuestion--;
                        });
                      },
                      child: const Text('Previous'),
                    ),
                  if (_currentQuestion < quiz.questions.length - 1)
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _currentQuestion++;
                        });
                      },
                      child: const Text('Next'),
                    ),
                  if (_currentQuestion == quiz.questions.length - 1)
                    ElevatedButton(
                      onPressed: () async {
                        await quizProvider.submitQuiz(
                          quiz.id,
                          authProvider.user!.uid,
                          _answers,
                        );
                        // Navigate to result screen
                      },
                      child: const Text('Submit'),
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    }
  }
