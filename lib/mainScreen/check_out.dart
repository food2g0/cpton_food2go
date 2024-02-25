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
  bool showAllAddresses = true; // Flag to show all addresses

  @override
  void initState() {
    super.initState();
    initializeSharedPreferences();
  }

  Future<void> initializeSharedPreferences() async {
    sharedPreferences = await SharedPreferences.getInstance();
    String? uid = sharedPreferences?.getString("uid");
    print("User UID: $uid");
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors().red,
        title: Text(
          "Choose Address",
          style: TextStyle(fontFamily: "Poppins", color: Colors.white, fontSize: 12.sp),
        ),
      ),
      body: FutureBuilder<void>(
        future: initializeSharedPreferences(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Display a loading indicator while waiting for SharedPreferences to initialize
            return Center(child: CircularProgressIndicator());
          } else {
            // SharedPreferences initialized, build the StreamBuilder to fetch addresses
            return SingleChildScrollView(
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
                            print("Snapshot data length: ${snapshot.data!.docs.length}");
                            return Column(
                              children: [
                                if (showAllAddresses)
                                  ...List.generate(snapshot.data!.docs.length, (index) {
                                    print("Address data: ${snapshot.data!.docs[index].data()}");
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
                                if (!showAllAddresses && snapshot.data!.docs.length > 1)
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
                ],
              ),
            );
          }
        },
      ),
    );
  }

}
