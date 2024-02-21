import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_foodtogo/mainScreen/payment_screen.dart';
import 'package:cpton_foodtogo/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../assistantMethods/assistant_methods.dart';
import '../global/global.dart';
import 'my_order_screen.dart';

class CheckoutOrderScreen extends StatefulWidget {
  final double? totalAmount;
  final String? sellersUID;
  final String? addressId;
  final String? paymentMode;

  const CheckoutOrderScreen({
    Key? key,
    this.totalAmount,
    this.sellersUID,
    this.addressId,
    this.paymentMode,
  }) : super(key: key);

  @override
  State<CheckoutOrderScreen> createState() => _CheckoutOrderScreenState();
}

class _CheckoutOrderScreenState extends State<CheckoutOrderScreen> {
  String? selectedPaymentMethod;
  String orderId = DateTime.now().millisecondsSinceEpoch.toString();

  SharedPreferences? sharedPreferences;
  bool showAllAddresses = false; // Flag to show all addresses

  @override
  void initState() {
    super.initState();
    initializeSharedPreferences();
  }

  void initializeSharedPreferences() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  Future<void> addOrderDetails(BuildContext context) async {
    if (sharedPreferences == null) return;
    try {
      DocumentReference userDocRef =
      FirebaseFirestore.instance.collection("users").doc(firebaseAuth.currentUser!.uid);

      QuerySnapshot cartSnapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(firebaseAuth.currentUser!.uid)
          .collection("cart")
          .get();

      List<Map<String, dynamic>> products = cartSnapshot.docs.map((cartItem) {
        return {
          "foodItemId": cartItem['foodItemId'],
          "itemCounter": cartItem['itemCounter'],
          "cartID": cartItem['cartID'],
          "thumbnailUrl": cartItem['thumbnailUrl'],
          "productTitle": cartItem['productTitle'],
          "productPrice": cartItem['productPrice'],
        };
      }).toList();







      await writeOrderDetailsForUser({
        "addressID": widget.addressId,
        "totalAmount": widget.totalAmount,
        "orderBy": sharedPreferences?.getString("uid"),
        "products": products,
        "paymentDetails": selectedPaymentMethod,
        "orderTime": orderId,
        "isSuccess": true,
        "sellerUID": widget.sellersUID,
        "riderUID": "",
        "status": "normal",
        "orderId": orderId,
        // "customerName": widget.model.name,
        // "phoneNumber": widget.model.phoneNumber,
      });

      await writeOrderDetailsForSeller({
        "addressID": widget.addressId,
        "totalAmount": widget.totalAmount,
        "orderBy": sharedPreferences?.getString("uid"),
        "products": products,
        "paymentDetails": selectedPaymentMethod,
        "orderTime": orderId,
        "isSuccess": true,
        "sellerUID": widget.sellersUID,
        "riderUID": "",
        "status": "normal",
        "orderId": orderId,
        // "customerName": widget.model.name,
        // "phoneNumber": widget.model.phoneNumber,
      });

      clearCartNow(context);

      setState(() {
        orderId = "";
      });

      Navigator.push(context, MaterialPageRoute(builder: (context) => MyOrderScreen()));

      Fluttertoast.showToast(msg: "Congratulations, order placed successfully!");
    } catch (error) {
      print("Error adding order details: $error");
    }
  }

  Future writeOrderDetailsForUser(Map<String, dynamic> data) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(sharedPreferences?.getString("uid"))
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
        backgroundColor: AppColors().red,
        title: Text(
          "Payment",
          style: TextStyle(
            fontFamily: "Poppins",
            fontSize: 12.sp,
            color: AppColors().white1,
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(16.w),
        color: Colors.grey[200],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Choose Payment Method:",
              style: TextStyle(
                color: AppColors().black,
                fontFamily: "Poppins",
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            // Radio buttons for payment methods
            RadioListTile(
              title: Text(
                "Pay with Gcash",
                style: TextStyle(
                  color: AppColors().black,
                  fontFamily: "Poppins",
                  fontSize: 12.sp,
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
            RadioListTile(
              title: Text(
                "Cash on Delivery",
                style: TextStyle(
                  color: AppColors().black,
                  fontFamily: "Poppins",
                  fontSize: 12.sp,
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
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16.w),
        child: ElevatedButton(
          onPressed: () {
            if (selectedPaymentMethod == "Gcash") {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (c) => PaymentScreen(
                    addressID: widget.addressId,
                    totalAmount: widget.totalAmount,
                    paymentMethod: selectedPaymentMethod,
                    sellersUID: widget.sellersUID,
                  ),
                ),
              );
            } else {
              addOrderDetails(context);
            }
          },
          child: Text(
            "Place Order",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontFamily: "Poppins",
              fontSize: 12.sp,
            ),
          ),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: AppColors().red,
            minimumSize: Size(200.w, 50.h),
          ),
        ),
      ),
    );
  }


}


