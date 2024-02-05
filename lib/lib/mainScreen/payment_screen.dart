import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_foodtogo/lib/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../assistantMethods/assistant_methods.dart';
import '../global/global.dart';
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

  addOrderDetails() {
    writeOrderDetailsForUser({
      "addressID": widget.addressID,
      "totalAmount": widget.totalAmount,
      "orderBy": sharedPreferences!.getString("uid"),
      "productsIDs": sharedPreferences!.getStringList("userCart"),
      "paymentDetails": "Gcash",
      "orderTime": orderId,
      "isSuccess": true,
      "sellerUID": widget.sellersUID,
      "referenceNumber": referenceNumberController.text,
      "riderUID": "",
      "status": "ToPay",
      "orderId": orderId,
    });
    writeOrderDetailsForSeller({
      "addressID": widget.addressID,
      "totalAmount": widget.totalAmount,
      "orderBy": sharedPreferences!.getString("uid"),
      "productsIDs": sharedPreferences!.getStringList("userCart"),
      "paymentDetails": "Gcash",
      "orderTime": orderId,
      "isSuccess": true,
      "referenceNumber": referenceNumberController.text,
      "sellerUID": widget.sellersUID,
      "riderUID": "",
      "status": "ToPay",
      "orderId": orderId,
    }).whenComplete(() {
      clearCartNow(context);
      setState(() {
        orderId = "";
        Navigator.push(context, MaterialPageRoute(builder: (context) => MyOrderScreen()));
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
    double defaultShippingFee = 50.0;
    double? totalAmount = widget.totalAmount! + defaultShippingFee;
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
                addOrderDetails();
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
