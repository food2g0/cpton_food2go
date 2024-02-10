import 'package:cpton_foodtogo/lib/mainScreen/payment_screen.dart';
import 'package:cpton_foodtogo/lib/mainScreen/save_address_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_foodtogo/lib/CustomersWidgets/address_design.dart';
import 'package:cpton_foodtogo/lib/assistantMethods/address_changer.dart';
import 'package:cpton_foodtogo/lib/assistantMethods/assistant_methods.dart';
import 'package:cpton_foodtogo/lib/mainScreen/placed_order_screen.dart';
import 'package:cpton_foodtogo/lib/models/address.dart';
import 'package:cpton_foodtogo/lib/theme/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../CustomersWidgets/progress_bar.dart';
import '../global/global.dart';
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
   // Declare sharedPreferences variable
  String? selectedPaymentMethod;
  String orderId = DateTime.now().millisecondsSinceEpoch.toString();


  SharedPreferences? sharedPreferences;

  @override
  void initState() {
    super.initState();
    initializeSharedPreferences();
  }

  void initializeSharedPreferences() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }


  // Function to retrieve sharedPreferences instance
  void retrieveSharedPreferences() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  Future<void> addOrderDetails(BuildContext context) async {
    if (sharedPreferences == null) return;
    try {
      // Fetch user document reference

      DocumentReference userDocRef =
      FirebaseFirestore.instance.collection("users").doc(firebaseAuth.currentUser!.uid);

      // Fetch cart items
      QuerySnapshot cartSnapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(firebaseAuth.currentUser!.uid)
          .collection("cart")
          .get();

      // Get cart item details
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

      // Add order details for user
      await writeOrderDetailsForUser({
        "addressID": widget.addressId,
        "totalAmount": widget.totalAmount,
        "orderBy": sharedPreferences?.getString("uid"),
        "products": products, // Add cart items
        "paymentDetails": selectedPaymentMethod,
        "orderTime": orderId,
        "isSuccess": true,
        "sellerUID": widget.sellersUID,
        "riderUID": "",
        "status": "normal",
        "orderId": orderId,
      });

      // Add order details for seller
      await writeOrderDetailsForSeller({
        "addressID": widget.addressId,
        "totalAmount": widget.totalAmount,
        "orderBy": sharedPreferences?.getString("uid"),
        "products": products, // Add cart items
        "paymentDetails": selectedPaymentMethod,
        "orderTime": orderId,
        "isSuccess": true,
        "sellerUID": widget.sellersUID,
        "riderUID": "",
        "status": "normal",
        "orderId": orderId,
      });

      // Clear the cart
      clearCartNow(context);

      // Reset orderId
      setState(() {
        orderId = "";
      });

      // Navigate to the order screen
      Navigator.push(context, MaterialPageRoute(builder: (context) => MyOrderScreen()));

      // Show success message
      Fluttertoast.showToast(msg: "Congratulations, order placed successfully!");
    } catch (error) {
      print("Error adding order details: $error");
      // Handle error as needed
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
                    fontWeight: FontWeight.w600,
                    color: AppColors().black,
                    fontFamily: "Poppins",
                    fontSize: 12.sp,
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
                    Icon(Icons.add_location_alt_outlined, color:  AppColors().red,),
                    Text("Add address", style: TextStyle(
                        color:  AppColors().red,
                        fontSize: 12.sp
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
                    .doc(sharedPreferences?.getString("uid")) // Check if sharedPreferences is not null
                    .collection("userAddress")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: circularProgress());
                  } else if (snapshot.data!.docs.isEmpty) {
                    return Container(); // Provide a default container if there are no items
                  } else {
                    return ListView.builder(
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
                // Radio button for "Pay with Gcash"
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
                // Radio button for "Cash on Delivery"
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
          ElevatedButton(
            onPressed: () {
              if (selectedPaymentMethod == "Gcash") {
                // Navigate to PaymentScreen for Gcash payment
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (c) => PaymentScreen(
                      // Pass any necessary data to PaymentScreen
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
            child: Text("Place Order", style: TextStyle(
              fontWeight: FontWeight.w600,
              fontFamily: "Poppins",
              fontSize: 12.sp,
            )),
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
