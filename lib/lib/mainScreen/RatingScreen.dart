import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_foodtogo/lib/global/global.dart';
import 'package:cpton_foodtogo/lib/mainScreen/home_screen.dart';
import 'package:cpton_foodtogo/lib/theme/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smooth_star_rating_null_safety/smooth_star_rating_null_safety.dart';

class RatingScreen extends StatefulWidget {
  String? riderUID;
  String? productsID;
  String? sellerUID;
  String? orderID;

  RatingScreen({
    this.orderID,
    this.productsID,
    this.riderUID,
    this.sellerUID,
  });

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  TextEditingController commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors().red,
        title: Text(
          "Rate your Order Experience",
          style: TextStyle(
            fontSize: 12.sp,
            fontFamily: "Poppins",
            color: AppColors().white,
          ),
        ),
      ),
      backgroundColor: Colors.grey,
      body: Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Rate your Rider",
              style: TextStyle(
                fontSize: 16.sp,
                fontFamily: "Poppins",
                fontWeight: FontWeight.w600,
                color: AppColors().black,
              ),
            ),
            SizedBox(height: 20.h,),

            Divider(height: 4.0, thickness: 2,),

            SmoothStarRating(
              rating: countRatingStars,
              allowHalfRating: false,
              starCount: 5,
              size: 30.sp,
              color: AppColors().yellow,
              borderColor: AppColors().black,
              onRatingChanged: (valueOfStarsChoice) {
                countRatingStars = valueOfStarsChoice;

                if (countRatingStars == 1) {
                  setState(() {
                    titleStarRatings = "very Bad";
                  });
                }
                if (countRatingStars == 2) {
                  setState(() {
                    titleStarRatings = "Bad";
                  });
                }
                if (countRatingStars == 3) {
                  setState(() {
                    titleStarRatings = "Good";
                  });
                }
                if (countRatingStars == 4) {
                  setState(() {
                    titleStarRatings = "very Good";
                  });
                }
                if (countRatingStars == 5) {
                  setState(() {
                    titleStarRatings = "Excellent";
                  });
                }
              },
            ),
            SizedBox(height: 12.h,),
            Text(
              titleStarRatings,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: Colors.grey,
                fontFamily: "Poppins",
              ),
            ),
            SizedBox(height: 18.h,),

            Container(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.w),
                child: Container(
                  height: 90.h,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors().red, width: 1.0),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: TextField(
                    controller: commentController,
                    maxLines: 3,
                    maxLength: 200,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 20.h), // Add padding here
                      hintText: 'Add your comment...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ),


            SizedBox(height: 18.h,),

            ElevatedButton(
              onPressed: () {
                submitRating();
                confirmParcelHasBeenDelivered();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors().green,
              ),
              child: Text(
                "Submit",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors().white,
                  fontFamily: "Poppins",
                ),
              ),
            ),
            SizedBox(height: 18.h,),
          ],
        ),
      ),
    );
  }

  void submitRating() async {
    try {
      await FirebaseFirestore.instance.collection("riders").doc(widget.riderUID).collection("ridersRecord").add({
        "productsID": widget.productsID,
        "sellerUID": widget.sellerUID,
        "rating": countRatingStars,
        "comment": commentController.text,
        // Add other fields as needed
      });

      // Handle success, for example, show a success message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Success"),
            content: Text("Rating and comment submitted successfully."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(MaterialPageRoute(builder: (c)=> HomeScreen()));

                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    } catch (e) {
      // Handle errors, for example, show an error message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text("Failed to submit rating and comment. Please try again."),
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
    }
  }
  confirmParcelHasBeenDelivered() {
    String? customerUID = FirebaseAuth.instance.currentUser?.uid;

    if (customerUID != null) {
      FirebaseFirestore.instance
          .collection("orders")
          .doc(widget.orderID)
          .update({
        "status": "rated",
      }).then((value) {
        FirebaseFirestore.instance
            .collection("users")
            .doc(customerUID)
            .collection("orders")
            .doc(widget.orderID)
            .update({
          "status": "rated",
          "riderUID": sharedPreferences!.getString("uid"),
        });
      });
    } else {
      // Handle the case where the current user ID is null
      print("Current user ID is null");
    }
  }

  }
