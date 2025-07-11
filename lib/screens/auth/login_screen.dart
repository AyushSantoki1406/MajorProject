import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/providers/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth_provider;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('remember_me') ?? false) {
      setState(() {
        _emailController.text = prefs.getString('email') ?? '';
        _passwordController.text = prefs.getString('password') ?? '';
        _rememberMe = true;
      });
    }
  }

  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('email', _emailController.text.trim());
      await prefs.setString('password', _passwordController.text.trim());
      await prefs.setBool('remember_me', true);
    } else {
      await prefs.remove('email');
      await prefs.remove('password');
      await prefs.setBool('remember_me', false);
    }
  }

  @override
  void dispose() {
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
                  'Welcome Back',
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (value) {
                            setState(() {
                              _rememberMe = value!;
                            });
                          },
                          activeColor: const Color(0xFF6949FF),
                          checkColor: Colors.white,
                          fillColor: MaterialStateProperty.all(
                            const Color(0xFF424242),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const Text(
                          'Remember Me',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontFamily: 'OpenSans',
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/forgot_password');
                      },
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Color(0xFF6949FF),
                          fontSize: 14,
                          fontFamily: 'OpenSans',
                        ),
                      ),
                    ),
                  ],
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
                            if (_emailController.text.trim().isEmpty ||
                                _passwordController.text.trim().isEmpty) {
                              Fluttertoast.showToast(
                                msg: 'Please enter email and password',
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
                              final userCredential =
                                  await firebase_auth_provider
                                      .FirebaseAuth
                                      .instance
                                      .signInWithEmailAndPassword(
                                        email: _emailController.text.trim(),
                                        password:
                                            _passwordController.text.trim(),
                                      );

                              if (userCredential.user != null) {
                                await _saveCredentials();
                                Fluttertoast.showToast(
                                  msg: 'Login successful!',
                                  backgroundColor: Colors.green,
                                  textColor: Colors.white,
                                  fontSize: 16.0,
                                );
                                print(
                                  '✅ Logged in: ${userCredential.user!.email}',
                                );
                                Navigator.pushReplacementNamed(
                                  context,
                                  '/home',
                                );
                              }
                            } on firebase_auth_provider.FirebaseAuthException catch (
                              e
                            ) {
                              setState(() {
                                _emailController.clear();
                                _passwordController.clear();
                                _isLoading = false;
                              });

                              if (e.code == 'wrong-password' ||
                                  e.code == 'user-not-found' ||
                                  e.code == 'invalid-credential') {
                                print('❌ Firebase login failed: ${e.code}');
                                Fluttertoast.showToast(
                                  msg: 'Invalid email or password',
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 16.0,
                                );
                              } else {
                                print('❌ Other FirebaseAuth error: ${e.code}');
                                Fluttertoast.showToast(
                                  msg: e.message ?? 'Login failed',
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 16.0,
                                );
                              }
                            } catch (e) {
                              setState(() {
                                _isLoading = false;
                              });
                              print('❌ Unexpected login error: $e');
                              Fluttertoast.showToast(
                                msg: 'Login failed. Please try again.',
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
                            'Login',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'OpenSans',
                            ),
                          ),
                ),
                const SizedBox(height: 15),
                // SizedBox(
                //   width: double.infinity,
                //   child: ElevatedButton.icon(
                //     onPressed:
                //         _isLoading || authProvider.isLoading
                //             ? null
                //             : () async {
                //               try {
                //                 final userCredential = await signInWithGoogle();
                //                 final user = userCredential.user;
                //                 if (user != null && user.email != null) {
                //                   await _saveCredentials();
                //                   Fluttertoast.showToast(
                //                     msg:
                //                         'Google login successful! Email: ${user.email}',
                //                     backgroundColor: Colors.green,
                //                     textColor: Colors.white,
                //                     fontSize: 16.0,
                //                   );
                //                   Navigator.pushReplacementNamed(
                //                     context,
                //                     '/home',
                //                   );
                //                 }
                //               } catch (e) {
                //                 // Error handled in signInWithGoogle
                //               } finally {
                //                 setState(() {
                //                   _isLoading = false;
                //                 });
                //               }
                //             },
                //     icon: const Icon(
                //       Icons.g_mobiledata,
                //       color: Color.fromARGB(255, 0, 0, 0),
                //     ),
                //     label: const Text(
                //       'Sign in with Google',
                //       style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                //     ),
                //     style: ElevatedButton.styleFrom(
                //       backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(8),
                //       ),
                //       padding: const EdgeInsets.symmetric(vertical: 14),
                //     ),
                //   ),
                // ),
                const SizedBox(height: 15),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignupScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Create an Account',
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
