import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../models/quiz.dart';
import '../providers/auth_provider.dart';
import '../providers/quiz_provider.dart';
import 'update_quiz_screen.dart';
import 'take_quiz_screen.dart';
import 'view_quiz_screen.dart';

class SubjectQuizScreen extends StatefulWidget {
  final String subject;
  final String? topic;
  final bool isInstructor;
  final String userId;

  const SubjectQuizScreen({
    Key? key,
    required this.subject,
    this.topic,
    required this.isInstructor,
    required this.userId,
  }) : super(key: key);

  @override
  State<SubjectQuizScreen> createState() => _SubjectQuizScreenState();
}

class _SubjectQuizScreenState extends State<SubjectQuizScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  final Color primaryColor = const Color(0xFF7C4DFF);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutQuint),
    );
    _opacityAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutQuint),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quizProvider = Provider.of<QuizProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final userId = widget.userId;

    final quizzes =
        quizProvider.quizzes
            .where(
              (quiz) =>
                  quiz.subject == widget.subject &&
                  (widget.topic == null || quiz.topic == widget.topic) &&
                  (quiz.isPublished || quiz.createdBy == userId),
            )
            .toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: FadeInDown(
          duration: const Duration(milliseconds: 800),
          child: Text(
            widget.topic != null
                ? '${widget.subject} - ${widget.topic}'
                : widget.subject,
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
      body:
          quizProvider.isLoading && quizzes.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
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
                    const SizedBox(height: 16),
                    const Text(
                      'Loading quizzes...',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
              )
              : quizzes.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
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
                    const SizedBox(height: 16),
                    Text(
                      'No quizzes available for ${widget.topic != null ? widget.topic : widget.subject}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: quizzes.length,
                itemBuilder: (context, index) {
                  final quiz = quizzes[index];
                  final hasSubmitted =
                      quiz.submittedUsers?.contains(userId) ?? false;
                  final attemptCount = quiz.attempts?[userId] ?? 0;
                  final canAttempt =
                      quiz.attemptLimit == 0 ||
                      attemptCount < quiz.attemptLimit;

                  return FadeInUp(
                    duration: Duration(milliseconds: 300 + (index * 100)),
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
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
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap:
                                canAttempt && quiz.isPublished
                                    ? () {
                                      try {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    TakeQuizScreen(quiz: quiz),
                                          ),
                                        );
                                      } catch (e) {
                                        Fluttertoast.showToast(
                                          msg: 'Error navigating to quiz: $e',
                                          backgroundColor: Colors.red,
                                          textColor: Colors.white,
                                          fontSize: 16.0,
                                        );
                                      }
                                    }
                                    : null,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      if (quiz.questions.any(
                                        (q) => q.imageUrl != null,
                                      ))
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            right: 16.0,
                                          ),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: primaryColor,
                                                width: 2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Image.network(
                                                quiz.questions
                                                    .firstWhere(
                                                      (q) => q.imageUrl != null,
                                                      orElse:
                                                          () => Question(
                                                            question: '',
                                                            type: '',
                                                            options: [],
                                                            correctAnswer: '',
                                                            imageUrl: '',
                                                          ),
                                                    )
                                                    .imageUrl!,
                                                width: 60,
                                                height: 60,
                                                fit: BoxFit.cover,
                                                errorBuilder: (
                                                  context,
                                                  error,
                                                  stackTrace,
                                                ) {
                                                  return Container(
                                                    color: const Color(
                                                      0xFF2A2D36,
                                                    ),
                                                    width: 60,
                                                    height: 60,
                                                    child: const Center(
                                                      child: Text(
                                                        'Image failed',
                                                        style: TextStyle(
                                                          color: Colors.white70,
                                                          fontSize: 12,
                                                          fontFamily:
                                                              'Montserrat',
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                      Expanded(
                                        child: Text(
                                          quiz.title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: Colors.white,
                                            fontFamily: 'Montserrat',
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Attempts: $attemptCount/${quiz.attemptLimit == 0 ? "Unlimited" : quiz.attemptLimit}',
                                    style: TextStyle(
                                      color:
                                          canAttempt
                                              ? primaryColor
                                              : Colors.redAccent,
                                      fontSize: 14,
                                      fontFamily: 'Montserrat',
                                    ),
                                  ),
                                  if (!quiz.isPublished)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        'Unpublished',
                                        style: TextStyle(
                                          color: Colors.orange,
                                          fontSize: 14,
                                          fontFamily: 'Montserrat',
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                  if (quiz.createdBy == userId)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 12.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (context) =>
                                                          UpdateQuizScreen(
                                                            quiz: quiz,
                                                          ),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 8,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: primaryColor.withOpacity(
                                                  0.2,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: primaryColor
                                                      .withOpacity(0.4),
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.edit,
                                                    color: primaryColor,
                                                    size: 16,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    'Edit',
                                                    style: TextStyle(
                                                      color: primaryColor,
                                                      fontFamily: 'Montserrat',
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () async {
                                              final confirm = await showDialog<
                                                bool
                                              >(
                                                context: context,
                                                builder:
                                                    (
                                                      BuildContext
                                                      dialogContext,
                                                    ) => AlertDialog(
                                                      backgroundColor:
                                                          const Color(
                                                            0xFF2A2D36,
                                                          ),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              16,
                                                            ),
                                                      ),
                                                      title: const Text(
                                                        'Delete Quiz',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontFamily:
                                                              'Montserrat',
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      content: const Text(
                                                        'Are you sure you want to delete this quiz?',
                                                        style: TextStyle(
                                                          color: Colors.white70,
                                                          fontFamily:
                                                              'Montserrat',
                                                        ),
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed:
                                                              () => Navigator.of(
                                                                dialogContext,
                                                              ).pop(false),
                                                          child: Text(
                                                            'Cancel',
                                                            style: TextStyle(
                                                              color:
                                                                  primaryColor,
                                                              fontFamily:
                                                                  'Montserrat',
                                                            ),
                                                          ),
                                                        ),
                                                        TextButton(
                                                          onPressed:
                                                              () => Navigator.of(
                                                                dialogContext,
                                                              ).pop(true),
                                                          child: const Text(
                                                            'Delete',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors
                                                                      .redAccent,
                                                              fontFamily:
                                                                  'Montserrat',
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                              );
                                              if (confirm == true) {
                                                try {
                                                  await quizProvider.deleteQuiz(
                                                    quiz.id,
                                                  );
                                                  Fluttertoast.showToast(
                                                    msg:
                                                        'Quiz deleted successfully!',
                                                    backgroundColor:
                                                        Colors.green,
                                                    textColor: Colors.white,
                                                  );
                                                } catch (e) {
                                                  Fluttertoast.showToast(
                                                    msg:
                                                        'Failed to delete quiz: $e',
                                                    backgroundColor: Colors.red,
                                                    textColor: Colors.white,
                                                  );
                                                }
                                              }
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 8,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.redAccent
                                                    .withOpacity(0.2),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: Colors.redAccent
                                                      .withOpacity(0.4),
                                                ),
                                              ),
                                              child: Row(
                                                children: const [
                                                  Icon(
                                                    Icons.delete,
                                                    color: Colors.redAccent,
                                                    size: 16,
                                                  ),
                                                  SizedBox(width: 6),
                                                  Text(
                                                    'Delete',
                                                    style: TextStyle(
                                                      color: Colors.redAccent,
                                                      fontFamily: 'Montserrat',
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () async {
                                              try {
                                                await quizProvider.publishQuiz(
                                                  quiz.id,
                                                  !quiz.isPublished,
                                                );
                                                Fluttertoast.showToast(
                                                  msg:
                                                      quiz.isPublished
                                                          ? 'Quiz unpublished successfully!'
                                                          : 'Quiz published successfully!',
                                                  backgroundColor: Colors.green,
                                                  textColor: Colors.white,
                                                );
                                              } catch (e) {
                                                Fluttertoast.showToast(
                                                  msg:
                                                      'Failed to update quiz: $e',
                                                  backgroundColor: Colors.red,
                                                  textColor: Colors.white,
                                                );
                                              }
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 8,
                                                  ),
                                              decoration: BoxDecoration(
                                                color:
                                                    quiz.isPublished
                                                        ? Colors.orange
                                                            .withOpacity(0.2)
                                                        : Colors.green
                                                            .withOpacity(0.2),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color:
                                                      quiz.isPublished
                                                          ? Colors.orange
                                                              .withOpacity(0.4)
                                                          : Colors.green
                                                              .withOpacity(0.4),
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    quiz.isPublished
                                                        ? Icons.visibility_off
                                                        : Icons
                                                            .published_with_changes,
                                                    color:
                                                        quiz.isPublished
                                                            ? Colors.orange
                                                            : Colors.green,
                                                    size: 16,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    quiz.isPublished
                                                        ? 'Unpublish'
                                                        : 'Publish',
                                                    style: TextStyle(
                                                      color:
                                                          quiz.isPublished
                                                              ? Colors.orange
                                                              : Colors.green,
                                                      fontFamily: 'Montserrat',
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
