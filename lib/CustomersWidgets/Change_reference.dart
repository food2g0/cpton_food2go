import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_foodtogo/mainScreen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../assistantMethods/assistant_methods.dart';
import '../global/global.dart';
import '../theme/colors.dart';

class ChangeReference extends StatefulWidget {
  final double? totalAmount;
  final String? referenceNumber;
  final String? reason;
  late final String? orderId;


  ChangeReference({this.totalAmount, this.referenceNumber, this.orderId, this.reason, });

  @override
  State<ChangeReference> createState() => _ChangeReferenceState();
}

class _ChangeReferenceState extends State<ChangeReference> {
  TextEditingController referenceNumberController = TextEditingController();


  Future<void> addOrderDetails(BuildContext context) async {
    if (sharedPreferences == null) return;
    try {

      // Update order status for user
      await updateOrderStatusForUser(widget.orderId.toString());

      // Update order status for seller
      await updateOrderStatusForSeller(widget.orderId.toString());

print(widget.orderId);

      // Reset orderId


      // Navigate to the order screen
      Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));

      // Show success message
      Fluttertoast.showToast(msg: "Congratulations, order placed successfully!");
    } catch (error) {
      print("Error adding order details: $error");
      // Handle error as needed
    }
  }





  Future<void> updateOrderStatusForUser(String orderId) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(sharedPreferences?.getString("uid"))
        .collection("orders")
        .doc(widget.orderId)
        .update({'status': 'ToPay',
        'referenceNumber': referenceNumberController.text});
  }

  Future<void> updateOrderStatusForSeller(String orderId) async {
    await FirebaseFirestore.instance.collection("orders").doc(widget.orderId).update({'status': 'ToPay',
      'referenceNumber': referenceNumberController.text});
  }

  @override
  Widget build(BuildContext context) {
    double? totalAmount = widget.totalAmount!;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors().red,
        title: Text(
          'Payment Details',
          style: TextStyle(
            fontFamily: "Poppins",
            fontSize: 14.sp,
            color: AppColors().white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Amount: ${totalAmount}'),
            SizedBox(height: 16),
            Text('Reason of Disaaproval : ${widget.reason}'),
            SizedBox(height: 16),
            Text('Previous Reference Number: ${widget.referenceNumber}'),
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
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (referenceNumberController.text.isEmpty || referenceNumberController.text.length != 13) {
                    // Show error if reference number is empty or not 13 digits long
                    Fluttertoast.showToast(msg: "Please enter a valid 13-digit reference number.");
                  } else {
                    addOrderDetails(context);
                    // Add your logic for processing the payment with the reference number
                  }
                },
                child: Text(
                  'Submit Payment',
                  style: TextStyle(
                    color: AppColors().white,
                    fontFamily: "Poppins",
                    fontSize: 12.sp,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors().red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.w),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
