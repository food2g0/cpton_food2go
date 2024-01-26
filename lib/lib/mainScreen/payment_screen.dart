// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';
// import 'package:webview_flutter/webview_flutter.dart';
//
// class PaymentScreen extends StatefulWidget {
//
//
//
//
//   @override
//   _PaymentScreenState createState() => _PaymentScreenState();
// }
//
// class _PaymentScreenState extends State<PaymentScreen> {
//
//   var _razorpay = Razorpay();
//   var amountController=TextEditingController();
//
//   @override
//   void initState() {
//
//     _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
//     _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
//     _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
//     super.initState();
//   }
//   void _handlePaymentSuccess(PaymentSuccessResponse response) {
//     // Do something when payment succeeds
//     print("Payment Done");
//   }
//
//   void _handlePaymentError(PaymentFailureResponse response) {
//     // Do something when payment fails
//     print("Payment Fail");
//   }
//
//   void _handleExternalWallet(ExternalWalletResponse response) {
//     // Do something when an external wallet is selected
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     var size = MediaQuery.of(context).size;
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("GCash Payment"),
//       ),
//       body: Container(
//         height: size.height,
//         width: size.width,
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
//               child: TextField(
//
//                 controller: amountController,
//                 decoration: const InputDecoration(
//                   hintText: "Enter the amount"
//                 ),
//               ),
//
//             ),
//
//             CupertinoButton(
//                 color: Colors.black12,
//                 child: Text("Proceed"),
//                 onPressed: (){
//               //Make payment
//                   var options = {
//                     'key': "rzp_test_qYSK5cLSPtBvhC",
//
//                     'amount': int.parse((amountController.text)*1).toString(), //in the smallest currency sub-unit.
//                     'name': 'food2go',
//                     'description': 'Demo',
//                     'timeout': 300, // in seconds
//                     'prefill': {
//                       'contact': '09271679585',
//                       'email': 'paolosomido42@gmail.com'
//                     }
//                   };
//                   _razorpay.open(
//                   options
//                   );
//
//             })
//           ],
//         ),
//       )
//     );
//   }
//  @override
//   void dispose() {
//    _razorpay.clear(); // Removes all listeners
//     super.dispose();
//   }
// }
