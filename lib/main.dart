import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/providers/auth_provider.dart' as custom_auth;
import 'package:quiz_app/providers/quiz_provider.dart';
import 'package:quiz_app/screens/auth/login_screen.dart';
import 'package:quiz_app/screens/home_screen.dart';
import 'package:quiz_app/screens/onboarding_screen.dart';
import 'package:quiz_app/screens/splash_screen.dart';
import 'package:quiz_app/screens/profile_screen.dart';
import 'package:quiz_app/screens/create_quiz_screen.dart';
import 'package:quiz_app/screens/library_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

const FirebaseOptions firebaseOptions = FirebaseOptions(
  apiKey: "AIzaSyCAGNN3b5LkO6hZ5Y8hv0v3raBI1b6DIC0",
  authDomain: "book-wave-5152c.firebaseapp.com",
  projectId: "book-wave-5152c",
  storageBucket: "book-wave-5152c.appspot.com",
  messagingSenderId: "527365810877",
  appId: "1:527365810877:android:95d3c49ad476a82923a5d4",
  measurementId:
      "G-16ZN3L4H81", // Optional; remove if not using Google Analytics
);

/// 🔹 Background FCM handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(options: firebaseOptions);
  }
  print('🔔 Background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: firebaseOptions);
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') {
      rethrow;
    }
  }
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  final prefs = await SharedPreferences.getInstance();
  final showOnboarding = !(prefs.getBool('onboarding_seen') ?? false);
  runApp(QuizApp(showOnboarding: showOnboarding));
}

class QuizApp extends StatelessWidget {
  final bool showOnboarding;
  const QuizApp({Key? key, required this.showOnboarding}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => custom_auth.AuthProvider()),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
      ],
      child: MaterialApp(
        title: 'Quiz Management System',
        theme: ThemeData(
          primarySwatch: Colors.teal,
          scaffoldBackgroundColor: const Color(0xFF1E1E1E),
          textTheme: const TextTheme(
            bodyMedium: TextStyle(
              color: Color(0xFFB0BEC5),
              fontFamily: 'OpenSans',
            ),
            titleLarge: TextStyle(
              color: Color(0xFFE0F7FA),
              fontWeight: FontWeight.bold,
              fontFamily: 'OpenSans',
            ),
          ),
        ),
        debugShowCheckedModeBanner: false,
        home: showOnboarding ? const OnboardingScreen() : const SplashScreen(),
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const TabNavigator(),
          '/create_quiz': (context) => const CreateQuizScreen(),
          '/library': (context) => const LibraryScreen(),
          '/profile': (context) => const ProfileScreen(),
        },
      ),
    );
  }
}

class TabNavigator extends StatefulWidget {
  const TabNavigator({Key? key}) : super(key: key);

  @override
  _TabNavigatorState createState() => _TabNavigatorState();
}

class _TabNavigatorState extends State<TabNavigator>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  final List<Widget> _pages = const [
    HomeScreen(),
    CreateQuizScreen(),
    LibraryScreen(),
    ProfileScreen(),
  ];

  final List<String> _titles = ['Home', 'Create Quiz', 'Library', 'Profile'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _animationController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizProvider>(
      builder: (context, quizProvider, child) {
        final Color headerColor = const Color(0xFF6949FF);

        return Scaffold(
          body: FadeTransition(
            opacity: _scaleAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: _pages[_selectedIndex],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home, size: 28),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.create, size: 28),
                label: 'Create Quiz',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.library_books, size: 28),
                label: 'Library',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person, size: 28),
                label: 'Profile',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: headerColor,
            unselectedItemColor: const Color(0xFFB0BEC5),
            onTap: _onItemTapped,
            backgroundColor: const Color(0xFF212121),
            elevation: 20,
            type: BottomNavigationBarType.fixed,
            selectedLabelStyle: const TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 12,
            ),
            selectedIconTheme: IconThemeData(size: 30, color: headerColor),
            unselectedIconTheme: const IconThemeData(
              size: 26,
              color: Color(0xFFB0BEC5),
            ),
          ),
        );
      },
    );
  }
}
