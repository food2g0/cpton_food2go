import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_foodtogo/authentication/Forgot_Password.dart';
import 'package:cpton_foodtogo/authentication/signup_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../CustomersWidgets/custom_text_field.dart';
import '../CustomersWidgets/error_dialog.dart';
import '../CustomersWidgets/loading_dialog.dart';
import '../global/global.dart';
import '../mainScreen/home_screen.dart';
import '../theme/colors.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool agreedToTerms = false; // Track whether the user has agreed to the terms
  bool isPasswordVisible = false;

  formValidation() {
    if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
      //login
      loginNow();
    } else {
      showDialog(
        context: context,
        builder: (c) {
          return const ErrorDialog(message: "Please write Email and password.");
        },
      );
    }
  }

  loginNow() async {
    showDialog(
      context: context,
      builder: (c) {
        return const LoadingDialog(message: "Checking credentials");
      },
    );

    User? currentUser;
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    )
        .then((auth) {
      currentUser = auth.user!;
    }).catchError((error) {
      Navigator.pop(context);

      showDialog(
        context: context,
        builder: (c) {
          return ErrorDialog(
            message: error.message.toString(),
          );
        },
      );
    });

    if (currentUser != null) {
      await currentUser!.reload(); // Refresh user data
      if (currentUser!.emailVerified) {
        readDataAndSetDataLocally(currentUser!);
      } else {
        // User's email is not verified
        Navigator.pop(context); // Close loading dialog
        showDialog(
          context: context,
          builder: (c) {
            return AlertDialog(
              title: const Text('Email Not Verified'),
              content: const Text('Please verify your email to log in.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(c).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  Future readDataAndSetDataLocally(User currentUser) async {
    await FirebaseFirestore.instance.collection("users").doc(currentUser.uid).get().then((snapshot) async {
      if (snapshot.exists) {
        await sharedPreferences!.setString("uid", currentUser.uid);
        await sharedPreferences!.setString("email", snapshot.data()!["customersEmail"]);
        await sharedPreferences!.setString("name", snapshot.data()!["customersName"]);

        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (c) => HomeScreen()));
      } else {
        FirebaseAuth.instance.signOut();
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (c) => const AuthScreen()));

        showDialog(
          context: context,
          builder: (c) {
            return const ErrorDialog(
              message: "no record exists.",
            );
          },
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors().white,
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              width: w,
              height: h * 0.4,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("images/log.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  CustomTextField(
                    data: Icons.email,
                    hintText: "Enter your Email",
                    hintStyle: TextStyle(
                      color: AppColors().black1,
                      fontFamily: "Poppins",
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    inputTextStyle: TextStyle(
                      fontFamily: "Poppins",
                      color: AppColors().black,
                      fontSize: 12.sp,
                    ),
                    isObscure: false,
                    controller: emailController,
                  ),
                  CustomTextField(
                    data: Icons.password,
                    hintText: "Enter your Password",
                    hintStyle: TextStyle(
                      color: AppColors().black1,
                      fontFamily: "Poppins",
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    inputTextStyle: TextStyle(
                      fontFamily: "Poppins",
                      color: AppColors().black,
                      fontSize: 12.sp,
                    ),
                    isObscure: !isPasswordVisible, // Pass the opposite of isPasswordVisible to control password visibility
                    controller: passwordController,
                    suffixIcon: IconButton( // Add suffixIcon property
                      onPressed: () {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible; // Toggle the visibility
                        });
                      },
                      icon: Icon(
                        isPasswordVisible ? Icons.visibility : Icons.visibility_off, // Show different icon based on password visibility
                        color: Colors.grey,
                      ),
                    ),
                  ),


                  Row(
                    children: [
                      Checkbox(
                        value: agreedToTerms,
                        onChanged: (value) {
                          setState(() {
                            agreedToTerms = value!;
                          });
                        },
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text("Terms and Conditions", style: TextStyle(
                                    fontFamily: "Poppins",
                                    fontSize: 8.sp,
                                    fontWeight: FontWeight.bold

                                  ),),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "1. We regret to inform you that order cancellation is not supported at this time.",
                                          style: TextStyle(fontFamily: "Poppins",
                                              fontSize: 8.sp),
                                        ),
                                        SizedBox(height: 5,),
                                        Text(
                                            "2. By placing an order, you agree to pay for the items ordered. ", style: TextStyle(fontFamily: "Poppins",
                                        fontSize: 8.sp),),
                                        SizedBox(height: 5,),
                                        Text(
                                          "3. Non-payment for orders may result in suspension or termination of your account", style: TextStyle(fontFamily: "Poppins",
                                            fontSize: 8.sp),),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("Close"),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Text(
                            "I agree to the Terms and Conditions",
                            style: TextStyle(
                              color: AppColors().black,
                              fontFamily: "Poppins",
                              fontSize: 10.sp,
                            ),
                          ),

                        ),

                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: RichText(
                  text: TextSpan(
                    text: "Forgot Password?",
                    style: TextStyle(
                      color: AppColors().black,
                      fontFamily: "Poppins",
                      fontSize: 12.sp,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => Get.to(() => const ForgotPassword()),
                  ),
                ),
              ),
            ),

            SizedBox(height: w * 0.08),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors().red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.w),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              onPressed: () {
                if (!agreedToTerms) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("Error"),
                        content: Text("Please agree to the Terms and Conditions to proceed."),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text("OK"),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  formValidation();
                }
              },
              child: Text(
                "Login",
                style: TextStyle(
                  fontFamily: "Poppins",
                  color: AppColors().white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: w * 0.08),
            RichText(
              text: TextSpan(
                text: "Don't have an account?",
                style: TextStyle(
                  color: AppColors().black1,
                  fontFamily: "Poppins",
                  fontSize: 15.sp,
                ),
                children: [
                  TextSpan(
                    text: "  Create!",
                    style: TextStyle(
                      fontFamily: "Poppins",
                      color: AppColors().black,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => Get.to(() => const SignUpPage()),
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
