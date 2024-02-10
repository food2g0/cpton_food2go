import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_foodtogo/lib/mainScreen/delivered_order_details_screen.dart';
import 'package:cpton_foodtogo/lib/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../mainScreen/order_details_screen.dart';
import '../models/items.dart';

class DeliveredOrderCard extends StatelessWidget {
  final int itemCount;
  final List<Map<String, dynamic>> data;
  final String orderID;
  final String sellerName;
  final String? paymentDetails;
  final String? totalAmount;
  final List<Map<String, dynamic>> cartItems;
  final String? status;

  DeliveredOrderCard({
    required this.itemCount,
    required this.data,
    required this.orderID,
    required this.sellerName,
    this.paymentDetails,
    this.totalAmount,
    required this.cartItems,  this.status,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: ()  {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (c) => DeliveredOrderDetailsScreen(orderID: orderID)),
        );
      },
      child: Card(
        elevation: 2,
        child: Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: itemCount,
              itemBuilder: (context, index) {
                return placedOrderDesignWidget(context, index, cartItems, sellerName);

              },
            ),
          ],
        ),
      ),
    );
  }
}

Widget placedOrderDesignWidget(BuildContext context, int index, List<Map<String, dynamic>> cartItems, String sellerName) {
  return SizedBox(
    height: 140,
    child: Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Image.network(
              cartItems[index]['thumbnailUrl'],
              width: 150,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cartItems[index]['productTitle'],
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5,),
                Row(
                  children: [
                    Text(
                      "Seller: ",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        fontFamily: "Poppins",
                      ),
                    ),
                    Text(
                      sellerName,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        fontFamily: "Poppins",
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      "Price: ",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: "Poppins",
                      ),
                    ),
                    Text(
                      cartItems[index]['productPrice'].toString(),
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: "Poppins",
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      "x ",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                        fontFamily: "Poppins",
                      ),
                    ),
                    Text(
                      cartItems[index]['itemCounter'].toString(),
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontFamily: "Poppins",
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10,),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
