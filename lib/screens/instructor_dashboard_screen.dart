import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui'; // Added for BackdropFilter
import '../providers/auth_provider.dart';
import '../providers/quiz_provider.dart';
import '../models/quiz.dart';

class InstructorDashboardScreen extends StatefulWidget {
  const InstructorDashboardScreen({Key? key}) : super(key: key);

  @override
  _InstructorDashboardScreenState createState() =>
      _InstructorDashboardScreenState();
}

class _InstructorDashboardScreenState extends State<InstructorDashboardScreen> {
  final Map<String, String> _studentNameCache = {};
  // Add a flag to control "Coming Soon" display (adjust as needed)
  final bool _isComingSoon = true; // Set to false to show original UI

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final quizProvider = Provider.of<QuizProvider>(context);
    final primaryColor = const Color(0xFF7C4DFF);

    // Check if "Coming Soon" should be displayed
    if (_isComingSoon) {
      return Scaffold(
        body: Stack(
          children: [
            // Blurred background with gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryColor.withOpacity(0.9),
                    const Color(0xFF8B5CFE).withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
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
                  ElevatedButton.icon(
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
                      Navigator.pop(context); // Navigate back
                    },
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    label: const Text(
                      'Back',
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
          ],
        ),
      );
    }

    // Original UI (unchanged)
    // Filter quizzes created by the instructor
    final instructorQuizzes =
        quizProvider.quizzes
            .where((quiz) => quiz.createdBy == authProvider.user!.uid)
            .toList();

    // Group quizzes by subject and then by topic
    final subjectTopicGroups = <String, Map<String, List<Quiz>>>{};
    for (var quiz in instructorQuizzes) {
      subjectTopicGroups
          .putIfAbsent(quiz.subject, () => {})
          .putIfAbsent(quiz.topic, () => [])
          .add(quiz);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Animated Header
              FadeInDown(
                duration: const Duration(milliseconds: 800),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        primaryColor.withOpacity(0.9),
                        const Color(0xFF8B5CFE).withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    height: 60, // Adjust if needed for alignment
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Back Button
                        Positioned(
                          left: 0,
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.pop(context); // Navigate back
                            },
                          ),
                        ),

                        // Centered Title
                        Text(
                          'Instructor Dashboard',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Montserrat',
                            letterSpacing: 1.2,
                            shadows: [
                              Shadow(
                                color: primaryColor.withOpacity(0.5),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bar Chart for Average Scores
                    FadeInUp(
                      duration: const Duration(milliseconds: 1000),
                      child: FutureBuilder<Map<String, double>>(
                        future: _calculateSubjectAverages(instructorQuizzes),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF2A2D36,
                                  ).withOpacity(0.6),
                                  shape: BoxShape.circle,
                                ),
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    primaryColor,
                                  ),
                                  strokeWidth: 4,
                                ),
                              ),
                            );
                          }
                          if (snapshot.hasError || !snapshot.hasData) {
                            return const Center(
                              child: Text(
                                'Error loading chart data',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                            );
                          }

                          final subjectAverages = snapshot.data!;
                          return Container(
                            height: 300,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF2A2D36).withOpacity(0.8),
                                  const Color(0xFF0D0D0D).withOpacity(0.9),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.3),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY: 100,
                                barTouchData: BarTouchData(
                                  enabled: true,
                                  touchTooltipData: BarTouchTooltipData(
                                    tooltipPadding: const EdgeInsets.all(10),
                                    tooltipMargin: 10,
                                    tooltipRoundedRadius: 12,
                                    getTooltipItem: (
                                      group,
                                      groupIndex,
                                      rod,
                                      rodIndex,
                                    ) {
                                      final subject = subjectAverages.keys
                                          .elementAt(group.x.toInt());
                                      return BarTooltipItem(
                                        '$subject\n${rod.toY.toStringAsFixed(1)}%',
                                        TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                barGroups:
                                    subjectAverages.entries
                                        .toList()
                                        .asMap()
                                        .entries
                                        .map((e) {
                                          final index = e.key;
                                          final subject = e.value.key;
                                          final avgScore = e.value.value;
                                          return BarChartGroupData(
                                            x: index,
                                            barRods: [
                                              BarChartRodData(
                                                toY: avgScore,
                                                gradient: LinearGradient(
                                                  colors: [
                                                    primaryColor,
                                                    const Color(0xFF8B5CFE),
                                                  ],
                                                ),
                                                width: 20,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                backDrawRodData:
                                                    BackgroundBarChartRodData(
                                                      show: true,
                                                      toY: 100,
                                                      color: Colors.white
                                                          .withOpacity(0.1),
                                                    ),
                                              ),
                                            ],
                                          );
                                        })
                                        .toList(),
                                titlesData: FlTitlesData(
                                  show: true,
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        final subject = subjectAverages.keys
                                            .elementAt(value.toInt());
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            top: 10,
                                          ),
                                          child: Text(
                                            subject,
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 14,
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.w600,
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        );
                                      },
                                      reservedSize: 50,
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        return Text(
                                          '${value.toInt()}%',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 14,
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.w600,
                                          ),
                                        );
                                      },
                                      reservedSize: 50,
                                    ),
                                  ),
                                  topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                ),
                                borderData: FlBorderData(show: false),
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  horizontalInterval: 20,
                                  getDrawingHorizontalLine: (value) {
                                    return FlLine(
                                      color: primaryColor.withOpacity(0.2),
                                      strokeWidth: 1,
                                    );
                                  },
                                ),
                              ),
                              swapAnimationDuration: const Duration(
                                milliseconds: 600,
                              ),
                              swapAnimationCurve: Curves.easeInOut,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Quiz List by Subject and Topic
                    Text(
                      'Your Quizzes',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                        shadows: [
                          Shadow(
                            color: primaryColor.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...subjectTopicGroups.entries.map((subjectEntry) {
                      final subject = subjectEntry.key;
                      final topicMap = subjectEntry.value;
                      return FadeInUp(
                        duration: const Duration(milliseconds: 800),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF2A2D36).withOpacity(0.85),
                                const Color(0xFF0D0D0D).withOpacity(0.95),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.2),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ExpansionTile(
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    primaryColor,
                                    const Color(0xFF8B5CFE),
                                  ],
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.subject,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            title: Text(
                              subject,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                            iconColor: primaryColor,
                            collapsedIconColor: Colors.white70,
                            children:
                                topicMap.entries.map((topicEntry) {
                                  final topic = topicEntry.key;
                                  final quizzes = topicEntry.value;
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
                                        size: 20,
                                      ),
                                      title: Text(
                                        topic,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 16,
                                          fontFamily: 'Montserrat',
                                        ),
                                      ),
                                      children:
                                          quizzes.map((quiz) {
                                            return FutureBuilder<
                                              List<Submission>
                                            >(
                                              future: _fetchQuizSubmissions([
                                                quiz,
                                              ]),
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState ==
                                                    ConnectionState.waiting) {
                                                  return Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          16,
                                                        ),
                                                    child: const CircularProgressIndicator(
                                                      strokeWidth: 3,
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                            Color
                                                          >(Colors.white70),
                                                    ),
                                                  );
                                                }
                                                final submissions =
                                                    snapshot.data ?? [];
                                                return FadeInUp(
                                                  duration: const Duration(
                                                    milliseconds: 900,
                                                  ),
                                                  child: Container(
                                                    margin:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 8,
                                                        ),
                                                    padding:
                                                        const EdgeInsets.all(
                                                          12,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          Colors.black
                                                              .withOpacity(0.4),
                                                          primaryColor
                                                              .withOpacity(0.2),
                                                        ],
                                                        begin:
                                                            Alignment.topLeft,
                                                        end:
                                                            Alignment
                                                                .bottomRight,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            16,
                                                          ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: primaryColor
                                                              .withOpacity(
                                                                0.15,
                                                              ),
                                                          blurRadius: 8,
                                                          offset: const Offset(
                                                            0,
                                                            2,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Icon(
                                                              Icons.quiz,
                                                              color:
                                                                  primaryColor,
                                                              size: 20,
                                                            ),
                                                            const SizedBox(
                                                              width: 8,
                                                            ),
                                                            Expanded(
                                                              child: Text(
                                                                quiz.title,
                                                                style: const TextStyle(
                                                                  color:
                                                                      Colors
                                                                          .white,
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontFamily:
                                                                      'Montserrat',
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 8,
                                                        ),
                                                        Text(
                                                          'Students Taken: ${submissions.length}',
                                                          style: const TextStyle(
                                                            color:
                                                                Colors.white70,
                                                            fontSize: 14,
                                                            fontFamily:
                                                                'Montserrat',
                                                          ),
                                                        ),
                                                        if (submissions
                                                            .isNotEmpty) ...[
                                                          const SizedBox(
                                                            height: 8,
                                                          ),
                                                          ...submissions.asMap().entries.map((
                                                            submissionEntry,
                                                          ) {
                                                            final submissionIndex =
                                                                submissionEntry
                                                                    .key;
                                                            final submission =
                                                                submissionEntry
                                                                    .value;
                                                            return FadeInUp(
                                                              duration:
                                                                  const Duration(
                                                                    milliseconds:
                                                                        1000,
                                                                  ),
                                                              child: FutureBuilder<
                                                                String
                                                              >(
                                                                future:
                                                                    _getStudentName(
                                                                      submission
                                                                          .userId,
                                                                    ),
                                                                builder: (
                                                                  context,
                                                                  nameSnapshot,
                                                                ) {
                                                                  final studentName =
                                                                      nameSnapshot
                                                                          .data ??
                                                                      'Student ${submission.userId.substring(0, 4)}';
                                                                  return Padding(
                                                                    padding:
                                                                        const EdgeInsets.only(
                                                                          top:
                                                                              4,
                                                                        ),
                                                                    child: Text(
                                                                      '$studentName: ${submission.score}%',
                                                                      style: const TextStyle(
                                                                        color:
                                                                            Colors.white70,
                                                                        fontSize:
                                                                            14,
                                                                        fontFamily:
                                                                            'Montserrat',
                                                                      ),
                                                                    ),
                                                                  );
                                                                },
                                                              ),
                                                            );
                                                          }),
                                                        ],
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          }).toList(),
                                    ),
                                  );
                                }).toList(),
                          ),
                        ),
                      );
                    }).toList(),
                    if (subjectTopicGroups.isEmpty)
                      FadeInUp(
                        duration: const Duration(milliseconds: 1000),
                        child: const Center(
                          child: Text(
                            'No quizzes created yet',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 18,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                            ),
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
    );
  }

  Future<Map<String, double>> _calculateSubjectAverages(
    List<Quiz> quizzes,
  ) async {
    final subjectAverages = <String, double>{};
    for (var quiz in quizzes) {
      final submissionsSnapshot =
          await FirebaseFirestore.instance
              .collection('quizzes')
              .doc(quiz.id)
              .collection('submissions')
              .get();
      final submissions =
          submissionsSnapshot.docs
              .map((doc) => Submission.fromJson(doc.data()))
              .toList();
      final subject = quiz.subject;
      final scores = submissions.map((s) => s.score.toDouble()).toList();
      if (scores.isNotEmpty) {
        final avgScore = scores.reduce((a, b) => a + b) / scores.length;
        subjectAverages[subject] = avgScore;
      } else {
        subjectAverages[subject] = 0.0;
      }
    }
    return subjectAverages;
  }

  Future<List<Submission>> _fetchQuizSubmissions(List<Quiz> quizzes) async {
    final List<Submission> allSubmissions = [];
    for (var quiz in quizzes) {
      final submissionsSnapshot =
          await FirebaseFirestore.instance
              .collection('quizzes')
              .doc(quiz.id)
              .collection('submissions')
              .get();
      allSubmissions.addAll(
        submissionsSnapshot.docs.map((doc) => Submission.fromJson(doc.data())),
      );
    }
    return allSubmissions;
  }

  Future<String> _getStudentName(String userId) async {
    if (_studentNameCache.containsKey(userId)) {
      return _studentNameCache[userId]!;
    }
    try {
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();
      final studentName =
          userDoc.data()?['displayName'] as String? ??
          'Student ${userId.substring(0, 4)}';
      _studentNameCache[userId] = studentName;
      return studentName;
    } catch (e) {
      print('Error fetching student name for $userId: $e');
      return 'Student ${userId.substring(0, 4)}';
    }
  }
}
