import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_foodtogo/lib/theme/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';

import '../mainScreen/myMap.dart';
import '../mainScreen/my_order_screen.dart';
import '../models/address.dart';
import '../splashScreen/splash_screen.dart';

class ShipmentAddressDesign extends StatefulWidget {
  final Address? model;
  String? purchaserId;
  String? sellerId;
  String? orderID;
  String? purchaserAddress;
  double? purchaserLat;

  double? purchaserLng;
  String? riderName;

  ShipmentAddressDesign({
    this.model,
    this.purchaserId,
    this.sellerId,
    this.orderID,
    this.purchaserAddress,
    this.purchaserLat,

    this.riderName,
    this.purchaserLng,
  });

  @override
  State<ShipmentAddressDesign> createState() => _ShipmentAddressDesignState();
}

class _ShipmentAddressDesignState extends State<ShipmentAddressDesign> {
  final loc.Location location = loc.Location();
  StreamSubscription<loc.LocationData>? _locationSubscription;

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  // Future<Map<String, dynamic>> fetchRiderLocation() async {
  //   try {
  //     DocumentSnapshot snapshot = await FirebaseFirestore.instance
  //         .collection('orders')
  //         .doc(widget.orderID!) // Assuming 'orderID' is the document ID
  //         .get();
  //
  //     return snapshot.data() as Map<String, dynamic>;
  //   } catch (e) {
  //     print("Error fetching rider location: $e");
  //     return {};
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              'Shipping Details:',
              style: TextStyle(
                color: Colors.black,
                fontFamily: "Poppins",
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(
            height: 6.0,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 90, vertical: 5),
            width: MediaQuery.of(context).size.width,
            child: Table(
              children: [
                TableRow(
                  children: [
                    const Text(
                      "Name",
                      style: TextStyle(color: Colors.black),
                    ),
                    Text(widget.model!.name!, style: TextStyle(fontFamily: "Poppins")),
                  ],
                ),
                TableRow(
                  children: [
                    const Text(
                      "Phone Number",
                      style: TextStyle(color: Colors.black),
                    ),
                    Text(widget.model!.phoneNumber!, style: TextStyle(fontFamily: "Poppins")),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10.h,
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              widget.model!.fullAddress!,
              textAlign: TextAlign.justify,
              style: TextStyle(fontFamily: "Poppins"),
            ),
          ),
          Divider(thickness: 4,),

          Container(
            height: 100.h,
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection("location").limit(1).snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                    itemCount: snapshot.data?.docs.length ?? 0,
                    itemBuilder: (context, index) {
                  if (snapshot.data?.docs == null || index >= snapshot.data!.docs.length) {
                    return Container(); // or any other widget indicating the absence of data
                  }
                  return Padding(
                    padding: EdgeInsets.all(8),
                    child: Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => MyMap(
                                user_id: snapshot.data!.docs[index].id,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Color(0xFF31572c),
                          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.navigation_outlined, color: Color(0xFFFFFFFF)),
                            Text(
                              "Track Order",
                              style: TextStyle(color: Colors.white, fontSize: 14.sp, fontFamily: "Poppins"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
    );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyOrderScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  primary: AppColors().red,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_back, color: AppColors().white),
                    Text(
                      "Go Back",
                      style: TextStyle(color: Colors.white, fontSize: 14.sp, fontFamily: "Poppins"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _requestPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      print('done');
    } else if (status.isDenied) {
      _requestPermission();
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }
}
