import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quiz.dart';
import '../providers/auth_provider.dart';
import '../providers/quiz_provider.dart';
import 'subject_quiz_screen.dart';
import 'create_quiz_screen.dart';
import 'instructor_dashboard_screen.dart';
import 'topic_quiz_selection_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _selectedAvatarIndex = 0;
  final Color primaryColor = const Color(0xFF7C4DFF);
  bool _isFetchAttempted = false;

  final List<String> _avatarAssets = [
    'assets/avatars/a1.jpg',
    'assets/avatars/a2.jpg',
    'assets/avatars/a3.jpg',
    'assets/avatars/a4.jpg',
    'assets/avatars/a5.jpg',
    'assets/avatars/a6.jpg',
    'assets/avatars/a7.jpg',
    'assets/avatars/a8.jpg',
    'assets/avatars/a9.jpg',
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutQuint),
    );
    _animationController.forward();
    _loadSavedAvatarIndex();
  }

  Future<void> _loadSavedAvatarIndex() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedAvatarIndex = prefs.getInt('selectedAvatarIndex') ?? 0;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizProvider>(
      builder: (context, quizProvider, child) {
        final authProvider = Provider.of<AuthProvider>(context);
        final isInstructor =
            authProvider.userRole?.toLowerCase() == 'instructor';
        final userId = authProvider.user!.uid;

        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (quizProvider.quizzes.isEmpty &&
              !quizProvider.isLoading &&
              !_isFetchAttempted) {
            setState(() {
              _isFetchAttempted = true;
            });
            try {
              await quizProvider.fetchAllQuizzes().timeout(
                const Duration(seconds: 10),
                onTimeout: () {
                  quizProvider.setLoading(false);
                  Fluttertoast.showToast(
                    msg: 'Quiz fetch timed out',
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                },
              );
            } catch (e) {
              quizProvider.setLoading(false);
              Fluttertoast.showToast(
                msg: 'Failed to load quizzes: $e',
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0,
              );
            }
          }
        });

        final allQuizzes =
            quizProvider.quizzes
                .where(
                  (quiz) =>
                      quiz.subject.isNotEmpty &&
                      (quiz.isPublished || quiz.createdBy == userId),
                )
                .toList();
        final myQuizzes =
            isInstructor
                ? allQuizzes.where((quiz) => quiz.createdBy == userId).toList()
                : [];
        final allSubjects =
            allQuizzes
                .map((quiz) => quiz.subject)
                .toSet()
                .toList()
                .cast<String>();
        final mySubjects =
            myQuizzes
                .map((quiz) => quiz.subject)
                .toSet()
                .toList()
                .cast<String>();

        // Group quizzes by subject and then by topic
        final subjectTopicMap = <String, Map<String, List<Quiz>>>{};
        for (var quiz in allQuizzes) {
          if (!subjectTopicMap.containsKey(quiz.subject)) {
            subjectTopicMap[quiz.subject] = {};
          }
          if (!subjectTopicMap[quiz.subject]!.containsKey(quiz.topic)) {
            subjectTopicMap[quiz.subject]![quiz.topic] = [];
          }
          subjectTopicMap[quiz.subject]![quiz.topic]!.add(quiz);
        }

        final mySubjectTopicMap = <String, Map<String, List<Quiz>>>{};
        for (var quiz in myQuizzes) {
          if (!mySubjectTopicMap.containsKey(quiz.subject)) {
            mySubjectTopicMap[quiz.subject] = {};
          }
          if (!mySubjectTopicMap[quiz.subject]!.containsKey(quiz.topic)) {
            mySubjectTopicMap[quiz.subject]![quiz.topic] = [];
          }
          mySubjectTopicMap[quiz.subject]![quiz.topic]!.add(quiz);
        }

        final subjectIcons = {
          "Mathematics": Icons.calculate,
          "Science (Physics, Chemistry, Biology)": Icons.science,
          "English Grammar": Icons.book,
          "Computer Science / IT Basics": Icons.computer,
          "General Knowledge": Icons.lightbulb,
          "Social Studies": Icons.people,
          "Environmental Science": Icons.eco,
          "Current Affairs (Student Edition)": Icons.newspaper,
          "Moral Education / Value Education": Icons.favorite,
          "Hindi / Regional Language": Icons.language,
          "Logical Reasoning / Aptitude": Icons.bar_chart,
          "Coding & Programming Basics": Icons.code,
          "History & Civics": Icons.history,
          "Geography": Icons.map,
          "Art & Culture (Indian and World)": Icons.palette,
          "Other": Icons.category,
        };

        return Scaffold(
          backgroundColor: const Color(0xFF0D0D0D),
          body: SafeArea(
            child: Column(
              children: [
                FadeInDown(
                  duration: const Duration(milliseconds: 800),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryColor.withOpacity(0.8), Colors.black87],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.transparent,
                              backgroundImage: AssetImage(
                                _avatarAssets[_selectedAvatarIndex],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome, ${isInstructor ? 'Instructor' : 'Learner'} ${authProvider.user?.displayName ?? 'User'}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                                Text(
                                  isInstructor
                                      ? 'Manage your quizzes'
                                      : 'Explore your subjects',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (isInstructor)
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              const InstructorDashboardScreen(),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.dashboard,
                                    color: primaryColor,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child:
                      quizProvider.isLoading
                          ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF2A2D36,
                                    ).withOpacity(0.6),
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
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      primaryColor,
                                    ),
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
                          : allQuizzes.isEmpty
                          ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.quiz,
                                  color: primaryColor.withOpacity(0.6),
                                  size: 64,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'No subjects available',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 18,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                                if (isInstructor) ...[
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) =>
                                                  const CreateQuizScreen(),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColor,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      'Create a Quiz',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Montserrat',
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          )
                          : SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 20,
                                    top: 20,
                                    bottom: 10,
                                  ),
                                  child: const Text(
                                    'All Quizzes',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Montserrat',
                                    ),
                                  ),
                                ),
                                _buildSubjectGrid(
                                  context,
                                  allSubjects,
                                  subjectTopicMap,
                                  subjectIcons,
                                  primaryColor,
                                  _fadeAnimation,
                                  isInstructor,
                                  userId,
                                ),
                                if (isInstructor && mySubjects.isNotEmpty) ...[
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 20,
                                      top: 20,
                                      bottom: 10,
                                    ),
                                    child: const Text(
                                      'My Created Quizzes',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Montserrat',
                                      ),
                                    ),
                                  ),
                                  _buildSubjectGrid(
                                    context,
                                    mySubjects,
                                    mySubjectTopicMap,
                                    subjectIcons,
                                    primaryColor,
                                    _fadeAnimation,
                                    isInstructor,
                                    userId,
                                  ),
                                ],
                              ],
                            ),
                          ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubjectGrid(
    BuildContext context,
    List<String> subjects,
    Map<String, Map<String, List<Quiz>>> subjectTopicMap,
    Map<String, IconData> subjectIcons,
    Color primaryColor,
    Animation<double> fadeAnimation,
    bool isInstructor,
    String userId,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 180,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: subjects.length,
      itemBuilder: (context, index) {
        final subject = subjects[index];
        final topicMap = subjectTopicMap[subject] ?? {};
        final icon = subjectIcons[subject] ?? Icons.help;

        return FadeTransition(
          opacity: fadeAnimation,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => TopicQuizSelectionScreen(
                        subject: subject,
                        topicMap: topicMap,
                        isInstructor: isInstructor,
                        userId: userId,
                      ),
                ),
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryColor.withOpacity(0.2),
                    const Color(0xFF2A2D36).withOpacity(0.4),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: primaryColor.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryColor, const Color(0xFF8B5CFE)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 36, color: Colors.white),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      subject,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontFamily: 'Montserrat',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '${topicMap.length} Topics',
                      style: TextStyle(
                        fontSize: 12,
                        color: primaryColor,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
