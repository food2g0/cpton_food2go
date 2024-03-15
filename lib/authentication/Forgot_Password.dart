import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_foodtogo/theme/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  @override
  void dispose(){
    super.dispose();
    emailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors().red,
        title: Text("Forgot Password",
        style: TextStyle(
          fontFamily: "Poppins",
          color: AppColors().white,
          fontSize: 12.sp
        ),),
      ),
      body: Padding(padding: EdgeInsets.all(16),
      child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Enter email to\nreset password.",textAlign:
                TextAlign.center,
              style: TextStyle(color: AppColors().black,
              fontFamily: "Poppins"),),
              SizedBox(height: 20.h,),
              TextFormField(
                controller: emailController,
                cursorColor: AppColors().black,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: "Email",
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                // validator: (email)=>
                // email != null && !EmailValidator.validate(email)
                // ? 'Enter Valid Email'
                // : null,
                
              ),

              SizedBox(height: 20.h,),
              ElevatedButton.icon(onPressed: (){
                resetPassword();
              },
                style: ElevatedButton.styleFrom(
                backgroundColor: AppColors().red,
                  shape: RoundedRectangleBorder(borderRadius: 
                  BorderRadius.circular(10)),
                  minimumSize: Size.fromHeight(50)
                ),
                icon: Icon(Icons.email_outlined,
                color: AppColors().white,),
                label: Text("Reset Password",style:
                  TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 12.sp,
                    color: AppColors().white
                  ),),
                   )
            ],
          )
      ),

      ),
    );


  }
  Future<void> resetPassword() async {
    showDialog(
      context: context,
      builder: (context) => Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Check if the email exists in the user collection
      var userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('customersEmail', isEqualTo: emailController.text.trim())
          .get();

      // If no user found with the given email
      if (userSnapshot.docs.isEmpty) {
        Navigator.of(context).pop(); // Close the loading dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Email Not Found'),
            content: Text('The entered email does not exist.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
        return; // Exit the method
      }

      // If email exists, send the password reset email
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );

      // Show toast message for success
      Fluttertoast.showToast(
        msg: 'Reset link sent successfully',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      Navigator.of(context).popUntil((route) => route.isActive);
    } on FirebaseAuthException catch (e) {
      print(e);
      Navigator.of(context).pop(); // Close the loading dialog

      // Handle any errors here if needed
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to reset password. Please try again later.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

}
