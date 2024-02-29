import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../authentication/auth_screen.dart';
import '../global/global.dart';
import '../mainScreen/home_screen.dart';




class MySplashScreen extends StatefulWidget {
  const MySplashScreen({super.key});

  @override
  State<MySplashScreen> createState() => _MySplashScreenState();
}




class _MySplashScreenState extends State<MySplashScreen> {
  bool _isNavigated = false;

  startTimer() {
    Timer(const Duration(seconds: 4), () async {
      if (!_isNavigated) {
        // Check if firebaseAuth is not null and currentUser is not null
        if (firebaseAuth != null && firebaseAuth.currentUser != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (c) => const HomeScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (c) => const AuthScreen()),
          );
        }
        _isNavigated = true; // Set flag to true after navigating away
      }
    });
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              "images/onboard.svg",
              height: 300,
            ),
            SizedBox(height: 20),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: "Welcome to ",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: "Food2Go",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// class _MySplashScreenState extends State<MySplashScreen> {
//   bool _isNavigated = false;
//
//   startTimer() {
//     Timer(const Duration(seconds: 4), () async {
//       if (!_isNavigated) {
//         // Check if firebaseAuth is not null and currentUser is not null
//         if (firebaseAuth != null && firebaseAuth.currentUser != null) {
//           // Check if phone number is validated
//           if (isPhoneNumberValidated) {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (c) => const HomeScreen()),
//             );
//           } else {
//             // If phone number is not validated, navigate to AuthScreen
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (c) => const AuthScreen()),
//             );
//           }
//         } else {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (c) => const AuthScreen()),
//           );
//         }
//         _isNavigated = true; // Set flag to true after navigating away
//       }
//     });
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     startTimer();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             SvgPicture.asset(
//               "images/onboard.svg",
//               height: 300,
//             ),
//             SizedBox(height: 20),
//             Text.rich(
//               TextSpan(
//                 children: [
//                   TextSpan(
//                     text: "Welcome to ",
//                     style: TextStyle(
//                       fontSize: 18.sp,
//                       fontFamily: "Poppins",
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   TextSpan(
//                     text: "Food2Go",
//                     style: TextStyle(
//                       fontSize: 18.sp,
//                       fontFamily: "Poppins",
//                       fontWeight: FontWeight.w600,
//                       color: Colors.red,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


