import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth_provider;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/firebase_service.dart'; // adjust path if needed

class AuthProvider extends ChangeNotifier {
  firebase_auth_provider.User? _user;
  String? _errorMessage;
  String? _userRole;
  bool _isLoading = false; // Added isLoading property

  AuthProvider() {
    FirebaseService.auth.authStateChanges().listen(
      (user) async {
        _user = user;
        if (user != null) {
          try {
            final snapshot =
                await FirebaseService.firestore
                    .collection('users')
                    .doc(user.uid)
                    .get();
            _userRole = snapshot.data()?['role'];
            await user.updateDisplayName(snapshot.data()?['name']);
          } catch (e) {
            print('Error fetching user data: $e');
          }
        } else {
          _userRole = null;
        }
        notifyListeners();
      },
      onError: (e) {
        print('Auth state error: $e');
      },
    );
  }

  firebase_auth_provider.User? get user => _user;
  String? get userRole => _userRole;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading; // Added isLoading getter

  Future<void> signup(
    String email,
    String password,
    String name,
    String role,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();

      final userCredential = await FirebaseService.auth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          );
      _user = userCredential.user;

      if (_user != null) {
        // Update display name
        await _user!.updateDisplayName(name);

        // Save user data to Firestore
        await FirebaseService.firestore.collection('users').doc(_user!.uid).set(
          {
            'email': email.trim(),
            'name': name.trim(),
            'role':
                role.toLowerCase(), // Ensure consistency (learner/instructor)
            'createdAt': FieldValue.serverTimestamp(),
          },
        );

        // Save login state
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);

        _userRole = role.toLowerCase();
        _errorMessage = null;
      } else {
        throw Exception('User creation failed');
      }
    } catch (e) {
      _errorMessage = _formatErrorMessage(e);
      _user = null;
      _userRole = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      final userCredential = await FirebaseService.auth
          .signInWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          );
      _user = userCredential.user;

      if (_user != null) {
        final snapshot =
            await FirebaseService.firestore
                .collection('users')
                .doc(_user!.uid)
                .get();
        _userRole = snapshot.data()?['role'];
        await _user!.updateDisplayName(snapshot.data()?['name']);

        // Save login state
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);

        _errorMessage = null;
      } else {
        throw Exception('Login failed');
      }
    } catch (e) {
      _errorMessage = _formatErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();
      await FirebaseService.auth.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false);
      _user = null;
      _userRole = null;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = _formatErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setErrorMessage(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  String _formatErrorMessage(dynamic error) {
    String message = error.toString();
    if (error is firebase_auth_provider.FirebaseAuthException) {
      switch (error.code) {
        case 'email-already-in-use':
          return 'This email is already registered.';
        case 'invalid-email':
          return 'Please enter a valid email address.';
        case 'weak-password':
          return 'Password is too weak. Use at least 6 characters.';
        case 'user-not-found':
        case 'wrong-password':
          return 'Invalid email or password.';
        case 'too-many-requests':
          return 'Too many attempts. Please try again later.';
        default:
          return 'An error occurred: ${error.message ?? error.code}';
      }
    }
    return message;
  }
}
