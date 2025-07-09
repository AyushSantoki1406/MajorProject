import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('Firebase initialized successfully');
    } catch (e) {
      print('Error initializing Firebase: $e');
      rethrow;
    }
  }

  static FirebaseAuth get auth => FirebaseAuth.instance;
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;
  static FirebaseStorage get storage => FirebaseStorage.instance;
}

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: "AIzaSyCKq8z9rLG69VuSasp5oiBjWOH5MnSAI8A",
      authDomain: "book-wave-5152c.firebaseapp.com",
      projectId: "book-wave-5152c",
      storageBucket: "book-wave-5152c.appspot.com",
      messagingSenderId: "527365810877",
      appId: "1:527365810877:web:616b5d168390e76423a5d4",
      measurementId: "G-16ZN3L4H81",
    );
  }
}
