import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:quiz_app/models/quiz.dart';
import 'package:quiz_app/providers/quiz_provider.dart';
import 'package:quiz_app/providers/auth_provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:animate_do/animate_do.dart';
import 'home_screen.dart'; // Import HomeScreen

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({Key? key}) : super(key: key);

  @override
  _LibraryScreenState createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final Color primaryColor = const Color(0xFF7C4DFF);
  // Add a flag to control "Coming Soon" display (adjust as needed)
  final bool _isComingSoon = true; // Set to false to show original UI

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quizProvider = Provider.of<QuizProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final userId = authProvider.user!.uid;

    // Check if "Coming Soon" should be displayed
    if (_isComingSoon) {
      return Scaffold(
        body: Stack(
          children: [
            // Blurred background with the original content
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor.withOpacity(0.8), Colors.black87],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(color: Colors.black.withOpacity(0.2)),
              ),
            ),
            // Coming Soon content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FadeIn(
                    duration: const Duration(milliseconds: 1000),
                    child: Text(
                      'Coming Soon',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                        shadows: [
                          Shadow(
                            color: primaryColor.withOpacity(0.5),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Original UI (unchanged)
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        automaticallyImplyLeading: false, // 👈 Hides the back button
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: FadeInDown(
          child: Text(
            'Quiz Journey',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              fontFamily: 'Montserrat',
              letterSpacing: 1.2,
              shadows: [
                Shadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor.withOpacity(0.8), Colors.black87],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child:
            quizProvider.isLoading
                ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    strokeWidth: 4,
                  ),
                )
                : FutureBuilder<List<Submission>>(
                  future: quizProvider.fetchUserSubmissions(userId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            primaryColor,
                          ),
                          strokeWidth: 4,
                        ),
                      );
                    }
                    if (snapshot.hasError ||
                        !snapshot.hasData ||
                        snapshot.data!.isEmpty) {
                      return FadeIn(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.quiz_outlined,
                                color: primaryColor.withOpacity(0.7),
                                size: 80,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No Quizzes Taken Yet',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 20,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 5,
                                ),
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const HomeScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Start a Quiz',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final submissions = snapshot.data!;
                    final quizMap = {
                      for (var quiz in quizProvider.quizzes) quiz.id: quiz,
                    };
                    final Map<String, Map<String, List<Submission>>>
                    submissionsBySubjectTopic = {};
                    for (var submission in submissions) {
                      if (submission.userId == userId) {
                        final quiz = quizMap[submission.quizId];
                        if (quiz != null) {
                          submissionsBySubjectTopic
                              .putIfAbsent(quiz.subject, () => {})
                              .putIfAbsent(quiz.topic, () => [])
                              .add(submission);
                        }
                      }
                    }

                    if (submissionsBySubjectTopic.isEmpty) {
                      return FadeIn(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.quiz_outlined,
                                color: primaryColor.withOpacity(0.7),
                                size: 80,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No Quizzes Taken Yet',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 20,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 5,
                                ),
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const HomeScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Start a Quiz',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      color: primaryColor,
                      onRefresh: () async {
                        await quizProvider.fetchUserSubmissions(userId);
                      },
                      child: ListView(
                        padding: const EdgeInsets.all(16.0),
                        children:
                            submissionsBySubjectTopic.entries.map((
                              subjectEntry,
                            ) {
                              final subject = subjectEntry.key;
                              final topicMap = subjectEntry.value;
                              return FadeInUp(
                                duration: const Duration(milliseconds: 300),
                                child: Card(
                                  elevation: 8,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  color: Colors.transparent,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.black87,
                                          primaryColor.withOpacity(0.3),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
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
                                    child: ExpansionTile(
                                      leading: Icon(
                                        Icons.subject,
                                        color: primaryColor,
                                        size: 32,
                                      ),
                                      title: Text(
                                        subject,
                                        style: const TextStyle(
                                          fontSize: 22,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: 'Montserrat',
                                        ),
                                      ),
                                      children:
                                          topicMap.entries.map((topicEntry) {
                                            final topic = topicEntry.key;
                                            final submissions =
                                                topicEntry.value;
                                            final relatedQuizzes =
                                                quizProvider.quizzes
                                                    .where(
                                                      (quiz) =>
                                                          quiz.subject ==
                                                              subject &&
                                                          quiz.topic == topic,
                                                    )
                                                    .toList();
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                left: 16.0,
                                                right: 16.0,
                                                bottom: 8.0,
                                              ),
                                              child: ExpansionTile(
                                                leading: Icon(
                                                  Icons.topic,
                                                  color: primaryColor,
                                                  size: 24,
                                                ),
                                                title: Text(
                                                  topic,
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.white70,
                                                    fontFamily: 'Montserrat',
                                                  ),
                                                ),
                                                children:
                                                    relatedQuizzes.map((quiz) {
                                                      final userSubmissions =
                                                          submissions
                                                              .where(
                                                                (s) =>
                                                                    s.quizId ==
                                                                    quiz.id,
                                                              )
                                                              .toList();
                                                      final attemptCount =
                                                          quiz.attempts?[userId] ??
                                                          0;
                                                      final avgScore =
                                                          userSubmissions
                                                                  .isNotEmpty
                                                              ? userSubmissions
                                                                      .map(
                                                                        (s) =>
                                                                            s.score,
                                                                      )
                                                                      .reduce(
                                                                        (
                                                                          a,
                                                                          b,
                                                                        ) =>
                                                                            a +
                                                                            b,
                                                                      ) /
                                                                  userSubmissions
                                                                      .length
                                                              : 0.0;

                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              vertical: 8.0,
                                                            ),
                                                        child: Card(
                                                          color: const Color(
                                                            0xFF2A2D36,
                                                          ).withOpacity(0.7),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  12,
                                                                ),
                                                            side: BorderSide(
                                                              color: primaryColor
                                                                  .withOpacity(
                                                                    0.4,
                                                                  ),
                                                              width: 1.0,
                                                            ),
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets.all(
                                                                  8.0,
                                                                ),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    CircularPercentIndicator(
                                                                      radius:
                                                                          20,
                                                                      lineWidth:
                                                                          3,
                                                                      percent:
                                                                          avgScore /
                                                                          100,
                                                                      center: Text(
                                                                        quiz.title[0]
                                                                            .toUpperCase(),
                                                                        style: const TextStyle(
                                                                          color:
                                                                              Colors.white,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                      progressColor:
                                                                          primaryColor,
                                                                      backgroundColor:
                                                                          Colors
                                                                              .white12,
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 12,
                                                                    ),
                                                                    Expanded(
                                                                      child: Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          Text(
                                                                            quiz.title,
                                                                            style: const TextStyle(
                                                                              fontSize:
                                                                                  16,
                                                                              color:
                                                                                  Colors.white,
                                                                              fontWeight:
                                                                                  FontWeight.w600,
                                                                              fontFamily:
                                                                                  'Montserrat',
                                                                            ),
                                                                          ),
                                                                          Text(
                                                                            'Attempts: $attemptCount | Avg: ${avgScore.toStringAsFixed(1)}%',
                                                                            style: const TextStyle(
                                                                              color:
                                                                                  Colors.white70,
                                                                              fontSize:
                                                                                  12,
                                                                              fontFamily:
                                                                                  'Montserrat',
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                const SizedBox(
                                                                  height: 8,
                                                                ),
                                                                SizedBox(
                                                                  height:
                                                                      200, // Fixed height to prevent size errors
                                                                  child: BarChart(
                                                                    BarChartData(
                                                                      alignment:
                                                                          BarChartAlignment
                                                                              .spaceAround,
                                                                      maxY: 100,
                                                                      minY: 0,
                                                                      gridData: FlGridData(
                                                                        show:
                                                                            true,
                                                                        drawVerticalLine:
                                                                            false,
                                                                        horizontalInterval:
                                                                            20,
                                                                        getDrawingHorizontalLine: (
                                                                          value,
                                                                        ) {
                                                                          return FlLine(
                                                                            color: primaryColor.withOpacity(
                                                                              0.2,
                                                                            ),
                                                                            strokeWidth:
                                                                                1,
                                                                          );
                                                                        },
                                                                      ),
                                                                      borderData:
                                                                          FlBorderData(
                                                                            show:
                                                                                false,
                                                                          ),
                                                                      titlesData: FlTitlesData(
                                                                        leftTitles: AxisTitles(
                                                                          sideTitles: SideTitles(
                                                                            showTitles:
                                                                                true,
                                                                            reservedSize:
                                                                                40,
                                                                            getTitlesWidget: (
                                                                              value,
                                                                              meta,
                                                                            ) {
                                                                              return Text(
                                                                                '${value.toInt()}%',
                                                                                style: const TextStyle(
                                                                                  color:
                                                                                      Colors.white70,
                                                                                  fontSize:
                                                                                      12,
                                                                                ),
                                                                              );
                                                                            },
                                                                          ),
                                                                        ),
                                                                        bottomTitles: AxisTitles(
                                                                          sideTitles: SideTitles(
                                                                            showTitles:
                                                                                true,
                                                                            getTitlesWidget: (
                                                                              value,
                                                                              meta,
                                                                            ) {
                                                                              return Text(
                                                                                'Attempt ${value.toInt() + 1}',
                                                                                style: const TextStyle(
                                                                                  color:
                                                                                      Colors.white70,
                                                                                  fontSize:
                                                                                      12,
                                                                                ),
                                                                              );
                                                                            },
                                                                          ),
                                                                        ),
                                                                        topTitles: const AxisTitles(
                                                                          sideTitles: SideTitles(
                                                                            showTitles:
                                                                                false,
                                                                          ),
                                                                        ),
                                                                        rightTitles: const AxisTitles(
                                                                          sideTitles: SideTitles(
                                                                            showTitles:
                                                                                false,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      barGroups:
                                                                          userSubmissions.asMap().entries.map((
                                                                            entry,
                                                                          ) {
                                                                            return BarChartGroupData(
                                                                              x: entry.key,
                                                                              barRods: [
                                                                                BarChartRodData(
                                                                                  toY:
                                                                                      entry.value.score.toDouble(),
                                                                                  gradient: LinearGradient(
                                                                                    colors: [
                                                                                      primaryColor,
                                                                                      primaryColor.withOpacity(
                                                                                        0.6,
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                  width:
                                                                                      18,
                                                                                  borderRadius: BorderRadius.circular(
                                                                                    6,
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            );
                                                                          }).toList(),
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  height: 8,
                                                                ),
                                                                ...userSubmissions.asMap().entries.map((
                                                                  entry,
                                                                ) {
                                                                  final attemptIndex =
                                                                      entry.key;
                                                                  final submission =
                                                                      entry
                                                                          .value;
                                                                  return Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        'Attempt ${attemptIndex + 1}: ${submission.score}%',
                                                                        style: TextStyle(
                                                                          fontSize:
                                                                              16,
                                                                          color:
                                                                              Colors.white,
                                                                          fontWeight:
                                                                              FontWeight.w700,
                                                                          fontFamily:
                                                                              'Montserrat',
                                                                          shadows: [
                                                                            Shadow(
                                                                              color: primaryColor.withOpacity(
                                                                                0.3,
                                                                              ),
                                                                              blurRadius:
                                                                                  4,
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            8,
                                                                      ),
                                                                      Container(
                                                                        decoration: BoxDecoration(
                                                                          color:
                                                                              Colors.black45,
                                                                          borderRadius: BorderRadius.circular(
                                                                            12,
                                                                          ),
                                                                          border: Border.all(
                                                                            color: primaryColor.withOpacity(
                                                                              0.2,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        child: Column(
                                                                          children:
                                                                              quiz.questions.asMap().entries.map((
                                                                                qEntry,
                                                                              ) {
                                                                                final qIndex =
                                                                                    qEntry.key;
                                                                                final question =
                                                                                    qEntry.value;
                                                                                final userAnswer =
                                                                                    submission.answers.length >
                                                                                            qIndex
                                                                                        ? submission.answers[qIndex]
                                                                                        : 'No answer';
                                                                                final isCorrect =
                                                                                    userAnswer ==
                                                                                    question.correctAnswer;

                                                                                return Padding(
                                                                                  padding: const EdgeInsets.symmetric(
                                                                                    vertical:
                                                                                        4.0,
                                                                                  ),
                                                                                  child: ListTile(
                                                                                    leading: Icon(
                                                                                      isCorrect
                                                                                          ? Icons.check_circle
                                                                                          : Icons.cancel,
                                                                                      color:
                                                                                          isCorrect
                                                                                              ? Colors.greenAccent
                                                                                              : Colors.redAccent,
                                                                                      size:
                                                                                          20,
                                                                                    ),
                                                                                    title: Text(
                                                                                      'Q${qIndex + 1}: ${question.question}',
                                                                                      style: const TextStyle(
                                                                                        color:
                                                                                            Colors.white,
                                                                                        fontSize:
                                                                                            14,
                                                                                        fontFamily:
                                                                                            'Montserrat',
                                                                                        fontWeight:
                                                                                            FontWeight.w600,
                                                                                      ),
                                                                                    ),
                                                                                    subtitle: Column(
                                                                                      crossAxisAlignment:
                                                                                          CrossAxisAlignment.start,
                                                                                      children: [
                                                                                        Text(
                                                                                          'Your Answer: $userAnswer',
                                                                                          style: TextStyle(
                                                                                            color:
                                                                                                isCorrect
                                                                                                    ? Colors.greenAccent
                                                                                                    : Colors.redAccent,
                                                                                            fontSize:
                                                                                                12,
                                                                                            fontFamily:
                                                                                                'Montserrat',
                                                                                          ),
                                                                                        ),
                                                                                        if (!isCorrect)
                                                                                          Text(
                                                                                            'Correct Answer: ${question.correctAnswer}',
                                                                                            style: const TextStyle(
                                                                                              color:
                                                                                                  Colors.greenAccent,
                                                                                              fontSize:
                                                                                                  12,
                                                                                              fontFamily:
                                                                                                  'Montserrat',
                                                                                            ),
                                                                                          ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                );
                                                                              }).toList(),
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            8,
                                                                      ),
                                                                    ],
                                                                  );
                                                                }).toList(),
                                                                Center(
                                                                  child: ElevatedButton.icon(
                                                                    style: ElevatedButton.styleFrom(
                                                                      backgroundColor:
                                                                          primaryColor,
                                                                      padding: const EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            24,
                                                                        vertical:
                                                                            12,
                                                                      ),
                                                                      shape: RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              12,
                                                                            ),
                                                                      ),
                                                                      elevation:
                                                                          5,
                                                                    ),
                                                                    onPressed: () {
                                                                      Navigator.pushReplacement(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                          builder:
                                                                              (
                                                                                context,
                                                                              ) =>
                                                                                  const HomeScreen(),
                                                                        ),
                                                                      );
                                                                    },
                                                                    icon: const Icon(
                                                                      Icons
                                                                          .refresh,
                                                                      color:
                                                                          Colors
                                                                              .white,
                                                                    ),
                                                                    label: const Text(
                                                                      'Retry Quiz',
                                                                      style: TextStyle(
                                                                        color:
                                                                            Colors.white,
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  height: 8,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    }).toList(),
                                              ),
                                            );
                                          }).toList(),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    );
                  },
                ),
      ),
    );
  }
}
