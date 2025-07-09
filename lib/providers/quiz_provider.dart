import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/quiz.dart';

class Submission {
  final String id;
  final String userId;
  final String quizId;
  final int score;
  final List<String> answers;
  final DateTime submittedAt;

  Submission({
    required this.id,
    required this.userId,
    required this.quizId,
    required this.score,
    required this.answers,
    required this.submittedAt,
  });

  factory Submission.fromJson(Map<String, dynamic> json) {
    return Submission(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      quizId: json['quizId'] ?? '',
      score: json['score'] ?? 0,
      answers: List<String>.from(json['answers'] ?? []),
      submittedAt:
          json['submittedAt'] is String
              ? DateTime.parse(json['submittedAt'])
              : (json['submittedAt'] is Timestamp
                  ? (json['submittedAt'] as Timestamp).toDate()
                  : DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'quizId': quizId,
    'score': score,
    'answers': answers,
    'submittedAt': Timestamp.fromDate(submittedAt),
  };
}

class QuizProvider with ChangeNotifier {
  List<Quiz> _quizzes = [];
  bool _isLoading = false;
  String? _error;

  List<Quiz> get quizzes => _quizzes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> fetchQuizzes([String? userId, String? userRole]) async {
    try {
      setLoading(true);
      Query<Map<String, dynamic>> query = _firestore.collection('quizzes');
      if (userId != null && userRole != null) {
        if (userRole.toLowerCase() == 'instructor') {
          query = query.where('createdBy', isEqualTo: userId);
        } else {
          query = query.where('assignedTo', arrayContains: userId);
        }
      }

      final querySnapshot = await query.get();
      _quizzes = [];
      for (var doc in querySnapshot.docs) {
        final quizData = doc.data();
        _quizzes.add(Quiz.fromJson({...quizData, 'id': doc.id}));
      }
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      print('Error fetching quizzes: $e');
    } finally {
      setLoading(false);
    }
  }

  Future<void> fetchAllQuizzes() async {
    try {
      setLoading(true);
      final querySnapshot = await _firestore.collection('quizzes').get();
      _quizzes = [];
      for (var doc in querySnapshot.docs) {
        final quizData = doc.data();
        _quizzes.add(Quiz.fromJson({...quizData, 'id': doc.id}));
      }
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      print('Error fetching all quizzes: $e');
    } finally {
      setLoading(false);
    }
  }

  Future<void> createQuiz(Quiz quiz) async {
    try {
      setLoading(true);
      if (!Quiz.availableSubjects.contains(quiz.subject)) {
        throw Exception(
          'Invalid subject: ${quiz.subject}. Must be one of ${Quiz.availableSubjects}',
        );
      }
      final quizRef = _firestore.collection('quizzes').doc();
      final quizData = quiz.toJson();
      quizData['id'] = quizRef.id;
      await quizRef.set(quizData);
      await fetchAllQuizzes();
      _error = null;
    } catch (e) {
      _error = e.toString();
      print('Error creating quiz: $e');
    } finally {
      setLoading(false);
    }
  }

  Future<void> submitQuiz(
    String quizId,
    String userId,
    List<String> answers,
  ) async {
    try {
      setLoading(true);
      final quizRef = _firestore.collection('quizzes').doc(quizId);
      final quizSnapshot = await quizRef.get();
      if (!quizSnapshot.exists) {
        throw Exception('Quiz not found');
      }
      final quizData = quizSnapshot.data()!;
      final quiz = Quiz.fromJson({...quizData, 'id': quizId});
      final currentAttempts = Map<String, int>.from(quizData['attempts'] ?? {});
      final attemptCount = (currentAttempts[userId] ?? 0) + 1;
      final updatedAttempts = {...currentAttempts, userId: attemptCount};
      final updatedSubmittedUsers =
          quizData['submittedUsers']?.contains(userId) ?? false
              ? quizData['submittedUsers']
              : [...(quizData['submittedUsers'] ?? []), userId];

      int score = 0;
      for (int i = 0; i < quiz.questions.length && i < answers.length; i++) {
        final userAnswer = answers[i]?.trim().toLowerCase() ?? '';
        final correctAnswer =
            quiz.questions[i].correctAnswer?.trim().toLowerCase() ?? '';
        final options = quiz.questions[i].options ?? [];
        bool isCorrect = false;

        if (userAnswer == correctAnswer) {
          isCorrect = true;
        } else if (RegExp(r'^\d+$').hasMatch(userAnswer) &&
            options.isNotEmpty) {
          try {
            final optionIndex = int.parse(userAnswer);
            if (optionIndex >= 0 && optionIndex < options.length) {
              isCorrect = options[optionIndex].toLowerCase() == correctAnswer;
            }
          } catch (e) {
            print('Error parsing index answer: $userAnswer');
          }
        } else if (quiz.questions[i].type == 'true_false') {
          isCorrect =
              userAnswer == correctAnswer ||
              (userAnswer == 'true' && correctAnswer == 'true') ||
              (userAnswer == 'false' && correctAnswer == 'false');
        }

        if (isCorrect) {
          score += 1;
        }
      }
      final scorePercentage =
          quiz.questions.isNotEmpty
              ? (score / quiz.questions.length * 100).round()
              : 0;

      final submissionRef = quizRef.collection('submissions').doc();
      await submissionRef.set({
        'id': submissionRef.id,
        'userId': userId,
        'quizId': quizId,
        'score': scorePercentage,
        'answers': answers,
        'submittedAt': Timestamp.fromDate(DateTime.now()),
      });

      await quizRef.update({
        'attempts': updatedAttempts,
        'submittedUsers': updatedSubmittedUsers,
      });

      await fetchAllQuizzes();
      _error = null;
    } catch (e) {
      _error = e.toString();
      print('Error submitting quiz: $e');
    } finally {
      setLoading(false);
    }
  }

  Future<void> deleteQuiz(String id) async {
    try {
      setLoading(true);
      final quizRef = _firestore.collection('quizzes').doc(id);
      final quizSnapshot = await quizRef.get();
      if (!quizSnapshot.exists) {
        throw Exception('Quiz not found');
      }
      await quizRef.delete();
      await fetchAllQuizzes();
      _error = null;
    } catch (e) {
      _error = e.toString();
      print('Error deleting quiz: $e');
    } finally {
      setLoading(false);
    }
  }

  Future<void> updateQuiz(Quiz quiz) async {
    try {
      setLoading(true);
      await _firestore.collection('quizzes').doc(quiz.id).update({
        'title': quiz.title,
        'subject': quiz.subject,
        'topic': quiz.topic,
        'attemptLimit': quiz.attemptLimit,
        'questions':
            quiz.questions
                .map(
                  (q) => {
                    'question': q.question,
                    'type': q.type,
                    'options': q.options ?? [],
                    'correctAnswer': q.correctAnswer,
                    'imageUrl': q.imageUrl,
                  },
                )
                .toList(),
        'createdBy': quiz.createdBy,
        'assignedTo': quiz.assignedTo,
        'submittedUsers': quiz.submittedUsers,
        'attempts': quiz.attempts,
      });
      await fetchAllQuizzes();
      _error = null;
    } catch (e) {
      _error = e.toString();
      print('Error updating quiz: $e');
    } finally {
      setLoading(false);
    }
  }

  Future<List<Submission>> fetchUserSubmissions(String userId) async {
    try {
      final List<Submission> submissions = [];
      final quizSnapshot = await _firestore.collection('quizzes').get();
      for (final quizDoc in quizSnapshot.docs) {
        final submissionSnapshot =
            await quizDoc.reference
                .collection('submissions')
                .where('userId', isEqualTo: userId)
                .get();
        submissions.addAll(
          submissionSnapshot.docs.map((doc) => Submission.fromJson(doc.data())),
        );
      }
      return submissions;
    } catch (e) {
      print('Error fetching submissions: $e');
      return [];
    }
  }
}
