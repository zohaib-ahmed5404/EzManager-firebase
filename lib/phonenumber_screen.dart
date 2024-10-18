import 'package:flutter/material.dart';

import 'otp_screen.dart';

class PhoneNumberScreen extends StatefulWidget {
  const PhoneNumberScreen({super.key});

  @override
  PhoneNumberScreenState createState() => PhoneNumberScreenState();
}

class PhoneNumberScreenState extends State<PhoneNumberScreen> {
  final TextEditingController _phoneNumberController = TextEditingController();
  bool _isLoading = false;

  Future<void> _sendOTP() async {
    setState(() {
      _isLoading = true;
    });

    // Simulating OTP send request
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;
    
    // Navigate to OTPScreen after sending OTP (replace with actual navigation)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OTPScreen(phoneNumber: _phoneNumberController.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Phone Number Verification'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF757575),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Enter your phone number',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'We will send an OTP to this number',
                style: TextStyle(color: Color(0xFF757575)),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _phoneNumberController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Enter phone number',
                  hintStyle: const TextStyle(color: Color(0xFF757575)),
                  border: authOutlineInputBorder,
                  enabledBorder: authOutlineInputBorder,
                  focusedBorder: authOutlineInputBorder.copyWith(
                    borderSide: const BorderSide(color: Color(0xFFFF7643)),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                style: const TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _sendOTP,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: const Color(0xFFFF7643),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                        ),
                      ),
                      child: const Text('Send OTP'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
