import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_foodtogo/lib/mainScreen/delivered_order_details_screen.dart';
import 'package:cpton_foodtogo/lib/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../mainScreen/order_details_screen.dart';
import '../models/items.dart';

class DeliveredOrderCard extends StatelessWidget {
  final int? itemCount;
  final List<DocumentSnapshot>? data;
  final String? orderID;
  final List<String>? seperateQuantitiesList;
  final String? sellerName;
  final String status; // Added status parameter

  DeliveredOrderCard({
    this.itemCount,
    this.data,
    this.orderID,
    this.seperateQuantitiesList,
    this.sellerName,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (c) => DeliveredOrderDetailsScreen(orderID: orderID)));
      },
      child: Card(
        elevation: 2,
        child: Container(
          color: Colors.white70,
          padding: EdgeInsets.all(10.w),
          margin: EdgeInsets.all(10.w),
          height: itemCount! * 125,
          child: ListView.builder(
            itemCount: itemCount,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              Items model = Items.fromJson(data![index].data()! as Map<String, dynamic>);
              return placedOrderDesignWidget(model, context, seperateQuantitiesList![index], sellerName, status);
            },
          ),
        ),
      ),
    );
  }
}

Widget placedOrderDesignWidget(Items model, BuildContext context, String seperateQuantitiesList, String? sellerName, String status) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Display seller's name
      Row(
        children: [
          Image.network(
            model.thumbnailUrl,
            width: 120.w,
            fit: BoxFit.cover,
          ),
          SizedBox(width: 10.0.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (model.productTitle.length > 12)
                      ? ' ${model.productTitle.substring(0, 12)}...'
                      : ' ${model.productTitle}',
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  sellerName ?? '',
                  style: const TextStyle(
                    color: Colors.black45,
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    fontFamily: "Poppins",
                  ),
                ),
                Row(
                  children: [
                    Text(
                      " Php ",
                      style: TextStyle(fontSize: 12.sp, color: AppColors().red),
                    ),
                    Text(
                      model.productPrice.toString(),
                      style: TextStyle(
                        color: AppColors().red,
                        fontSize: 12.0.sp,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      "qty: x ",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      seperateQuantitiesList,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14.sp,
                        fontFamily: "Poppins",
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),

    ],
  );
}
