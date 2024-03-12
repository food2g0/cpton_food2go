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
  final double? shippingFee;
  final String? sellersUID;
  final String? addressId;
  final String? paymentMode;

  const CheckoutOrderScreen({
    Key? key,
    this.totalAmount,
    this.sellersUID,
    this.addressId,
    this.paymentMode,
    this.shippingFee,
  }) : super(key: key);

  @override
  State<CheckoutOrderScreen> createState() => _CheckoutOrderScreenState();
}

class _CheckoutOrderScreenState extends State<CheckoutOrderScreen> {
  String? selectedPaymentMethod;
  String orderId = DateTime.now().millisecondsSinceEpoch.toString();

  SharedPreferences? sharedPreferences;
  bool showAllAddresses = false; // Flag to show all addresses
  int availableRiders = 0; // Variable to hold the count of available riders

  @override
  void initState() {
    super.initState();
    initializeSharedPreferences();
    fetchAvailableRiders(); // Fetch available riders count
  }

  void initializeSharedPreferences() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }
  void fetchAvailableRiders() async {
    try {
      QuerySnapshot<Map<String, dynamic>> ridersSnapshot = await FirebaseFirestore.instance
          .collection("riders")
          .where("availability", isEqualTo: "yes") // Filter by availability
          .get();

      setState(() {
        availableRiders = ridersSnapshot.size; // Get the count of available riders
      });

      if (availableRiders == 0) {
        // Show an alert dialog if no riders are available
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("No Available Riders", style: TextStyle(fontFamily: "Poppins",
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            color: AppColors().black),),
            content: Text("There are no available riders right now. Do you want to continue?",
            style: TextStyle(
              fontFamily: "Poppins",
              fontSize: 10.sp,
              fontWeight: FontWeight.normal,
              color: AppColors().black
            ),),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text("Cancel",
                style: TextStyle(color: AppColors().red,
                fontFamily: "Poppins"),),
              ),
              TextButton(
                onPressed: () {
                  // Add logic to handle continuation
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text("Continue",
                style: TextStyle(
                  color: AppColors().green,
                  fontFamily: "Poppins"
                ),),
              ),
            ],
          ),
        );
      }
    } catch (error) {
      print("Error fetching available riders: $error");
    }
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
        "shippingFee": widget.shippingFee,
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
        "shippingFee": widget.shippingFee,
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
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: ordersIsEmpty(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Display a loading indicator while fetching data
          return Center(
            child: SizedBox(
              height: 24.h,
                width: 24.w,
                child: CircularProgressIndicator()),
          );
        } else {
          if (snapshot.hasError) {
            // Display an error message if fetching data fails
            return Text('Error: ${snapshot.error}');
          } else {
            // Display the screen based on the fetched data
            final bool isOrdersEmpty = snapshot.data ?? true;
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
                    if (!isOrdersEmpty) // Check if orders collection is empty
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
                  onPressed: selectedPaymentMethod == null
                      ? null // Disable button if payment method is not selected
                      : () {
                    if (selectedPaymentMethod == "Gcash") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (c) => PaymentScreen(
                            shippingFee: widget.shippingFee,
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
              persistentFooterButtons: [
                Text("Available Riders: $availableRiders",
                style: TextStyle(fontFamily: "Poppins",
                fontWeight: FontWeight.w600,
                fontSize: 10.sp),), // Display the count of available riders
              ],
            );
          }
        }
      },
    );
  }


  Future<bool> ordersIsEmpty() async {
    // Retrieve documents within the orders collection
    QuerySnapshot<Map<String, dynamic>> ordersSnapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(firebaseAuth.currentUser!.uid)
        .collection("orders")
        .get();

    // Check if there are any documents present
    return ordersSnapshot.docs.isEmpty;
  }




}


