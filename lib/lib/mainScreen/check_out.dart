import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_foodtogo/lib/CustomersWidgets/address_design.dart';
import 'package:cpton_foodtogo/lib/CustomersWidgets/dimensions.dart';
import 'package:cpton_foodtogo/lib/assistantMethods/address_changer.dart';
import 'package:cpton_foodtogo/lib/mainScreen/payment_screen.dart';
import 'package:cpton_foodtogo/lib/mainScreen/placed_order_screen.dart';
import 'package:cpton_foodtogo/lib/mainScreen/save_address_screen.dart';
import 'package:cpton_foodtogo/lib/models/address.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../CustomersWidgets/progress_bar.dart';
import '../global/global.dart';
import '../models/menus.dart';

class CheckOut extends StatefulWidget {
  final double? totalAmount;
  final String? sellersUID;
  final Menus? model;
  final String? addressId;
  final String? paymentMode;

  CheckOut({this.sellersUID, this.totalAmount, this.model, this.addressId, this.paymentMode,});

  @override
  State<CheckOut> createState() => _CheckOutState();
}

class _CheckOutState extends State<CheckOut> {
  String? selectedPaymentMethod;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF890010),
        title: const Text(
          "Checkout",
          style: TextStyle(fontFamily: "Poppins"),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  "Select Address: ",
                  style: TextStyle(
                    color: Colors.black87,
                    fontFamily: "Poppins",
                    fontSize: Dimensions.font20,
                  ),
                ),
              ),
              Spacer(),
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (c) => SaveAddressScreen()));
                },
                child: const Row(
                  children: [
                    Icon(Icons.add_location_alt_outlined),
                    Text("Add new address"),
                  ],
                ),
              ),
            ],
          ),
          // Limit the height of the address container
          Container(
            height: 150,
            child: Consumer<AddressChanger>(
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
                        ? Container()
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
          ),
          SizedBox(height: 16),
          // Container for Payment Methods
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.grey[200],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Choose Payment Method:",
                  style: TextStyle(
                    color: Colors.black87,
                    fontFamily: "Poppins",
                    fontSize: Dimensions.font16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
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
                      fontSize: Dimensions.font14,
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
          SizedBox(height: 16),
          // Place Order button
          ElevatedButton(
            onPressed: () {
             Navigator.push(context, MaterialPageRoute(builder: (c)=> PlacedOrderScreen(
               addressID: widget.addressId,
               totalAmount: widget.totalAmount,
               sellerUID: widget.sellersUID,
               paymentMode: widget.paymentMode,
             )));
            },
            child: Text("Place Order"),
          ),
        ],
      ),
    );
  }
}
