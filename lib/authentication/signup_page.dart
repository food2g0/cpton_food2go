import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_storage/firebase_storage.dart' as fStorage;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../CustomersWidgets/custom_text_field.dart';
import '../CustomersWidgets/error_dialog.dart';
import '../CustomersWidgets/loading_dialog.dart';
import '../global/global.dart';
import '../mainScreen/home_screen.dart';
import '../theme/colors.dart';
import 'auth_screen.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController otpController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  var verificationId = ''.obs;

  XFile? imageXFile;
  final ImagePicker _picker = ImagePicker();

  Position? position;
  List<Placemark>? placeMarks;

  String customerImageUrl = "";
  String completeAddress = "";

  Future<void> _getImage() async {
    imageXFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {});
  }

  getCurrentLocation() async {
    Position newPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    position = newPosition;

    placeMarks = await placemarkFromCoordinates(
      position!.latitude,
      position!.longitude,
    );

    Placemark pMark = placeMarks![0];

    completeAddress =
    '${pMark.subThoroughfare} ${pMark.thoroughfare}, ${pMark.subLocality} ${pMark.locality}, ${pMark.subAdministrativeArea}, ${pMark.administrativeArea} ${pMark.postalCode}, ${pMark.country}';

    locationController.text = completeAddress;
  }








  Future<void> formValidation() async {
    if (imageXFile == null) {
      showDialog(
        context: context,
        builder: (c) {
          return const ErrorDialog(
            message: "Please select an image.",
          );
        },
      );
    } else {
      if (passwordController.text == confirmPasswordController.text) {
        if (confirmPasswordController.text.isNotEmpty &&
            emailController.text.isNotEmpty &&
            nameController.text.isNotEmpty &&
            phoneController.text.isNotEmpty &&
            locationController.text.isNotEmpty) {
          showDialog(
            context: context,
            builder: (c) {
              return const LoadingDialog(
                message: "Registering Account",
              );
            },
          );

          String fileName = DateTime.now().millisecondsSinceEpoch.toString();
          fStorage.Reference reference = fStorage.FirebaseStorage.instance
              .ref()
              .child("customer")
              .child(fileName);
          fStorage.UploadTask uploadTask =
          reference.putFile(File(imageXFile!.path));
          fStorage.TaskSnapshot taskSnapshot =
          await uploadTask.whenComplete(() {});

          try {
            customerImageUrl = await taskSnapshot.ref.getDownloadURL();
            authenticateSellerAndSignUp();
          } catch (error) {
            Navigator.pop(context);
            showDialog(
              context: context,
              builder: (c) {
                return ErrorDialog(
                  message: "Error uploading image: $error",
                );
              },
            );
          }
        } else {
          showDialog(
            context: context,
            builder: (c) {
              return const ErrorDialog(
                message: "Please write the complete required info for Registration.",
              );
            },
          );
        }
      } else {
        showDialog(
          context: context,
          builder: (c) {
            return const ErrorDialog(
              message: "Password do not match.",
            );
          },
        );
      }
    }
  }

  void authenticateSellerAndSignUp() async {
    User? currentUser;

    await _auth
        .createUserWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    )
        .then((auth) async {
      currentUser = auth.user;
      if (currentUser != null) {
        // Send email verification
        await currentUser!.sendEmailVerification();
      }
    }).catchError((error) {
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (c) {
            return ErrorDialog(
              message: error.message.toString(),
            );
          });
    });

    if (currentUser != null) {
      saveDataToFirestore(currentUser!).then((value) async {
        Navigator.pop(context);
        // Check if email is verified before navigating
        await currentUser!.reload(); // Refresh user data
        if (currentUser!.emailVerified) {
          // Navigate to home screen if email is verified
          Route newRoute = MaterialPageRoute(builder: (c) => HomeScreen());
          Navigator.pushReplacement(context, newRoute);
        } else {
          // Navigate to authentication screen if email is not verified
          Route newRoute = MaterialPageRoute(builder: (c) => AuthScreen());
          Navigator.pushReplacement(context, newRoute);
          // Show dialog to prompt user to check their email for verification
          showDialog(
              context: context,
              builder: (c) {
                return AlertDialog(
                  title: Text('Email Not Verified'),
                  content: Text(
                      'Please check your email to verify your account.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('OK'),
                    ),
                  ],
                );
              });
        }
      });
    }
  }




  Future saveDataToFirestore(User currentUser) async {
    FirebaseFirestore.instance.collection("users").doc(currentUser.uid).set({
      "customersUID": currentUser.uid,
      "customersEmail": currentUser.email,
      "customersName": nameController.text.trim(),
      "customerImageUrl": customerImageUrl,
      "phone": phoneController.text.trim(),
      "address": completeAddress,
      "status": "approved",
      "earnings": 0.0,
      "lat": position?.latitude ?? 0.0,
      "lng": position?.longitude ?? 0.0,
    });

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString("phone", phoneController.text);
    sharedPreferences.setString("uid", currentUser.uid);
    sharedPreferences.setString("address", completeAddress);
    sharedPreferences.setString("lat", (position?.latitude ?? 0.0).toString());
    sharedPreferences.setString("email", currentUser.email.toString());
    sharedPreferences.setString("name", nameController.text.trim());
    sharedPreferences.setString("customerImageUrl", customerImageUrl);
  }


  @override
  Widget build(BuildContext context) {
    List images = ["google.png", "facebook.png", "twitter.png"];

    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: AppColors().white,
      body: SingleChildScrollView(
        // Wrap with SingleChildScrollView
        child: Column(
          children: [
            Container(
              width: w,
              height: h * 0.4,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("images/log.png"),
                    fit: BoxFit.cover,
                  )),
            ),
            Container(

              margin: const EdgeInsets.only(left: 20, right: 20),
              width: w,
              child: const Column(

                crossAxisAlignment: CrossAxisAlignment.start,
                children: [],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                const SizedBox(
                  height: 10,
                ),
                InkWell(
                  onTap: () {
                    _getImage();
                  },
                  child: CircleAvatar(
                    radius: MediaQuery.of(context).size.width * 0.10,
                    backgroundColor: Colors.black87,
                    backgroundImage: imageXFile == null
                        ? null
                        : FileImage(File(imageXFile!.path)),
                    child: imageXFile == null
                        ? Icon(
                      Icons.add_photo_alternate,
                      size: MediaQuery.of(context).size.width * 0.10,
                      color: Colors.grey,
                    )
                        : null,
                  ),

                ),
                SizedBox(height: 10.h),
                Text("Choose your profile",
                  style: TextStyle(
                      color: AppColors().black,
                      fontFamily: "Poppins",
                      fontSize: 12.sp
                  ),),
                SizedBox(height: 20.h),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomTextField(
                        controller: nameController,
                        data: Icons.person,
                        hintText: "Enter your Full Name",
                        isObscure: false,
                      ),
                      SizedBox(height: 10.h),
                      CustomTextField(
                        controller: emailController,
                        data: Icons.email,
                        hintText: "Enter your Email",
                        isObscure: false,
                      ),
                      SizedBox(height: 10.h),
                      CustomTextField(
                        controller: phoneController,
                        data: Icons.phone_android,
                        hintText: "Enter your Phone Number",
                        isObscure: false,
                      ),
                      SizedBox(height: 10.h),
                      CustomTextField(
                        controller: passwordController,
                        data: Icons.password,
                        hintText: "Enter your Password",
                        isObscure: true,
                      ),
                      SizedBox(height: 10.h),
                      CustomTextField(
                        controller: confirmPasswordController,
                        data: Icons.password_rounded,
                        hintText: "Confirm your Password",
                        isObscure: true,
                      ),
                      SizedBox(height: 10.h),
                      CustomTextField(
                        controller: locationController,
                        data: Icons.location_city,
                        hintText: "Enter your Address",
                        isObscure: false,
                        enabled: true,
                      ),
                      SizedBox(height: 10.h),
                      Container(
                          width: 400.w,
                          height: 40.h,
                          alignment: Alignment.center,
                          child: ElevatedButton.icon(
                            label:  Text(
                              ("Get my current location")
                              ,
                              style: TextStyle(color: AppColors().white,
                                  fontFamily: "Poppins",
                                  fontSize: 12.sp),
                            ),
                            icon: Icon(
                              Icons.location_on,
                              color: AppColors().black,
                            ),
                            onPressed: () {
                              getCurrentLocation();
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors().black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                )),
                          ))
                    ],
                  ),
                ),
                SizedBox(height: w * 0.08),
                SizedBox(
                  width: 150, // Set the desired width
                  child: ElevatedButton(
                    onPressed: () {
                      // signUp();
                      formValidation();
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.w)
                      ),
                      backgroundColor: AppColors().red,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child:  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Sign Up",
                          style: TextStyle(
                              color: AppColors().white,
                              fontFamily: "Poppins",
                              fontWeight: FontWeight.w600),
                        ),

                      ],
                    ),

                  ),

                ),
                SizedBox(height: 20.h,)
              ],
            ),
          ],
        ),
      ),
    );
  }
}