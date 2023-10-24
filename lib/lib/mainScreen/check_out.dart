import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_foodtogo/lib/CustomersWidgets/address_design.dart';
import 'package:cpton_foodtogo/lib/CustomersWidgets/dimensions.dart';
import 'package:cpton_foodtogo/lib/assistantMethods/address_changer.dart';
import 'package:cpton_foodtogo/lib/mainScreen/save_address_screen.dart';
import 'package:cpton_foodtogo/lib/models/address.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../CustomersWidgets/progress_bar.dart';
import '../global/global.dart';
import '../models/menus.dart';

class checkOut extends StatefulWidget {
  final double? totalAmount;
  final String? sellersUID;
  final Menus? model;

  checkOut({this.sellersUID, this.totalAmount, this.model});

  @override
  State<checkOut> createState() => _checkOutState();
}

class _checkOutState extends State<checkOut> {
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
      body: Container(
        height: 180,
        child: Column(
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
                Spacer(), // Add spacer to push "Add new address" to the right
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
            Expanded(
              child: Consumer<AddressChanger>(
                builder: (context, address, c) {
                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection("users")
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
            SizedBox(height: 8),
            InkWell(
              onTap: () {},
              child: Container(
                color: Colors.white,
                width: MediaQuery.of(context).size.width * 1,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Align elements to the start and end
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.payment, // Replace with your desired payment icon
                            color: Colors.black87,
                            size: 24, // Adjust the size as needed
                          ),
                          SizedBox(width: 8), // Add some space between the icon and text
                          Text(
                            "Choose Payment Method:",
                            style: TextStyle(
                              color: Colors.black87,
                              fontFamily: "Poppins",
                              fontSize: Dimensions.font12,
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        Icons.navigate_next, // Replace with your desired icon at the end
                        color: Colors.black87,
                        size: 24, // Adjust the size as needed
                      ),
                    ],
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