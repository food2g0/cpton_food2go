import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../assistantMethods/assistant_methods.dart';
import '../global/global.dart';
import '../theme/colors.dart';
import 'my_order_screen.dart';

class PaymentScreen extends StatefulWidget {
  final double? totalAmount;
  final String? paymentMethod;
  final String? addressID;
  final String? sellersUID;

  PaymentScreen({this.totalAmount, this.paymentMethod, this.addressID, this.sellersUID});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {

  @override
  void initState() {
    super.initState();

    // Print the values when the widget is initialized
    print('Total Amount: ${widget.totalAmount}');
    print('Payment Method: ${widget.paymentMethod}');
    print('Address ID: ${widget.addressID}');
    print('Sellers ID: ${widget.sellersUID}');
  }


  TextEditingController referenceNumberController = TextEditingController();
  String? selectedPaymentMethod;
  String orderId = DateTime.now().millisecondsSinceEpoch.toString();

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
        "addressID": widget.addressID,
        "totalAmount": widget.totalAmount,
        "orderBy": sharedPreferences?.getString("uid"),
        "products": products, // Add cart items
        "paymentDetails": "Gcash",
        "orderTime": orderId,
        "isSuccess": true,
        "sellerUID": widget.sellersUID,
        "riderUID": "",
        "status": "ToPay",
        "orderId": orderId,
      });

      // Add order details for seller
      await writeOrderDetailsForSeller({
        "addressID": widget.addressID,
        "totalAmount": widget.totalAmount,
        "orderBy": sharedPreferences?.getString("uid"),
        "products": products, // Add cart items
        "paymentDetails": "Gcash",
        "orderTime": orderId,
        "isSuccess": true,
        "sellerUID": widget.sellersUID,
        "riderUID": "",
        "status": "ToPay",
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
    double? totalAmount = widget.totalAmount!;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors().red,
        title: Text('Payment Details',
        style: TextStyle(
          fontFamily: "Poppins",
          fontSize: 14.sp,
          color: AppColors().white
        ),),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Amount: ${totalAmount}'),
            SizedBox(height: 16),
            Text('GCash Number: 09271679585 - Paolo Somido'), // Assuming sellersUID is the GCash number
            SizedBox(height: 16),
            Text('Enter Reference Number:'),
            TextFormField(
              controller: referenceNumberController,
              keyboardType: TextInputType.number,
              maxLength: 13,
              decoration: InputDecoration(
                hintText: 'Enter 13-digit reference number',
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                addOrderDetails(context);
                // Add your logic for processing the payment with the reference number
              },
              child: Text('Submit Payment'),
            ),
          ],
        ),
      ),
    );
  }
}
