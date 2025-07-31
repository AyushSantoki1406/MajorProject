import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../models/quiz.dart';
import '../providers/quiz_provider.dart';
import '../providers/auth_provider.dart';

class TakeQuizScreen extends StatefulWidget {
  final Quiz quiz;

  const TakeQuizScreen({Key? key, required this.quiz}) : super(key: key);

  @override
  State<TakeQuizScreen> createState() => _TakeQuizScreenState();
}

class _TakeQuizScreenState extends State<TakeQuizScreen> {
  late int _currentIndex;
  late List<String?> _userAnswers;
  final Color primaryColor = const Color(0xFF7C4DFF);

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
    _userAnswers = List<String?>.filled(widget.quiz.questions.length, null);
  }

  void _nextQuestion() {
    if (_currentIndex < widget.quiz.questions.length - 1) {
      setState(() {
        _currentIndex++;
      });
    }
  }

  void _previousQuestion() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
    }
  }

  void _submitQuiz(BuildContext context) async {
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user!.uid;

    final answers =
        _userAnswers.where((answer) => answer != null).cast<String>().toList();
    if (answers.length < widget.quiz.questions.length) {
      Fluttertoast.showToast(
        msg: 'Please answer all questions',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    try {
      await quizProvider.submitQuiz(widget.quiz.id, userId, answers);
      Fluttertoast.showToast(
        msg: 'Quiz submitted successfully!',
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
      Navigator.pop(context);
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to submit quiz: $e',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.quiz.questions[_currentIndex];
    final isLastQuestion = _currentIndex == widget.quiz.questions.length - 1;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: FadeInDown(
          duration: const Duration(milliseconds: 800),
          child: Text(
            widget.quiz.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Montserrat',
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (_currentIndex + 1) / widget.quiz.questions.length,
              backgroundColor: const Color(0xFF2A2D36),
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            ),
            const SizedBox(height: 20),
            FadeInUp(
              duration: const Duration(milliseconds: 600),
              child: Card(
                color: const Color(0xFF2A2D36),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Question ${_currentIndex + 1} of ${widget.quiz.questions.length}',
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 16,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        question.question,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (question.type == 'mcq' && question.options != null)
                        ...question.options!.asMap().entries.map((entry) {
                          final index = entry.key;
                          final option = entry.value;
                          return RadioListTile<String>(
                            title: Text(
                              option,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                            value: option,
                            groupValue: _userAnswers[_currentIndex],
                            onChanged: (value) {
                              setState(() {
                                _userAnswers[_currentIndex] = value;
                              });
                            },
                            activeColor: primaryColor,
                          );
                        }),
                      if (question.type == 'true_false')
                        Column(
                          children:
                              ['True', 'False'].map((value) {
                                return RadioListTile<String>(
                                  title: Text(
                                    value,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontFamily: 'Montserrat',
                                    ),
                                  ),
                                  value: value,
                                  groupValue: _userAnswers[_currentIndex],
                                  onChanged: (val) {
                                    setState(() {
                                      _userAnswers[_currentIndex] = val;
                                    });
                                  },
                                  activeColor: primaryColor,
                                );
                              }).toList(),
                        ),
                      if (question.type == 'open_ended')
                        TextField(
                          decoration: InputDecoration(
                            hintText: 'Enter your answer',
                            hintStyle: TextStyle(color: Colors.white70),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: primaryColor),
                            ),
                            filled: true,
                            fillColor: const Color(0xFF1E1E1E),
                          ),
                          style: const TextStyle(color: Colors.white),
                          onChanged: (value) {
                            setState(() {
                              _userAnswers[_currentIndex] = value;
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentIndex > 0)
                  ElevatedButton(
                    onPressed: _previousQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Previous',
                      style: TextStyle(fontFamily: 'Montserrat'),
                    ),
                  ),
                const Spacer(),
                ElevatedButton(
                  onPressed:
                      isLastQuestion
                          ? () => _submitQuiz(context)
                          : _nextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isLastQuestion ? 'Submit' : 'Next',
                    style: const TextStyle(fontFamily: 'Montserrat'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
