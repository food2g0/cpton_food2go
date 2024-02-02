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

  const CategoryDesignWidget({super.key, this.model, this.context});

  @override
  State<CategoryDesignWidget> createState() => _CategoryDesignWidgetState();
}

class _CategoryDesignWidgetState extends State<CategoryDesignWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (c) => ItemDetailsScreen(model: widget.model, )));
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
              SizedBox(height: 5),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0.w),
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: SmoothStarRating(
                    allowHalfRating: false,
                    starCount: 5,
                    size: 10.sp,
                    rating: 5,
                    color: AppColors().yellow,
                    borderColor: AppColors().black,
                  ),
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
                            child: Icon(
                              Icons.currency_ruble,
                              size: 16.sp,
                              color: Colors.green,
                            ),
                          ),
                        ),
                        TextSpan(
                          text: "Php: " + '${widget.model!.productPrice}',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.black45,
                            fontWeight: FontWeight.w700,
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
