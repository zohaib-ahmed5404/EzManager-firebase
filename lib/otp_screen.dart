import 'package:flutter/material.dart';

class OTPScreen extends StatefulWidget {
  final String phoneNumber;

  const OTPScreen({super.key, required this.phoneNumber});

  @override
  OTPScreenState createState() => OTPScreenState();
}

class OTPScreenState extends State<OTPScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;

  Future<void> _verifyOTP() async {
    setState(() {
      _isLoading = true;
    });

    // Simulating a network request
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('OTP Verified!')),
    );

    // Navigate to HomeScreen (replace with actual navigation)
    // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('OTP Verification'),
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
                'Enter the OTP',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'We have sent an OTP to your number',
                style: TextStyle(color: Color(0xFF757575)),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter OTP',
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
          ),
        ),
      ),
    );
  }
}

const authOutlineInputBorder = OutlineInputBorder(
  borderSide: BorderSide(color: Color(0xFF757575)),
  borderRadius: BorderRadius.all(Radius.circular(12)),
);
