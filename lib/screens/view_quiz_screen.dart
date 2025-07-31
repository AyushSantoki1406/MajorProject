import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../models/quiz.dart';
import '../providers/quiz_provider.dart';
import '../providers/auth_provider.dart';

class ViewQuizScreen extends StatefulWidget {
  final Quiz quiz;

  const ViewQuizScreen({Key? key, required this.quiz}) : super(key: key);

  @override
  _ViewQuizScreenState createState() => _ViewQuizScreenState();
}

class _ViewQuizScreenState extends State<ViewQuizScreen> {
  final List<String?> _answers = [];
  int _currentQuestionIndex = 0;
  bool _isLoading = false;
  final Color primaryColor = const Color(0xFF7C4DFF);

  @override
  void initState() {
    super.initState();
    _answers.addAll(List<String?>.filled(widget.quiz.questions.length, null));
  }

  void _selectAnswer(String option) {
    setState(() {
      _answers[_currentQuestionIndex] = option;
    });
  }

  @override
  Widget build(BuildContext context) {
    final quizProvider = Provider.of<QuizProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final question = widget.quiz.questions[_currentQuestionIndex];

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
              fontWeight: FontWeight.bold,
              fontSize: 28,
              color: Colors.white,
              fontFamily: 'Montserrat',
              letterSpacing: 1.2,
              shadows: [
                Shadow(
                  color: Colors.black26,
                  offset: Offset(2, 2),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor.withOpacity(0.8), Colors.black87],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor.withOpacity(0.8), Colors.black87],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF2A2D36).withOpacity(0.7),
                        const Color(0xFF0D0D0D).withOpacity(0.9),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: primaryColor.withOpacity(0.4),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Question ${_currentQuestionIndex + 1}/${widget.quiz.questions.length}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.white,
                                fontFamily: 'Montserrat',
                                shadows: [
                                  Shadow(color: Colors.black26, blurRadius: 4),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: primaryColor.withOpacity(0.4),
                                ),
                              ),
                              child: Text(
                                question.type == 'mcq'
                                    ? 'Multiple Choice'
                                    : 'True/False',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 14,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF2A2D36).withOpacity(0.7),
                                const Color(0xFF0D0D0D).withOpacity(0.9),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: primaryColor.withOpacity(0.4),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.2),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      question.question,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontFamily: 'Montserrat',
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    ...(question.type == 'mcq' &&
                                                question.options != null
                                            ? question.options!
                                            : ['True', 'False'])
                                        .asMap()
                                        .entries
                                        .map((entry) {
                                          final index = entry.key;
                                          final option = entry.value;
                                          final isSelected =
                                              _answers[_currentQuestionIndex] ==
                                              option;
                                          return FadeInUp(
                                            duration: Duration(
                                              milliseconds: 400 + (index * 100),
                                            ),
                                            child: GestureDetector(
                                              onTap:
                                                  () => _selectAnswer(option),
                                              child: Container(
                                                margin: const EdgeInsets.only(
                                                  bottom: 12,
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 14,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color:
                                                      isSelected
                                                          ? primaryColor
                                                              .withOpacity(0.3)
                                                          : Colors.white
                                                              .withOpacity(
                                                                0.05,
                                                              ),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color:
                                                        isSelected
                                                            ? primaryColor
                                                            : Colors.white
                                                                .withOpacity(
                                                                  0.2,
                                                                ),
                                                    width: 1.5,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color:
                                                          isSelected
                                                              ? primaryColor
                                                                  .withOpacity(
                                                                    0.3,
                                                                  )
                                                              : Colors.black
                                                                  .withOpacity(
                                                                    0.1,
                                                                  ),
                                                      blurRadius: 8,
                                                      offset: const Offset(
                                                        0,
                                                        2,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      isSelected
                                                          ? Icons.check_circle
                                                          : Icons
                                                              .circle_outlined,
                                                      color:
                                                          isSelected
                                                              ? primaryColor
                                                              : Colors.white70,
                                                      size: 24,
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: Text(
                                                        option,
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 16,
                                                          fontFamily:
                                                              'Montserrat',
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        })
                                        .toList(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (_currentQuestionIndex > 0)
                              FadeInUp(
                                duration: const Duration(milliseconds: 500),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _currentQuestionIndex--;
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey.shade700,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 16,
                                    ),
                                    elevation: 8,
                                    shadowColor: Colors.grey.withOpacity(0.5),
                                    minimumSize: const Size(120, 50),
                                  ),
                                  child: const Text(
                                    'Previous',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Montserrat',
                                    ),
                                  ),
                                ),
                              ),
                            FadeInUp(
                              duration: const Duration(milliseconds: 500),
                              child: ElevatedButton(
                                onPressed:
                                    _answers[_currentQuestionIndex] == null
                                        ? () {
                                          Fluttertoast.showToast(
                                            msg: 'Please select an answer',
                                            backgroundColor: Colors.red,
                                            textColor: Colors.white,
                                          );
                                        }
                                        : () async {
                                          if (_currentQuestionIndex <
                                              widget.quiz.questions.length -
                                                  1) {
                                            setState(() {
                                              _currentQuestionIndex++;
                                            });
                                          } else {
                                            setState(() {
                                              _isLoading = true;
                                            });
                                            try {
                                              final answers =
                                                  _answers
                                                      .map(
                                                        (answer) =>
                                                            answer ?? '',
                                                      )
                                                      .toList();
                                              await quizProvider.submitQuiz(
                                                widget.quiz.id,
                                                authProvider.user!.uid,
                                                answers,
                                              );
                                              Fluttertoast.showToast(
                                                msg:
                                                    'Quiz submitted successfully!',
                                                backgroundColor: Colors.green,
                                                textColor: Colors.white,
                                              );
                                              Navigator.pop(context);
                                            } catch (e) {
                                              Fluttertoast.showToast(
                                                msg:
                                                    'Failed to submit quiz: $e',
                                                backgroundColor: Colors.red,
                                                textColor: Colors.white,
                                              );
                                            } finally {
                                              if (mounted) {
                                                setState(() {
                                                  _isLoading = false;
                                                });
                                              }
                                            }
                                          }
                                        },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      _currentQuestionIndex <
                                              widget.quiz.questions.length - 1
                                          ? Colors.green
                                          : primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 16,
                                  ),
                                  elevation: 8,
                                  shadowColor:
                                      _currentQuestionIndex <
                                              widget.quiz.questions.length - 1
                                          ? Colors.green.withOpacity(0.5)
                                          : primaryColor.withOpacity(0.5),
                                  minimumSize: const Size(120, 50),
                                ),
                                child: Text(
                                  _currentQuestionIndex <
                                          widget.quiz.questions.length - 1
                                      ? 'Next'
                                      : 'Submit',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2D36).withOpacity(0.6),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    strokeWidth: 4,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
