import 'package:cloud_firestore/cloud_firestore.dart';

class Quiz {
  final String id;
  final String title;
  final String subject;
  final String topic;
  final int attemptLimit;
  final List<Question> questions;
  final String createdBy;
  final List<String> assignedTo;
  final DateTime createdAt;
  final List<String> submittedUsers;
  final Map<String, int>? attempts;
  final bool isPublished;

  static const List<String> availableSubjects = [
    'Subject',
    'Mathematics',
    'Science (Physics, Chemistry, Biology)',
    'English Grammar',
    'Computer Science / IT Basics',
    'General Knowledge',
    'Social Studies',
    'Environmental Science',
    'Current Affairs (Student Edition)',
    'Moral Education / Value Education',
    'Hindi / Regional Language',
    'Logical Reasoning / Aptitude',
    'Coding & Programming Basics',
    'History & Civics',
    'Geography',
    'Art & Culture (Indian and World)',
    'Other',
  ];

  Quiz({
    required this.id,
    required this.title,
    required this.subject,
    required this.topic,
    required this.attemptLimit,
    required this.questions,
    required this.createdBy,
    required this.assignedTo,
    required this.createdAt,
    required this.submittedUsers,
    this.attempts,
    required this.isPublished,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    final createdAtRaw = json['createdAt'];

    DateTime createdAt;
    if (createdAtRaw is Timestamp) {
      createdAt = createdAtRaw.toDate();
    } else if (createdAtRaw is String) {
      createdAt = DateTime.parse(createdAtRaw);
    } else if (createdAtRaw is Map) {
      createdAt = DateTime.fromMillisecondsSinceEpoch(
        (createdAtRaw['_seconds'] ?? 0) * 1000,
      );
    } else {
      createdAt = DateTime.now();
    }

    return Quiz(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      subject: json['subject'] ?? '',
      topic: json['topic'] ?? '',
      attemptLimit: json['attemptLimit'] ?? 1,
      questions:
          (json['questions'] as List<dynamic>?)
              ?.map((q) => Question.fromJson(q as Map<String, dynamic>))
              .toList() ??
          [],
      createdBy: json['createdBy'] ?? '',
      assignedTo: List<String>.from(json['assignedTo'] ?? []),
      createdAt: createdAt,
      submittedUsers: List<String>.from(json['submittedUsers'] ?? []),
      attempts: (json['attempts'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, value as int),
      ),
      isPublished: json['isPublished'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'subject': subject,
    'topic': topic,
    'attemptLimit': attemptLimit,
    'questions': questions.map((q) => q.toJson()).toList(),
    'createdBy': createdBy,
    'assignedTo': assignedTo,
    'createdAt': Timestamp.fromDate(createdAt),
    'submittedUsers': submittedUsers,
    'attempts': attempts,
    'isPublished': isPublished,
  };
}

class Question {
  final String question;
  final String type;
  final List<String>? options;
  final String? correctAnswer;
  final String? imageUrl;

  Question({
    required this.question,
    required this.type,
    this.options,
    this.correctAnswer,
    this.imageUrl,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      question: json['question'] ?? '',
      type: json['type'] ?? 'mcq',
      options:
          json['options'] != null ? List<String>.from(json['options']) : [],
      correctAnswer: json['correctAnswer'],
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() => {
    'question': question,
    'type': type,
    'options': options,
    'correctAnswer': correctAnswer,
    'imageUrl': imageUrl,
  };
}
