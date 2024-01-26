import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../models/menus.dart';
import 'dimensions.dart';

class CartItemDesign extends StatelessWidget {
  final Menus? model;
  final int? quanNumber;
  final BuildContext? context;

  const CartItemDesign({
    super.key,
    this.model,
    this.quanNumber,
    this.context,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Padding(
        padding: EdgeInsets.only(left: 10, right: 10, top: 10).w,
        child: SizedBox(
          height: 120.h,
          width: double.infinity,
          child: Container(

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.w),
              border: Border.all(color: Color(0xFF890010), width: 1), // Add this line for the border
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                Container(
                  width: 140,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius:  BorderRadius.only(
                      topLeft: Radius.circular(10.w),
                      bottomLeft: Radius.circular(10.w),
                    ),
                    image: DecorationImage(
                      image: NetworkImage(model!.thumbnailUrl!),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
             SizedBox(width: 8.w),

                // Title, Quantity, Price
                Padding(
                  padding: const EdgeInsets.all(8.0).w,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       SizedBox(height: 8.h),
                      Text(
                        model!.productTitle!,
                        style:  TextStyle(
                          color: Colors.black,
                          fontSize: 12.sp,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w700
                        ),
                      ),

                       SizedBox(height: 5.h),
                      // Quantity
                      Row(
                        children: [
                          Text(
                            "Quantity: ",
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 12.sp,
                              fontFamily: "Poppins",
                              fontWeight: FontWeight.w600
                            ),
                          ),

                          Text(
                            quanNumber.toString(),
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              fontFamily: "Poppins",
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5.h),
                      // Price
                      Text(
                        "Php ${model!.productPrice}.00",
                        style:  TextStyle(
                          fontSize: 14.sp,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
