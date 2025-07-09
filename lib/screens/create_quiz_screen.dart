import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../providers/auth_provider.dart';
import '../providers/quiz_provider.dart';
import '../models/quiz.dart';

class CreateQuizScreen extends StatefulWidget {
  const CreateQuizScreen({Key? key}) : super(key: key);

  @override
  _CreateQuizScreenState createState() => _CreateQuizScreenState();
}

class _CreateQuizScreenState extends State<CreateQuizScreen> {
  final _titleController = TextEditingController();
  final _customSubjectController = TextEditingController();
  final _topicController = TextEditingController();
  final _attemptLimitController = TextEditingController(text: '0');
  String? _selectedSubject;
  bool _showCustomSubjectField = false;
  bool _isSaveAndAddLoading =
      false; // Separate loading state for Save & Add Another
  bool _isSaveAndExitLoading = false; // Separate loading state for Save & Exit
  bool _showTopicError = false; // Validation variable for topic error
  final Color primaryColor = const Color(0xFF7C4DFF);

  final List<String> _subjects = [
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

  List<Map<String, dynamic>> _questions = [
    {
      'question': '',
      'type': 'mcq',
      'options': ['', '', '', ''],
      'correctAnswer': 'Option 1',
      'controller': TextEditingController(),
      'optionControllers': [
        TextEditingController(),
        TextEditingController(),
        TextEditingController(),
        TextEditingController(),
      ],
    },
  ];

  Widget _buildSubjectSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownMenu<String>(
          initialSelection: _selectedSubject ?? 'Subject',
          width: MediaQuery.of(context).size.width * 0.85,
          textStyle: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Montserrat',
          ),
          inputDecorationTheme: InputDecorationTheme(
            labelStyle: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontFamily: 'Montserrat',
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryColor.withOpacity(0.4)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryColor, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryColor.withOpacity(0.4)),
            ),
            filled: true,
            fillColor: const Color(0xFF2A2D36),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ),
          ),
          leadingIcon: Icon(Icons.book, color: primaryColor),
          dropdownMenuEntries:
              _subjects.map((subject) {
                return DropdownMenuEntry<String>(
                  value: subject,
                  label: subject,
                  enabled: subject != 'Subject',
                  style: ButtonStyle(
                    textStyle: WidgetStateProperty.all(
                      const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                );
              }).toList(),
          onSelected: (value) {
            setState(() {
              _selectedSubject = value;
              _showCustomSubjectField = value == 'Other';
              if (!_showCustomSubjectField) {
                _customSubjectController.clear();
              }
            });
          },
          menuStyle: MenuStyle(
            backgroundColor: WidgetStateProperty.all(const Color(0xFF1A1A1A)),
            elevation: WidgetStateProperty.all(8),
          ),
        ),
        if (_showCustomSubjectField)
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: TextField(
              controller: _customSubjectController,
              decoration: InputDecoration(
                labelText: 'Custom Subject',
                labelStyle: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontFamily: 'Montserrat',
                ),
                prefixIcon: Icon(Icons.edit, color: primaryColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryColor.withOpacity(0.4)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryColor, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryColor.withOpacity(0.4)),
                ),
                filled: true,
                fillColor: const Color(0xFF2A2D36),
                errorText:
                    _showCustomSubjectField &&
                            _customSubjectController.text.isEmpty
                        ? 'Custom subject is required'
                        : null,
              ),
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Montserrat',
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
      ],
    );
  }

  Widget _buildTopicField() {
    return TextField(
      controller: _topicController,
      decoration: InputDecoration(
        labelText: 'Topic',
        labelStyle: const TextStyle(
          color: Colors.white70,
          fontSize: 16,
          fontFamily: 'Montserrat',
        ),
        prefixIcon: Icon(Icons.topic, color: primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor.withOpacity(0.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor.withOpacity(0.4)),
        ),
        filled: true,
        fillColor: const Color(0xFF2A2D36),
        errorText: _showTopicError ? 'Topic is required' : null,
      ),
      style: const TextStyle(color: Colors.white, fontFamily: 'Montserrat'),
      onChanged:
          (value) =>
              setState(() {}), // Only update UI, no error validation here
    );
  }

  void _addNewQuestion() {
    setState(() {
      _questions.add({
        'question': '',
        'type': 'mcq',
        'options': ['', '', '', ''],
        'correctAnswer': 'Option 1',
        'controller': TextEditingController(),
        'optionControllers': [
          TextEditingController(),
          TextEditingController(),
          TextEditingController(),
          TextEditingController(),
        ],
      });
    });
  }

  void _removeQuestion(int index) {
    setState(() {
      if (_questions.length > 1) {
        _questions[index]['controller'].dispose();
        for (var controller in _questions[index]['optionControllers']) {
          controller.dispose();
        }
        _questions.removeAt(index);
      } else {
        Fluttertoast.showToast(
          msg: 'At least one question is required',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    });
  }

  Future<void> _saveQuiz({required bool isAddAnother}) async {
    // Common validation logic
    setState(() {
      _showTopicError = _topicController.text.isEmpty;
    });
    if (_titleController.text.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Please enter a quiz title',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }
    if (_selectedSubject == null || _selectedSubject == 'Subject') {
      Fluttertoast.showToast(
        msg: 'Please select a subject',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }
    if (_selectedSubject == 'Other' && _customSubjectController.text.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Please enter a custom subject',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }
    if (_topicController.text.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Please enter a topic',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }
    if (_questions.any(
      (q) =>
          q['question'].isEmpty ||
          (q['options'] as List<String>).any((String opt) => opt.isEmpty),
    )) {
      Fluttertoast.showToast(
        msg: 'Please fill all questions and options',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);

    final quiz = Quiz(
      id: '',
      title: _titleController.text,
      subject:
          _selectedSubject == 'Other'
              ? _customSubjectController.text
              : _selectedSubject!,
      topic: _topicController.text,
      attemptLimit: int.tryParse(_attemptLimitController.text) ?? 0,
      questions:
          _questions.map((q) {
            final options = List<String>.from(q['options']);
            final correctAnswer =
                q['type'] == 'true_false'
                    ? q['correctAnswer']
                    : options[int.parse(
                          q['correctAnswer'].replaceAll('Option ', ''),
                        ) -
                        1];
            return Question(
              question: q['question'],
              type: q['type'],
              options: options,
              correctAnswer: correctAnswer,
            );
          }).toList(),
      createdBy: authProvider.user!.uid,
      assignedTo: [],
      createdAt: DateTime.now(),
      submittedUsers: [],
      attempts: {},
    );

    try {
      setState(() {
        if (isAddAnother) {
          _isSaveAndAddLoading = true;
        } else {
          _isSaveAndExitLoading = true;
        }
      });
      await quizProvider.createQuiz(quiz);
      Fluttertoast.showToast(
        msg: 'Quiz saved successfully!',
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
      await quizProvider.fetchQuizzes(
        authProvider.user!.uid,
        authProvider.userRole!,
      );
      // Reset quiz-specific fields
      setState(() {
        _titleController.clear();
        _questions = [
          {
            'question': '',
            'type': 'mcq',
            'options': ['', '', '', ''],
            'correctAnswer': 'Option 1',
            'controller': TextEditingController(),
            'optionControllers': [
              TextEditingController(),
              TextEditingController(),
              TextEditingController(),
              TextEditingController(),
            ],
          },
        ];
        if (!isAddAnother) {
          // Reset additional fields for Save & Exit
          _customSubjectController.clear();
          _topicController.clear();
          _attemptLimitController.text = '0';
          _selectedSubject = null;
          _showCustomSubjectField = false;
        }
      });
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to save quiz: $e',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() {
          if (isAddAnother) {
            _isSaveAndAddLoading = false;
          } else {
            _isSaveAndExitLoading = false;
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        automaticallyImplyLeading: false, // 👈 Hides the back button
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: FadeInDown(
          child: Text(
            'Create Quiz',
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Quiz Title',
                      labelStyle: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontFamily: 'Montserrat',
                      ),
                      prefixIcon: Icon(Icons.title, color: primaryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: primaryColor.withOpacity(0.4),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: primaryColor, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: primaryColor.withOpacity(0.4),
                        ),
                      ),
                      filled: true,
                      fillColor: const Color(0xFF2A2D36),
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Montserrat',
                    ),
                    onChanged: (value) => setState(() {}),
                  ),
                  const SizedBox(height: 20),
                  _buildSubjectSelector(),
                  const SizedBox(height: 20),
                  _buildTopicField(),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _attemptLimitController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: 'Max Attempts (0 = unlimited)',
                      labelStyle: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontFamily: 'Montserrat',
                      ),
                      prefixIcon: Icon(Icons.repeat, color: primaryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: primaryColor.withOpacity(0.4),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: primaryColor, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: primaryColor.withOpacity(0.4),
                        ),
                      ),
                      filled: true,
                      fillColor: const Color(0xFF2A2D36),
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: ListView.builder(
                      itemCount: _questions.length,
                      itemBuilder: (context, index) {
                        final question = _questions[index];
                        return FadeInUp(
                          duration: Duration(milliseconds: 300 + (index * 100)),
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 10.0),
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
                                filter: ImageFilter.blur(
                                  sigmaX: 10,
                                  sigmaY: 10,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Question ${index + 1}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: Colors.white,
                                              fontFamily: 'Montserrat',
                                              shadows: [
                                                Shadow(
                                                  color: primaryColor
                                                      .withOpacity(0.3),
                                                  blurRadius: 4,
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (_questions.length > 1)
                                            IconButton(
                                              icon: Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                              ),
                                              onPressed:
                                                  () => _removeQuestion(index),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      TextField(
                                        controller: question['controller'],
                                        onChanged: (value) {
                                          question['question'] = value;
                                          setState(() {});
                                        },
                                        decoration: InputDecoration(
                                          labelText: 'Question Text',
                                          labelStyle: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 16,
                                            fontFamily: 'Montserrat',
                                          ),
                                          prefixIcon: Icon(
                                            Icons.question_answer,
                                            color: primaryColor,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: BorderSide(
                                              color: primaryColor.withOpacity(
                                                0.4,
                                              ),
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: BorderSide(
                                              color: primaryColor,
                                              width: 2,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: BorderSide(
                                              color: primaryColor.withOpacity(
                                                0.4,
                                              ),
                                            ),
                                          ),
                                          filled: true,
                                          fillColor: const Color(0xFF2A2D36),
                                        ),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Montserrat',
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      DropdownMenu<String>(
                                        initialSelection: question['type'],
                                        width:
                                            MediaQuery.of(context).size.width *
                                            0.85,
                                        textStyle: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontFamily: 'Montserrat',
                                        ),
                                        inputDecorationTheme:
                                            InputDecorationTheme(
                                              labelStyle: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 16,
                                                fontFamily: 'Montserrat',
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: BorderSide(
                                                  color: primaryColor
                                                      .withOpacity(0.4),
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: BorderSide(
                                                  color: primaryColor,
                                                  width: 2,
                                                ),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: BorderSide(
                                                  color: primaryColor
                                                      .withOpacity(0.4),
                                                ),
                                              ),
                                              filled: true,
                                              fillColor: const Color(
                                                0xFF2A2D36,
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 16,
                                                  ),
                                            ),
                                        leadingIcon: Icon(
                                          Icons.category,
                                          color: primaryColor,
                                        ),
                                        dropdownMenuEntries:
                                            ['mcq', 'true_false'].map((type) {
                                              return DropdownMenuEntry<String>(
                                                value: type,
                                                label:
                                                    type == 'mcq'
                                                        ? 'Multiple Choice'
                                                        : 'True/False',
                                                style: ButtonStyle(
                                                  textStyle:
                                                      WidgetStateProperty.all(
                                                        const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 16,
                                                          fontFamily:
                                                              'Montserrat',
                                                        ),
                                                      ),
                                                ),
                                              );
                                            }).toList(),
                                        onSelected: (value) {
                                          setState(() {
                                            question['type'] = value;
                                            if (value == 'true_false') {
                                              question['options'] = [
                                                'True',
                                                'False',
                                              ];
                                              question['correctAnswer'] =
                                                  'True';
                                              question['optionControllers'] = [
                                                TextEditingController(
                                                  text: 'True',
                                                ),
                                                TextEditingController(
                                                  text: 'False',
                                                ),
                                              ];
                                            } else {
                                              question['options'] = [
                                                '',
                                                '',
                                                '',
                                                '',
                                              ];
                                              question['correctAnswer'] =
                                                  'Option 1';
                                              question['optionControllers'] = [
                                                TextEditingController(),
                                                TextEditingController(),
                                                TextEditingController(),
                                                TextEditingController(),
                                              ];
                                            }
                                          });
                                        },
                                        menuStyle: MenuStyle(
                                          backgroundColor:
                                              WidgetStateProperty.all(
                                                const Color(0xFF1A1A1A),
                                              ),
                                          elevation: WidgetStateProperty.all(8),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      ...question['options'].asMap().entries.map(
                                        (entry) => Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 12.0,
                                          ),
                                          child: TextField(
                                            controller:
                                                question['optionControllers'][entry
                                                    .key],
                                            enabled:
                                                question['type'] !=
                                                'true_false',
                                            onChanged: (value) {
                                              if (question['type'] !=
                                                  'true_false') {
                                                question['options'][entry.key] =
                                                    value;
                                                setState(() {});
                                              }
                                            },
                                            decoration: InputDecoration(
                                              labelText:
                                                  question['type'] ==
                                                          'true_false'
                                                      ? question['options'][entry
                                                          .key]
                                                      : 'Option ${entry.key + 1}',
                                              labelStyle: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 16,
                                                fontFamily: 'Montserrat',
                                              ),
                                              prefixIcon: Icon(
                                                Icons.radio_button_unchecked,
                                                color: primaryColor,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: BorderSide(
                                                  color: primaryColor
                                                      .withOpacity(0.4),
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: BorderSide(
                                                  color: primaryColor,
                                                  width: 2,
                                                ),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: BorderSide(
                                                  color: primaryColor
                                                      .withOpacity(0.4),
                                                ),
                                              ),
                                              filled: true,
                                              fillColor: const Color(
                                                0xFF2A2D36,
                                              ),
                                            ),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontFamily: 'Montserrat',
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      DropdownMenu<String>(
                                        initialSelection:
                                            question['correctAnswer'],
                                        width:
                                            MediaQuery.of(context).size.width *
                                            0.85,
                                        textStyle: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontFamily: 'Montserrat',
                                        ),
                                        inputDecorationTheme:
                                            InputDecorationTheme(
                                              labelStyle: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 16,
                                                fontFamily: 'Montserrat',
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: BorderSide(
                                                  color: primaryColor
                                                      .withOpacity(0.4),
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: BorderSide(
                                                  color: primaryColor,
                                                  width: 2,
                                                ),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: BorderSide(
                                                  color: primaryColor
                                                      .withOpacity(0.4),
                                                ),
                                              ),
                                              filled: true,
                                              fillColor: const Color(
                                                0xFF2A2D36,
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 16,
                                                  ),
                                            ),
                                        leadingIcon: Icon(
                                          Icons.check_circle,
                                          color: primaryColor,
                                        ),
                                        dropdownMenuEntries: List.generate(
                                          question['options'].length,
                                          (i) => DropdownMenuEntry(
                                            value:
                                                question['type'] == 'true_false'
                                                    ? question['options'][i]
                                                    : 'Option ${i + 1}',
                                            label:
                                                question['type'] == 'true_false'
                                                    ? question['options'][i]
                                                    : 'Option ${i + 1}',
                                            style: ButtonStyle(
                                              textStyle:
                                                  WidgetStateProperty.all(
                                                    const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontFamily: 'Montserrat',
                                                    ),
                                                  ),
                                            ),
                                          ),
                                        ),
                                        onSelected: (value) {
                                          setState(() {
                                            question['correctAnswer'] = value;
                                          });
                                        },
                                        menuStyle: MenuStyle(
                                          backgroundColor:
                                              WidgetStateProperty.all(
                                                const Color(0xFF1A1A1A),
                                              ),
                                          elevation: WidgetStateProperty.all(8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed:
                        _isSaveAndAddLoading || _isSaveAndExitLoading
                            ? null
                            : () {
                              _addNewQuestion();
                            },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      elevation: 8,
                      shadowColor: Colors.green.withOpacity(0.5),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      'Add New Question',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed:
                              _isSaveAndAddLoading || _isSaveAndExitLoading
                                  ? null
                                  : () => _saveQuiz(isAddAnother: true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            elevation: 8,
                            shadowColor: primaryColor.withOpacity(0.5),
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child:
                              _isSaveAndAddLoading
                                  ? SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                  : const Text(
                                    'Save & Add Another',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Montserrat',
                                    ),
                                  ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed:
                              _isSaveAndAddLoading || _isSaveAndExitLoading
                                  ? null
                                  : () => _saveQuiz(isAddAnother: false),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            elevation: 8,
                            shadowColor: primaryColor.withOpacity(0.5),
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child:
                              _isSaveAndExitLoading
                                  ? SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                  : const Text(
                                    'Save & Exit',
                                    style: TextStyle(
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
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _customSubjectController.dispose();
    _topicController.dispose();
    _attemptLimitController.dispose();
    for (var question in _questions) {
      question['controller'].dispose();
      for (var controller in question['optionControllers']) {
        controller.dispose();
      }
    }
    super.dispose();
  }
}
