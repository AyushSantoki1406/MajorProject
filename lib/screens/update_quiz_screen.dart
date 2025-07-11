import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../models/quiz.dart';
import '../providers/quiz_provider.dart';

class UpdateQuizScreen extends StatefulWidget {
  final Quiz quiz;

  const UpdateQuizScreen({Key? key, required this.quiz}) : super(key: key);

  @override
  State<UpdateQuizScreen> createState() => _UpdateQuizScreenState();
}

class _UpdateQuizScreenState extends State<UpdateQuizScreen> {
  late TextEditingController _titleController;
  late TextEditingController _subjectController;
  late TextEditingController _topicController;
  late TextEditingController _attemptLimitController;
  late List<Map<String, dynamic>> _questions;
  late List<TextEditingController> _questionControllers;
  late List<List<TextEditingController>> _optionControllers;
  bool _isLoading = false;
  final Color primaryColor = const Color(0xFF7C4DFF);

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.quiz.title);
    _subjectController = TextEditingController(text: widget.quiz.subject);
    _topicController = TextEditingController(text: widget.quiz.topic);
    _attemptLimitController = TextEditingController(
      text: widget.quiz.attemptLimit.toString(),
    );

    _questions =
        widget.quiz.questions.map((q) {
          return {
            'question': q.question,
            'type': q.type,
            'options': List<String>.from(q.options ?? ['', '', '', '']),
            'correctAnswer': q.correctAnswer ?? '',
          };
        }).toList();

    _questionControllers =
        widget.quiz.questions
            .map((q) => TextEditingController(text: q.question))
            .toList();

    _optionControllers =
        widget.quiz.questions.map((q) {
          return (q.type == 'true_false'
                  ? ['True', 'False']
                  : List<String>.from(q.options ?? ['', '', '', '']))
              .map((opt) => TextEditingController(text: opt))
              .toList();
        }).toList();
  }

  void _addQuestion() {
    setState(() {
      _questions.add({
        'question': '',
        'type': 'mcq',
        'options': ['', '', '', ''],
        'correctAnswer': 'Option 1',
      });
      _questionControllers.add(TextEditingController());
      _optionControllers.add([
        TextEditingController(),
        TextEditingController(),
        TextEditingController(),
        TextEditingController(),
      ]);
    });
  }

  void _removeQuestion(int index) {
    setState(() {
      if (_questions.length > 1) {
        _questionControllers[index].dispose();
        for (var controller in _optionControllers[index]) {
          controller.dispose();
        }
        _questions.removeAt(index);
        _questionControllers.removeAt(index);
        _optionControllers.removeAt(index);
      } else {
        Fluttertoast.showToast(
          msg: 'At least one question is required',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    });
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
        errorText: _topicController.text.isEmpty ? 'Topic is required' : null,
      ),
      style: const TextStyle(color: Colors.white, fontFamily: 'Montserrat'),
      onChanged: (value) => setState(() {}),
    );
  }

  @override
  Widget build(BuildContext context) {
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: FadeInDown(
          duration: const Duration(milliseconds: 800),
          child: Text(
            'Update Quiz',
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
                            borderSide: BorderSide(
                              color: primaryColor,
                              width: 2,
                            ),
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
                      TextField(
                        controller: _subjectController,
                        enabled: false,
                        decoration: InputDecoration(
                          labelText: 'Subject',
                          labelStyle: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontFamily: 'Montserrat',
                          ),
                          prefixIcon: Icon(Icons.book, color: primaryColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: primaryColor.withOpacity(0.4),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: primaryColor,
                              width: 2,
                            ),
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
                      _buildTopicField(),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _attemptLimitController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
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
                            borderSide: BorderSide(
                              color: primaryColor,
                              width: 2,
                            ),
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
                      const SizedBox(height: 24),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: ListView.builder(
                          itemCount: _questions.length,
                          itemBuilder: (context, index) {
                            final question = _questions[index];
                            final List<String> options = List<String>.from(
                              question['options'] ?? [],
                            );

                            return FadeInUp(
                              duration: Duration(
                                milliseconds: 300 + (index * 100),
                              ),
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 10.0,
                                ),
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
                                                  icon: const Icon(
                                                    Icons.delete,
                                                    color: Colors.red,
                                                  ),
                                                  onPressed:
                                                      () => _removeQuestion(
                                                        index,
                                                      ),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          TextField(
                                            controller:
                                                _questionControllers[index],
                                            onChanged: (value) {
                                              _questions[index]['question'] =
                                                  value;
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
                                          const SizedBox(height: 12),
                                          DropdownMenu<String>(
                                            initialSelection: question['type'],
                                            width:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width *
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
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                    borderSide: BorderSide(
                                                      color: primaryColor
                                                          .withOpacity(0.4),
                                                    ),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                        borderSide: BorderSide(
                                                          color: primaryColor,
                                                          width: 2,
                                                        ),
                                                      ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
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
                                                ['mcq', 'true_false'].map((
                                                  type,
                                                ) {
                                                  return DropdownMenuEntry<
                                                    String
                                                  >(
                                                    value: type,
                                                    label:
                                                        type == 'mcq'
                                                            ? 'Multiple Choice'
                                                            : 'True/False',
                                                    style: ButtonStyle(
                                                      textStyle:
                                                          WidgetStateProperty.all(
                                                            const TextStyle(
                                                              color:
                                                                  Colors.white,
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
                                                  _optionControllers[index] = [
                                                    TextEditingController(
                                                      text: 'True',
                                                    ),
                                                    TextEditingController(
                                                      text: 'False',
                                                    ),
                                                  ];
                                                } else {
                                                  // Preserve existing option texts if available
                                                  question['options'] = [
                                                    _optionControllers[index][0]
                                                            .text
                                                            .isNotEmpty
                                                        ? _optionControllers[index][0]
                                                            .text
                                                        : '',
                                                    _optionControllers[index][1]
                                                            .text
                                                            .isNotEmpty
                                                        ? _optionControllers[index][1]
                                                            .text
                                                        : '',
                                                    _optionControllers[index][2]
                                                            .text
                                                            .isNotEmpty
                                                        ? _optionControllers[index][2]
                                                            .text
                                                        : '',
                                                    _optionControllers[index][3]
                                                            .text
                                                            .isNotEmpty
                                                        ? _optionControllers[index][3]
                                                            .text
                                                        : '',
                                                  ];
                                                  // Set correctAnswer to first non-empty option or 'Option 1' if all empty
                                                  question['correctAnswer'] =
                                                      question['options']
                                                              .asMap()
                                                              .entries
                                                              .any(
                                                                (entry) =>
                                                                    entry
                                                                        .value
                                                                        .isNotEmpty,
                                                              )
                                                          ? 'Option 1'
                                                          : '';
                                                  _optionControllers[index] =
                                                      question['options']
                                                          .asMap()
                                                          .entries
                                                          .map(
                                                            (
                                                              entry,
                                                            ) => TextEditingController(
                                                              text: entry.value,
                                                            ),
                                                          )
                                                          .toList();
                                                }
                                              });
                                            },
                                            menuStyle: MenuStyle(
                                              backgroundColor:
                                                  WidgetStateProperty.all(
                                                    const Color.fromARGB(
                                                      255,
                                                      255,
                                                      255,
                                                      255,
                                                    ),
                                                  ),
                                              elevation:
                                                  WidgetStateProperty.all(8),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          ...options.asMap().entries.map(
                                            (entry) => Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 12.0,
                                              ),
                                              child: TextField(
                                                controller:
                                                    _optionControllers[index][entry
                                                        .key],
                                                enabled:
                                                    question['type'] !=
                                                    'true_false',
                                                onChanged: (value) {
                                                  if (question['type'] !=
                                                      'true_false') {
                                                    question['options'][entry
                                                            .key] =
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
                                                    Icons
                                                        .radio_button_unchecked,
                                                    color: primaryColor,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                    borderSide: BorderSide(
                                                      color: primaryColor
                                                          .withOpacity(0.4),
                                                    ),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                        borderSide: BorderSide(
                                                          color: primaryColor,
                                                          width: 2,
                                                        ),
                                                      ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
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
                                                MediaQuery.of(
                                                  context,
                                                ).size.width *
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
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                    borderSide: BorderSide(
                                                      color: primaryColor
                                                          .withOpacity(0.4),
                                                    ),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                        borderSide: BorderSide(
                                                          color: primaryColor,
                                                          width: 2,
                                                        ),
                                                      ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
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
                                              options.length,
                                              (i) {
                                                return DropdownMenuEntry(
                                                  value:
                                                      question['type'] ==
                                                              'true_false'
                                                          ? options[i]
                                                          : 'Option ${i + 1}',
                                                  label:
                                                      question['type'] ==
                                                              'true_false'
                                                          ? options[i]
                                                          : 'Option ${i + 1}',
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
                                              },
                                            ),
                                            onSelected: (value) {
                                              setState(() {
                                                question['correctAnswer'] =
                                                    value;
                                              });
                                            },
                                            menuStyle: MenuStyle(
                                              backgroundColor:
                                                  WidgetStateProperty.all(
                                                    const Color.fromARGB(
                                                      255,
                                                      255,
                                                      255,
                                                      255,
                                                    ),
                                                  ),
                                              elevation:
                                                  WidgetStateProperty.all(8),
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
                            _isLoading
                                ? null
                                : () async {
                                  if (_titleController.text.isEmpty) {
                                    Fluttertoast.showToast(
                                      msg: 'Please enter a quiz title',
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                    );
                                    return;
                                  }
                                  if (_subjectController.text.isEmpty) {
                                    Fluttertoast.showToast(
                                      msg: 'Please enter a subject',
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
                                        (q['options'] as List<String>).any(
                                          (opt) => opt.isEmpty,
                                        ),
                                  )) {
                                    Fluttertoast.showToast(
                                      msg:
                                          'Please fill all questions and options',
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                    );
                                    return;
                                  }

                                  final updatedQuiz = Quiz(
                                    id: widget.quiz.id,
                                    title: _titleController.text,
                                    subject: _subjectController.text,
                                    topic: _topicController.text,
                                    attemptLimit:
                                        int.tryParse(
                                          _attemptLimitController.text,
                                        ) ??
                                        0,
                                    questions:
                                        _questions.map((q) {
                                          final options = List<String>.from(
                                            q['options'],
                                          );
                                          final correctAnswer =
                                              q['type'] == 'true_false'
                                                  ? q['correctAnswer']
                                                  : options[int.parse(
                                                        q['correctAnswer']
                                                            .replaceAll(
                                                              'Option ',
                                                              '',
                                                            ),
                                                      ) -
                                                      1];
                                          return Question(
                                            question: q['question'],
                                            type: q['type'],
                                            options: options,
                                            correctAnswer: correctAnswer,
                                          );
                                        }).toList(),
                                    createdBy: widget.quiz.createdBy,
                                    assignedTo: widget.quiz.assignedTo,
                                    createdAt: widget.quiz.createdAt,
                                    submittedUsers: widget.quiz.submittedUsers,
                                    attempts: widget.quiz.attempts,
                                  );

                                  try {
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    await quizProvider.updateQuiz(updatedQuiz);
                                    Fluttertoast.showToast(
                                      msg: 'Quiz updated successfully!',
                                      backgroundColor: Colors.green,
                                      textColor: Colors.white,
                                    );
                                    Navigator.pop(context);
                                  } catch (e) {
                                    Fluttertoast.showToast(
                                      msg: 'Failed to update quiz: $e',
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
                                },
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
                            _isLoading
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
                                  'Save Changes',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                      ),
                    ],
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

  @override
  void dispose() {
    _titleController.dispose();
    _subjectController.dispose();
    _topicController.dispose();
    _attemptLimitController.dispose();
    for (var controller in _questionControllers) {
      controller.dispose();
    }
    for (var controllers in _optionControllers) {
      for (var controller in controllers) {
        controller.dispose();
      }
    }
    super.dispose();
  }
}
