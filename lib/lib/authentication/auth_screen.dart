import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_foodtogo/lib/authentication/signup_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../CustomersWidgets/custom_text_field.dart';
import '../CustomersWidgets/error_dialog.dart';
import '../CustomersWidgets/loading_dialog.dart';
import '../global/global.dart';
import '../mainScreen/home_screen.dart';

class AuthScreen extends StatefulWidget {
    const AuthScreen({Key? key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();


}

class _AuthScreenState extends State<AuthScreen> {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();

  formValidation() {
    if (emailcontroller.text.isNotEmpty && passwordcontroller.text.isNotEmpty) {
      //login
      loginNow();
    }
    else {
      showDialog(context: context, builder: (c) {
        return const ErrorDialog(message: "Please write Email and password.",);
      }
      );
    }
  }

  loginNow()async
  {
    showDialog(context: context, builder: (c) {
      return const LoadingDialog(message: "Checking credentials",);
    }
    );

    User? currentUser;
    await firebaseAuth.signInWithEmailAndPassword(
      email: emailcontroller.text.trim(),
      password: passwordcontroller.text.trim(),
    ).then((auth)
    {
      currentUser = auth.user!;
    }).catchError((error) {
      Navigator.pop(context);

      showDialog(context: context, builder: (c) {
        return ErrorDialog(message: error.message.toString(),
        );
      }
      );
    });
    if (currentUser != null)
      {
          readDataAndSetDataLocally(currentUser!);
      }
  }

  Future readDataAndSetDataLocally(User currentUser) async
  {
    await FirebaseFirestore.instance.collection("users")
        .doc(currentUser.uid)
        .get()
        .then((snapshot)
    async {
          if(snapshot.exists)
          {
            await sharedPreferences!.setString("uid", currentUser.uid);
            await sharedPreferences!.setString("email", snapshot.data()!["customersEmail"]);
            await sharedPreferences!.setString("name", snapshot.data()!["customersName"]);

            List<String> userCartList = snapshot.data()!['userCart'].cast<String>();
            await sharedPreferences!.setStringList("userCart", userCartList );

            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (c)=> const HomeScreen()));

          }
          else
          {
            firebaseAuth.signOut();
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (c)=> const AuthScreen()));

            showDialog(
                context: context,
                builder: (c)
                {
                  return const ErrorDialog(
                    message: "no record exists.",
                  );
                }
            );

          }

    });
  }


  @override
  Widget build(BuildContext context) {
    double w = MediaQuery
        .of(context)
        .size
        .width;
    double h = MediaQuery
        .of(context)
        .size
        .height;

    return Scaffold(
      backgroundColor: Colors.grey,
      body: SingleChildScrollView( // Wrap with SingleChildScrollView
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
            Form(key: _formkey,
              child: Column(

                children: [
                  CustomTextField(
                    data: Icons.email,
                    hintText: "Enter your Email",
                    isObscure: false,
                    controller: emailcontroller,

                  ),
                  CustomTextField(
                    data: Icons.password,
                    hintText: "Enter your Password",
                    isObscure : true,
                    controller: passwordcontroller,

                  ),
                ],
              ),
            ),
            SizedBox(height: w * 0.08),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black45,
                padding: const EdgeInsets.symmetric(
                    horizontal: 50, vertical: 15),
              ),
              onPressed: () {
                formValidation();
                loginNow();
              },
              child: const Text("Login", style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.normal),
              ),
            ),


            SizedBox(height: w * 0.08),
            RichText(text: TextSpan(
                text: "Don\'t have an account?",
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15
                ),
                children: [
                  TextSpan(
                      text: "  Create!",
                      style: const TextStyle(
                          color: Colors.black,

                          fontSize: 16,
                          fontWeight: FontWeight.w600

                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => Get.to(() => const SignUpPage())
                  ),

                ]
            )),
          ],
        ),
      ),
    );
  }
}
