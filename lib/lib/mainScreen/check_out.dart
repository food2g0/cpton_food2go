import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_foodtogo/lib/CustomersWidgets/address_design.dart';
import 'package:cpton_foodtogo/lib/CustomersWidgets/dimensions.dart';
import 'package:cpton_foodtogo/lib/assistantMethods/address_changer.dart';
import 'package:cpton_foodtogo/lib/assistantMethods/assistant_methods.dart';
import 'package:cpton_foodtogo/lib/mainScreen/payment_screen.dart';
import 'package:cpton_foodtogo/lib/mainScreen/placed_order_screen.dart';
import 'package:cpton_foodtogo/lib/mainScreen/save_address_screen.dart';
import 'package:cpton_foodtogo/lib/models/address.dart';
import 'package:cpton_foodtogo/lib/theme/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:provider/provider.dart';
import '../CustomersWidgets/progress_bar.dart';
import '../global/global.dart';

class CheckOut extends StatefulWidget {
  final double? totalAmount;
  final String? sellersUID;
  final dynamic model;
  final String? addressId;
  final String? paymentMode;

  CheckOut({this.sellersUID, this.totalAmount, this.model, this.addressId, this.paymentMode});

  @override
  State<CheckOut> createState() => _CheckOutState();
}

class _CheckOutState extends State<CheckOut> {
  String? selectedPaymentMethod;
  String orderId = DateTime.now().millisecondsSinceEpoch.toString();

  addOrderDetails() {
    writeOrderDetailsForUser({
      "addressID": widget.addressId,
      "totalAmount": widget.totalAmount,
      "orderBy": sharedPreferences!.getString("uid"),
      "productsIDs": sharedPreferences!.getStringList("userCart"),
      "paymentDetails": selectedPaymentMethod,
      "orderTime": orderId,
      "isSuccess": true,
      "sellerUID": widget.sellersUID,
      "riderUID": "",
      "status": "normal",
      "orderId": orderId,
    });
    writeOrderDetailsForSeller({
      "addressID": widget.addressId,
      "totalAmount": widget.totalAmount,
      "orderBy": sharedPreferences!.getString("uid"),
      "productsIDs": sharedPreferences!.getStringList("userCart"),
      "paymentDetails": selectedPaymentMethod,
      "orderTime": orderId,
      "isSuccess": true,
      "sellerUID": widget.sellersUID,
      "riderUID": "",
      "status": "normal",
      "orderId": orderId,
    }).whenComplete(() {
      clearCartNow(context);
      setState(() {
        orderId = "";
        Navigator.push(context, MaterialPageRoute(builder: (context) => PlacedOrderScreen()));
        Fluttertoast.showToast(msg: "Congratulations, order placed successfully! ");
      });
    });
  }

  Future writeOrderDetailsForUser(Map<String, dynamic> data) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(sharedPreferences!.getString("uid"))
        .collection("orders")
        .doc(orderId)
        .set(data);
  }

  Future writeOrderDetailsForSeller(Map<String, dynamic> data) async {
    await FirebaseFirestore.instance.collection("orders").doc(orderId).set(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF890010),
        title: Text(
          "Checkout",
          style: TextStyle(fontFamily: "Poppins", color: Colors.white, fontSize: 14.sp),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Padding(
                padding: EdgeInsets.all(8.w),
                child: Text(
                  "Select Address: ",
                  style: TextStyle(
                    color: Colors.black87,
                    fontFamily: "Poppins",
                    fontSize: 16.sp,
                  ),
                ),
              ),
              Spacer(),
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (c) => SaveAddressScreen()));
                },
                child:  Row(
                  children: [
                    Icon(Icons.add_location_alt_outlined, color:  Color(0xFF890010),),
                    Text("Add address", style: TextStyle(
                      color:  Color(0xFF890010),
                      fontSize: 14.sp
                    ),),
                  ],
                ),
              ),
            ],
          ),
          // Limit the height of the address container
          Consumer<AddressChanger>(
            builder: (context, address, c) {
              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("users")
                    .doc(sharedPreferences!.getString("uid"))
                    .collection("userAddress")
                    .snapshots(),
                builder: (context, snapshot) {
                  return !snapshot.hasData
                      ? Center(child: circularProgress())
                      : snapshot.data!.docs.length == 0
                      ? Container() // You can provide a default container if there are no items
                      : ListView.builder(
                    itemCount: snapshot.data?.docs.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return AddressDesign(
                        currentIndex: address.count,
                        value: index,
                        addressId: snapshot.data!.docs[index].id,
                        totalAmount: widget.totalAmount,
                        sellersUID: widget.sellersUID,
                        model: Address.fromJson(
                          snapshot.data!.docs[index].data()! as Map<String, dynamic>,
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),

          SizedBox(height: 16.h),
          // Container for Payment Methods
          Container(
            padding: EdgeInsets.all(16.w),
            color: Colors.grey[200],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Choose Payment Method:",
                  style: TextStyle(
                    color: Colors.black87,
                    fontFamily: "Poppins",
                    fontSize: 14.h,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                // Radio button for "Pay with Gcash"
                RadioListTile(
                  title: Text(
                    "Pay with Gcash",
                    style: TextStyle(
                      color: Colors.black87,
                      fontFamily: "Poppins",
                      fontSize: Dimensions.font14,
                    ),
                  ),
                  value: "Gcash",
                  groupValue: selectedPaymentMethod,
                  onChanged: (value) {
                    setState(() {
                      selectedPaymentMethod = value as String?;
                    });
                  },
                ),
                // Radio button for "Cash on Delivery"
                RadioListTile(
                  title: Text(
                    "Cash on Delivery",
                    style: TextStyle(
                      color: Colors.black87,
                      fontFamily: "Poppins",
                      fontSize: 14.sp,
                    ),
                  ),
                  value: "CashOnDelivery",
                  groupValue: selectedPaymentMethod,
                  onChanged: (value) {
                    setState(() {
                      selectedPaymentMethod = value as String?;
                    });
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          // Place Order button
          ElevatedButton(
            onPressed: () {
              if (selectedPaymentMethod == "Gcash") {
                // Navigate to PaymentScreen for Gcash payment
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (c) => PaymentScreen(
                      // Pass any necessary data to PaymentScreen
                      totalAmount: widget.totalAmount,
                      paymentMethod: selectedPaymentMethod,
                    ),
                  ),
                );
              } else {
                // Navigate to PlacedOrderScreen for other payment methods
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (c) => PlacedOrderScreen(
                      addressID: widget.addressId,
                      totalAmount: widget.totalAmount,
                      sellerUID: widget.sellersUID,
                      paymentMode: widget.paymentMode,
                    ),
                  ),
                );
                addOrderDetails();
              }
            },
            child: Text("Place Order", style: TextStyle(fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(
              primary: AppColors().red, // Change the background color
              onPrimary: Colors.white, // Change the text color
              minimumSize: Size(200.w, 50.h), // Adjust the width and height
            ),
          ),


        ],
      ),
    );
  }
}
