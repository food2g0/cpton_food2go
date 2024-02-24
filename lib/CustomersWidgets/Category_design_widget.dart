import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:smooth_star_rating_null_safety/smooth_star_rating_null_safety.dart';

import '../assistantMethods/assistant_methods.dart';
import '../mainScreen/item_details_screen.dart';
import '../theme/colors.dart';



class CategoryDesignWidget extends StatefulWidget {
  final dynamic model;
  final BuildContext? context;
  final sellersUID;
  final double? distanceInKm;

  const CategoryDesignWidget({super.key, this.model, this.context, this.sellersUID, this.distanceInKm});

  @override
  State<CategoryDesignWidget> createState() => _CategoryDesignWidgetState();
}

class _CategoryDesignWidgetState extends State<CategoryDesignWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (c) => ItemDetailsScreen(model: widget.model, sellersUID: widget.sellersUID, distanceInKm: widget.distanceInKm??0.0,)));
      },
      child: Padding(
        padding: EdgeInsets.all(4.0.w),
        child: Card(
          elevation: 2,
          child: Column(
            children: [
              SizedBox(
                height: 120.h,
                width: 200.w,
                child: AspectRatio(
                  aspectRatio: 3 / 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0), // You can adjust the radius as needed
                    child: Image.network(
                      widget.model!.thumbnailUrl!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 10.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: RichText(
                    text: TextSpan(
                      children: [
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Padding(
                            padding: EdgeInsets.only(right: 4.0),
                            child: Icon(
                              Icons.fastfood,
                              size: 16.sp,
                              color: AppColors().red,
                            ),
                          ),
                        ),
                        TextSpan(
                          text: (widget.model!.productTitle.length > 13)
                              ? ' ${widget.model!.productTitle.substring(0, 13)}...'
                              : ' ${widget.model!.productTitle}',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: AppColors().black,
                            fontWeight: FontWeight.w700,
                            fontFamily: "Poppins",
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("items")
                      .doc(widget.model.productsID)
                      .collection("itemRecord")
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    var ratings = snapshot.data!.docs
                        .map((doc) => (doc.data() as Map<String, dynamic>)['rating'] as num?)
                        .toList();

                    double averageRating = 0;
                    if (ratings.isNotEmpty) {
                      var totalRating = ratings
                          .map((rating) => rating ?? 0)
                          .reduce((a, b) => a + b);
                      averageRating = totalRating / ratings.length;
                    }

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 10.h),
                            Row(
                              children: [
                                SmoothStarRating(
                                  rating: averageRating,
                                  allowHalfRating: false,
                                  starCount: 5,
                                  size: 10.sp,
                                  color: Colors.yellow,
                                  borderColor: Colors.black45,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  '${averageRating.toStringAsFixed(1)}',
                                  style: TextStyle(
                                      fontFamily: "Poppins",
                                      color: AppColors().black1,
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
              SizedBox(height: 5),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: RichText(
                    text: TextSpan(
                      children: [
                        WidgetSpan(
                          child: Padding(
                            padding: EdgeInsets.only(right: 10.0),
                            child: Image.asset(
                              'images/peso.png',
                              width: 14,
                              height: 14,
                              color: AppColors().green,
                            ),
                          ),
                        ),
                        TextSpan(
                          text: ": "+ '${widget.model!.productPrice}'".00",
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors().black1,
                            fontWeight: FontWeight.w600,
                            overflow: TextOverflow.ellipsis,
                            fontFamily: "Poppins",
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),


            ],
          ),
        ),
      ),
    );
  }
}
