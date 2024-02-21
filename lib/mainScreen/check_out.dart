
import 'package:cpton_foodtogo/mainScreen/payment_screen.dart';
import 'package:cpton_foodtogo/mainScreen/save_address_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../CustomersWidgets/address_design.dart';
import '../CustomersWidgets/progress_bar.dart';
import '../assistantMethods/address_changer.dart';
import '../assistantMethods/assistant_methods.dart';
import '../global/global.dart';
import '../models/address.dart';
import '../theme/colors.dart';
import 'my_order_screen.dart';

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
          "Checkout",
          style: TextStyle(fontFamily: "Poppins", color: Colors.white, fontSize: 14.sp),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 16.h),
            // "Add Address" button
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (c) => SaveAddressScreen()));
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_location_alt_outlined, color: AppColors().red,),
                  Text("Add Address", style: TextStyle(color: AppColors().red, fontSize: 12.sp)),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            // List of addresses
            Consumer<AddressChanger>(
              builder: (context, address, c) {
                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("users")
                      .doc(sharedPreferences?.getString("uid"))
                      .collection("userAddress")
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: circularProgress());
                    } else if (snapshot.data!.docs.isEmpty) {
                      return Center(child: Text("No addresses added yet."));
                    } else {
                      return Column(
                        children: [
                          if (showAllAddresses)
                            ...List.generate(snapshot.data!.docs.length, (index) {
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
                            }),
                          if (!showAllAddresses)
                            AddressDesign(
                              currentIndex: address.count,
                              value: 0,
                              addressId: snapshot.data!.docs[0].id,
                              totalAmount: widget.totalAmount,
                              sellersUID: widget.sellersUID,
                              model: Address.fromJson(
                                snapshot.data!.docs[0].data()! as Map<String, dynamic>,
                              ),
                            ),
                          if (snapshot.data!.docs.length > 1)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  showAllAddresses = !showAllAddresses;
                                });
                              },
                              child: Text(showAllAddresses ? "Hide Addresses" : "View All Addresses"),
                            ),
                        ],
                      );
                    }
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
            SizedBox(height: 16.h),
            // Place Order button
            // Place Order button
            ElevatedButton(
              onPressed: () {
                if (widget.addressId == null) {
                  // Show toast message or alert dialog indicating that the user needs to choose an address
                  Fluttertoast.showToast(msg: "Please choose an address.");
                } else if (selectedPaymentMethod == null) {
                  // Show toast message or alert dialog indicating that the user needs to select a payment method
                  Fluttertoast.showToast(msg: "Please select a payment method.");
                } else if (widget.sellersUID == null) {
                  // Show toast message or alert dialog indicating that the sellersUID is missing
                  Fluttertoast.showToast(msg: "Seller's UID is missing.");
                } else {
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
                }
              },
              child: Text("Place Order", style: TextStyle(fontWeight: FontWeight.w600, fontFamily: "Poppins", fontSize: 12.sp)),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: AppColors().red,
                minimumSize: Size(200.w, 50.h),
              ),
            ),


          ],
        ),
      ),
    );
  }
}
