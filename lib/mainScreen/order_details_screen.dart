import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../CustomersWidgets/progress_bar.dart';
import '../CustomersWidgets/shipment_address_design.dart';
import '../CustomersWidgets/statusBanner.dart';
import '../global/global.dart';
import '../models/address.dart';

class OrderDetailsScreen extends StatefulWidget {

  final String? orderID;


  OrderDetailsScreen({this.orderID, });

  @override

  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  String orderStatus = "";




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection("users")
              .doc(sharedPreferences!.getString("uid"))
              .collection("orders")
              .doc(widget.orderID)
              .get(),
          builder: (context, snapshot) {
            Map<String, dynamic>? dataMap;
            if (snapshot.hasData) {
              dataMap = snapshot.data!.data()! as Map<String, dynamic>;
              orderStatus = dataMap["status"].toString();
            }
            return snapshot.hasData
                ? Container(

              child: Column(
                children: [
                  StatusBanner(
                    status: dataMap!["isSuccess"],
                    orderStatus: orderStatus,
                  ),
                  SizedBox(height: 5.0.h),
                  Padding(
                    padding:  EdgeInsets.all(4.0.w),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Total Amount Php ${(dataMap["totalAmount"])}", // Add defaultShippingFee here
                        style:  TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          fontFamily: "Poppins",
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(4.0.w),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Order Id = " + widget.orderID!,
                        style:  TextStyle(
                          fontSize: 12.sp,
                          fontFamily: "Poppins",
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding:  EdgeInsets.all(4.0.w),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Order at: " +
                            DateFormat("dd MMMM, yyyy - hh:mm aa").format(
                              DateTime.fromMillisecondsSinceEpoch(
                                int.parse(dataMap["orderTime"]),
                              ),
                            ),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey,
                          fontFamily: "Poppins",
                        ),
                      ),
                    ),
                  ),

                  const Divider(thickness: 4),
                  orderStatus == "ended"
                      ? Image.asset("images/delivered.jpg")
                      : Image.asset("images/state.jpg"),
                  const Divider(thickness: 4),
                  FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection("users")
                        .doc(sharedPreferences?.getString("uid")) // Use null-aware operator
                        .collection("userAddress")
                        .doc(dataMap["addressID"])
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: circularProgress());
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (snapshot.hasData) {
                        // Print the address data
                        print('Address data: ${snapshot.data!.data()}');

                        // Return the ShipmentAddressDesign widget with the retrieved address data
                        return ShipmentAddressDesign(
                          orderID: widget.orderID,
                          model: Address.fromJson(
                            snapshot.data!.data()! as Map<String, dynamic>,
                          ),
                        );
                      } else {
                        // Display a message indicating that the address was not found
                        return Center(child: Text("Address not found."));
                      }
                    },

                  ),

                ],
              ),
            )
                : Center(child: circularProgress());
          },
        ),


      ),
    );
  }
}