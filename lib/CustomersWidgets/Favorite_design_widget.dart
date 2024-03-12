import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../assistantMethods/assistant_methods.dart';
import '../mainScreen/item_details_screen.dart';
import '../theme/colors.dart';

class FavoriteDesignWidget extends StatefulWidget {
  final dynamic model;
  final BuildContext? context;
  final VoidCallback? onRemove;
  final double? distanceInKm;


  const FavoriteDesignWidget({super.key, this.model, this.context, this.onRemove, this.distanceInKm});

  @override
  State<FavoriteDesignWidget> createState() => _FavoriteDesignWidgetState();
}

class _FavoriteDesignWidgetState extends State<FavoriteDesignWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (c) => ItemDetailsScreen(model: widget.model,   distanceInKm: widget.distanceInKm ?? 0.0,)));
      },
      child: Padding(
        padding: EdgeInsets.all(4.0.w),
        child: Card(

          elevation: 2,
          child: Column(
            children: [
              SizedBox(
                height: 100.h,
                width: 200.w,
                child: AspectRatio(
                  aspectRatio: 3 / 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
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
                              Icons.delete_forever,
                              size: 16.sp,
                              color: AppColors().yellow,
                            ),
                          ),
                        ),
                        TextSpan(
                          text:  widget.model!.productTitle!.length <= 14
                              ? widget.model!.productTitle!
                              : widget.model!.productTitle!.substring(0, 14) + '...',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors().black,
                            fontWeight: FontWeight.w500,
                            overflow: TextOverflow.ellipsis,
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
                              color: AppColors().green,
                            ),
                          ),
                        ),
                        TextSpan(
                          text:   '${widget.model!.productPrice}',
                          style: TextStyle(
                            fontSize: 14.sp,
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
