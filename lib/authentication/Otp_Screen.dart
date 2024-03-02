import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_foodtogo/mainScreen/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pinput/pinput.dart';

import '../theme/colors.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  OtpScreen(this.phone);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

final defaultPinTheme = PinTheme(
  width: 56,
  height: 56,
  textStyle: TextStyle(fontSize: 20, color: Color.fromRGBO(30, 60, 87, 1), fontWeight: FontWeight.w600),
  decoration: BoxDecoration(
    border: Border.all(color: Color.fromRGBO(234, 239, 243, 1)),
    borderRadius: BorderRadius.circular(20),
  ),
);

final focusedPinTheme = defaultPinTheme.copyDecorationWith(
  border: Border.all(color: Color.fromRGBO(114, 178, 238, 1)),
  borderRadius: BorderRadius.circular(8),
);

final submittedPinTheme = defaultPinTheme.copyWith(
  decoration: defaultPinTheme.decoration?.copyWith(
    color: Color.fromRGBO(234, 239, 243, 1),
  ),
);

class _OtpScreenState extends State<OtpScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late String _verificationCode;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _otpController = TextEditingController(); // Controller for OTP input field
  bool _isLoading = false; // Flag to track loading state
  int _resendCounter = 60;
  late Timer _resendTimer;

  @override
  void initState() {
    super.initState();
    _verifyPhone();
    _startResendTimer();
  }

  @override
  void dispose() {
    _resendTimer.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _resendTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendCounter > 0) {
          _resendCounter--;
        } else {
          _resendTimer.cancel(); // Stop the timer when counter reaches 0
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: AppColors().red,
        title: Text(
          "OTP Verification",
          style: TextStyle(
            color: AppColors().white,
            fontFamily: "Poppins",
            fontSize: 12.sp,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              child: Center(
                child: Text(
                  "verify +63${widget.phone}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors().black,
                    fontSize: 12.sp,
                    fontFamily: "Poppins",
                  ),
                ),
              ),
            ),
          ),
          Pinput(
            length: 6,
            defaultPinTheme: defaultPinTheme,
            focusedPinTheme: focusedPinTheme,
            submittedPinTheme: submittedPinTheme,
            controller: _otpController, // Assigning controller to OTP input field
            pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
            showCursor: true,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isLoading ? null : _submitOTP, // Disable button when loading
            child: _isLoading ? CircularProgressIndicator() : Text('Submit OTP'),
          ),
          SizedBox(height: 10),
          _resendCounter > 0
              ? Text("Resend OTP in $_resendCounter seconds")
              : ElevatedButton(
            onPressed: _resendCounter == 0 ? _resendOTP : null,
            child: Text('Resend OTP'),
          ),
        ],
      ),
    );
  }

  // Function to submit OTP
  void _submitOTP() async {
    // Validate OTP
    if (_otpController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter OTP")),
      );
      return;
    }

    try {
      setState(() {
        _isLoading = true; // Set loading state to true
      });
      await FirebaseAuth.instance.signInWithCredential(
        PhoneAuthProvider.credential(
          verificationId: _verificationCode,
          smsCode: _otpController.text,
        ),
      );
      // OTP verification successful, navigate to home screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (c) => HomeScreen()),
      );
    } catch (e) {
      // OTP verification failed, show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid OTP")),
      );
    } finally {
      setState(() {
        _isLoading = false; // Set loading state to false
      });
    }
  }

  // Function to resend OTP
  void _resendOTP() async {
    setState(() {
      _resendCounter = 60; // Reset the counter
    });
    _startResendTimer(); // Start the timer again
    // Implement OTP resend logic here
    // For example, you can call the _verifyPhone method again to resend OTP
    _verifyPhone();
  }

  _verifyPhone() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+63${widget.phone}',
      verificationCompleted: (PhoneAuthCredential credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential).then((value) async {
          if (value.user != null) {
            print('user Logged In');
          }
        });
      },
      verificationFailed: (FirebaseException e) {
        print(e.message);
      },
      codeSent: (String verificationID, int? resendToken) {
        setState(() {
          _verificationCode = verificationID;
        });
      },
      codeAutoRetrievalTimeout: (String verificationID) {
        setState(() {
          _verificationCode = verificationID;
        });
      },
      timeout: Duration(seconds: 60),
    );
  }
}