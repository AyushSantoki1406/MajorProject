import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/providers/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth_provider;
import 'package:google_sign_in/google_sign_in.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _selectedRole;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<firebase_auth_provider.UserCredential> signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId:
            '527365810877-con3t0b4s54ibgasvhcldg36t47esupo.apps.googleusercontent.com',
      );
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        setState(() {
          _isLoading = false;
        });
        throw Exception('Google sign-in cancelled');
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = firebase_auth_provider.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      return await firebase_auth_provider.FirebaseAuth.instance
          .signInWithCredential(credential);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      Fluttertoast.showToast(
        msg: 'Google sign-in failed: $e',
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      rethrow;
    }
  }

  bool _isValidName(String name) {
    return RegExp(r'^[a-zA-Z][a-zA-Z0-9]*$').hasMatch(name);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF181A20),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Image.asset(
                      'assets/logo.png',
                      width: 120,
                      height: 100,
                      color: const Color(0xFF6949FF),
                    ),
                  ),
                ),
                const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                    fontFamily: 'OpenSans',
                    shadows: [
                      Shadow(
                        color: Colors.black12,
                        offset: Offset(1, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.person,
                      color: Color(0xFF6949FF),
                    ),
                    labelText: 'Full Name',
                    labelStyle: const TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                      fontFamily: 'OpenSans',
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade700),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Color(0xFF6949FF),
                        width: 2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade700),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF424242),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.email,
                      color: Color(0xFF6949FF),
                    ),
                    labelText: 'Email Address',
                    labelStyle: const TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                      fontFamily: 'OpenSans',
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade700),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Color(0xFF6949FF),
                        width: 2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade700),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF424242),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.lock,
                      color: Color(0xFF6949FF),
                    ),
                    labelText: 'Password',
                    labelStyle: const TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                      fontFamily: 'OpenSans',
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade700),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Color(0xFF6949FF),
                        width: 2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade700),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF424242),
                  ),
                  style: const TextStyle(color: Colors.white),
                  obscureText: true,
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  hint: const Text(
                    'Select Role',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                      fontFamily: 'OpenSans',
                    ),
                  ),
                  items:
                      ['learner', 'instructor'].map((String role) {
                        return DropdownMenuItem<String>(
                          value: role,
                          child: Text(
                            role,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontFamily: 'OpenSans',
                            ),
                          ),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedRole = newValue;
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade700),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Color(0xFF6949FF),
                        width: 2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade700),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF424242),
                  ),
                  dropdownColor: const Color(0xFF424242),
                  iconEnabledColor: const Color(0xFF6949FF),
                ),
                if (authProvider.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      authProvider.errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ),
                const SizedBox(height: 25),
                ElevatedButton(
                  onPressed:
                      _isLoading || authProvider.isLoading
                          ? null
                          : () async {
                            if (_nameController.text.trim().isEmpty ||
                                _emailController.text.trim().isEmpty ||
                                _passwordController.text.trim().isEmpty) {
                              Fluttertoast.showToast(
                                msg: 'Please fill all fields',
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0,
                              );
                              return;
                            }
                            if (!_isValidName(_nameController.text.trim())) {
                              Fluttertoast.showToast(
                                msg:
                                    'Name must start with a letter and can only contain letters and numbers',
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0,
                              );
                              return;
                            }
                            if (_selectedRole == null) {
                              Fluttertoast.showToast(
                                msg: 'Please select a role',
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0,
                              );
                              return;
                            }
                            setState(() {
                              _isLoading = true;
                            });
                            try {
                              await authProvider.signup(
                                _emailController.text.trim(),
                                _passwordController.text.trim(),
                                _nameController.text.trim(),
                                _selectedRole!,
                              );
                              if (authProvider.user != null) {
                                Fluttertoast.showToast(
                                  msg: 'Signup successful!',
                                  backgroundColor: Colors.green,
                                  textColor: Colors.white,
                                  fontSize: 16.0,
                                );
                                Navigator.pushReplacementNamed(
                                  context,
                                  '/home',
                                );
                              }
                            } catch (e) {
                              setState(() {
                                _isLoading = false;
                              });
                              Fluttertoast.showToast(
                                msg:
                                    authProvider.errorMessage ??
                                    'Signup failed',
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0,
                              );
                            }
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6949FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    elevation: 6,
                    shadowColor: const Color(0xFF6949FF).withOpacity(0.4),
                    minimumSize: const Size(double.infinity, 0),
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : const Text(
                            'Sign Up',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'OpenSans',
                            ),
                          ),
                ),
                const SizedBox(height: 15),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Already have an account? Login',
                      style: TextStyle(
                        color: Color(0xFF6949FF),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'OpenSans',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
