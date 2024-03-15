import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smooth_star_rating_null_safety/smooth_star_rating_null_safety.dart';
import '../theme/colors.dart';

class OrderRatingsScreen extends StatefulWidget {
  final String productId;

  const OrderRatingsScreen({Key? key, required this.productId}) : super(key: key);

  @override
  _OrderRatingsScreenState createState() => _OrderRatingsScreenState();
}

class _OrderRatingsScreenState extends State<OrderRatingsScreen> {
  double calculateAverageRating(List<DocumentSnapshot> documents) {
    double totalRating = 0;
    for (var document in documents) {
      totalRating += (document['rating'] as num).toDouble();
    }
    return totalRating / documents.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors().red,
        title: Text(
          "Product Ratings",
          style: TextStyle(
            fontFamily: "Poppins",
            color: AppColors().white,
            fontSize: 12.sp,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildRatingSection(),
            SizedBox(height: 20.h),
            Text(
              "User Reviews",
              style: TextStyle(
                fontFamily: "Poppins",
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: AppColors().black,
              ),
            ),
            SizedBox(height: 10.h),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("items")
                  .doc(widget.productId)
                  .collection("itemRecord")
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                List<DocumentSnapshot> reviewDocuments = snapshot.data!.docs;
                if (reviewDocuments.isEmpty) {
                  return Center(child: Text("No reviews available."));
                }

                return Column(
                  children: reviewDocuments.map((reviewData) {
                    return buildReviewItem(reviewData);
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildReviewItem(DocumentSnapshot reviewData) {
    double rating = (reviewData['rating'] as num?)?.toDouble() ?? 0.0;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [

              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'User', // Replace 'User' with the actual user's name
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors().black1,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  SmoothStarRating(
                    rating: rating,
                    allowHalfRating: false,
                    starCount: 5,
                    size: 16.sp,
                    color: Colors.yellow,
                    borderColor: Colors.black45,
                  ),
                  Text(
                    'Comment: ${(reviewData['comment'] as String?) ?? ""}',
                    style: TextStyle(
                      fontFamily: "Poppins",
                      color: AppColors().black1,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Divider(), // Add a divider between review items
        ],
      ),
    );
  }


  Widget buildRatingSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("items")
          .doc(widget.productId)
          .collection("itemRecord")
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        double averageRating = calculateAverageRating(snapshot.data!.docs);

        // Conditionally render SmoothStarRating based on averageRating
        Widget starRatingWidget = averageRating > 0
            ? SmoothStarRating(
          rating: averageRating,
          allowHalfRating: true,
          starCount: 5,
          size: 25,
          color: Colors.yellow,
          borderColor: Colors.black45,
        )
            : SmoothStarRating(
          rating: 0,
          allowHalfRating: true,
          starCount: 5,
          size: 25,
          color: Colors.yellow,
          borderColor: Colors.black45,
        );

        return Row(
          children: [
            starRatingWidget,
            SizedBox(width: 5.w),
            Text(
              '${averageRating.toStringAsFixed(2)}/5.00',
              style: TextStyle(
                fontFamily: "Poppins",
                fontSize: 12.sp,
                color: AppColors().black1,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      },
    );
  }


}
