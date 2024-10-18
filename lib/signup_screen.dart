import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For phone number input format
import 'package:flutter_verification_code/flutter_verification_code.dart'; // For OTP input
import 'package:google_sign_in/google_sign_in.dart';

import 'home_screen.dart'; // Import HomeScreen

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  SignupScreenState createState() => SignupScreenState();
}

class SignupScreenState extends State<SignupScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  String? _verificationId;
  bool _isOTPMode = false; // To switch between OTP and normal signup mode
  String _smsCode = '';


  // Phone number verification
  Future<void> _verifyPhoneNumber() async {
    setState(() {
      _isLoading = true;
    });

    await _auth.verifyPhoneNumber(
      phoneNumber: _phoneNumberController.text.trim(),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        setState(() {
          _isLoading = false;
          _isOTPMode = false; // Reset OTP mode if verification completed
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Phone number verified successfully!')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      },
      verificationFailed: (FirebaseAuthException e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification failed. ${e.message}')),
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
          _isOTPMode = true; // Switch to OTP input mode
          _isLoading = false;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() {
          _verificationId = verificationId;
          _isLoading = false;
        });
      },
    );
  }

  Future<void> _verifyOTP() async {
    setState(() {
      _isLoading = true;
    });

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _smsCode,
      );

      await _auth.signInWithCredential(credential);
      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number verified successfully!')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to verify OTP. Please try again.')),
      );
    }
  }

  Future<void> _googleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // User cancelled the sign-in

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Signup',
          style: TextStyle(color: Color(0xFF757575)),
        ),
      ),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'Create an Account',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _usernameController,
                    hintText: 'Username',
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    controller: _emailController,
                    hintText: 'Email',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    controller: _passwordController,
                    hintText: 'Password',
                    obscureText: true,
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    controller: _confirmPasswordController,
                    hintText: 'Confirm Password',
                    obscureText: true,
                  ),
                  const SizedBox(height: 10),
                  // Phone Number Field
                  _buildTextField(
                    controller: _phoneNumberController,
                    hintText: 'Phone Number (e.g. +92 300 1234567)',
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 20),
                  // Show either OTP input or Phone Verification button
                  _isOTPMode
                      ? Column(
                          children: [
                            VerificationCode(
                              length: 6,
                              onCompleted: (String value) {
                                setState(() {
                                  _smsCode = value;
                                });
                              },
                              onEditing: (bool value) {},
                            ),
                            const SizedBox(height: 20),
                            _isLoading
                                ? const CircularProgressIndicator()
                                : ElevatedButton(
                                    onPressed: _verifyOTP,
                                    style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      backgroundColor: const Color(0xFFFF7643),
                                      foregroundColor: Colors.white,
                                      minimumSize: const Size(double.infinity, 48),
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(16)),
                                      ),
                                    ),
                                    child: const Text('Verify OTP'),
                                  ),
                          ],
                        )
                      : ElevatedButton(
                          onPressed: _verifyPhoneNumber,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: const Color(0xFFFF7643),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 48),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(16)),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Send OTP'),
                        ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _googleSignIn,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFFF7643),
                      minimumSize: const Size(double.infinity, 48),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                    ),
                    child: const Text('Sign up with Google'),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFFF7643)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFFF7643)),
        ),
      ),
    );
  }
}
