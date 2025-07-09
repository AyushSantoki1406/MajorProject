import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:quiz_app/screens/subject_quiz_screen.dart';
import '../models/quiz.dart';

class TopicQuizSelectionScreen extends StatelessWidget {
  final String subject;
  final Map<String, List<Quiz>> topicMap;
  final bool isInstructor;
  final String userId;

  const TopicQuizSelectionScreen({
    Key? key,
    required this.subject,
    required this.topicMap,
    required this.isInstructor,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF7C4DFF);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: FadeInDown(
          child: Text(
            subject,
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
            topicMap.isEmpty
                ? Center(
                  child: Text(
                    'No topics available',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                )
                : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: topicMap.length,
                  itemBuilder: (context, index) {
                    final topicEntry = topicMap.entries.elementAt(index);
                    final topic = topicEntry.key;
                    final quizzes = topicEntry.value;

                    return FadeInUp(
                      duration: Duration(milliseconds: 300 + (index * 100)),
                      child: Card(
                        color: const Color(0xFF2A2D36).withOpacity(0.7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: primaryColor.withOpacity(0.4),
                            width: 1.5,
                          ),
                        ),
                        elevation: 4,
                        child: ExpansionTile(
                          leading: Icon(
                            Icons.topic,
                            color: primaryColor,
                            size: 24,
                          ),
                          title: Text(
                            topic,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                          subtitle: Text(
                            '${quizzes.length} Quizzes',
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: 14,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                          children:
                              quizzes.map((quiz) {
                                return ListTile(
                                  leading: Icon(
                                    Icons.quiz,
                                    color: primaryColor,
                                    size: 20,
                                  ),
                                  title: Text(
                                    quiz.title,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontFamily: 'Montserrat',
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => SubjectQuizScreen(
                                              subject: subject,
                                              topic: topic,
                                              isInstructor: isInstructor,
                                              userId: userId,
                                            ),
                                      ),
                                    );
                                  },
                                );
                              }).toList(),
                        ),
                      ),
                    );
                  },
                ),
      ),
    );
  }
}
