import 'dart:async';
import 'package:cpton_foodtogo/lib/mainScreen/RatingScreen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_foodtogo/lib/theme/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';
import '../mainScreen/myMap.dart';
import '../mainScreen/my_order_screen.dart';
import '../models/address.dart';
import '../splashScreen/splash_screen.dart';

class DeliveredShipmentAddressDesign extends StatefulWidget {
  final Address? model;
  String? purchaserId;
  String? sellerUID;
  String? orderID;
  String? purchaserAddress;
  double? purchaserLat;
  String? getOrderID;
  double? purchaserLng;
  String? riderName;
  String? riderUID;
  String? orderByUser;
  String? productsIDs;

  DeliveredShipmentAddressDesign({
    this.model,
    this.purchaserId,
    this.sellerUID,
    this.orderID,
    this.purchaserAddress,
    this.purchaserLat,
    this.getOrderID,
    this.riderName,
    this.purchaserLng,
    this.riderUID,
    this.orderByUser,
    this.productsIDs,
  });

  @override
  State<DeliveredShipmentAddressDesign> createState() => _DeliveredShipmentAddressDesignState();
}

class _DeliveredShipmentAddressDesignState extends State<DeliveredShipmentAddressDesign> {
  final loc.Location location = loc.Location();
  StreamSubscription<loc.LocationData>? _locationSubscription;

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(10.0),
            child: Text('Shipping Details:', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontFamily: "Poppins")),
          ),
          SizedBox(height: 6.0.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 5.h),
            width: MediaQuery.of(context).size.width,
            child: Table(
              children: [
                TableRow(
                  children: [
                    Text("Name : ", style: TextStyle(color: Colors.black, fontFamily: "Poppins", fontSize: 12.sp)),
                    Text(widget.model!.name!, style: TextStyle(color: Colors.black, fontFamily: "Poppins", fontSize: 12.sp)),
                  ],
                ),
                TableRow(
                  children: [
                    Text("Phone Number : ", style: TextStyle(color: Colors.black, fontFamily: "Poppins", fontSize: 12.sp)),
                    Text(widget.model!.phoneNumber!, style: TextStyle(color: Colors.black, fontFamily: "Poppins", fontSize: 12.sp)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              widget.model!.fullAddress!,
              style: TextStyle(
                fontFamily: "Poppins",
                fontSize: 12.sp,
              ),
            ),
          ),
          Divider(thickness: 4),
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
                      padding: EdgeInsets.all(8.w),
                      child: Center(
                        child: ElevatedButton(
                          onPressed: () {
                            fetchData(); // Fetch data when the button is pressed
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Color(0xFF31572c),
                            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.rate_review, color: Color(0xFFFFFFFF)),
                              Text("Rate Now", style: TextStyle(color: Colors.white, fontSize: 14.sp, fontFamily: "Poppins")),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
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
                    Text("Go Back", style: TextStyle(color: Colors.white, fontSize: 14.sp, fontFamily: "Poppins")),
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

  // Fetch data for orderID
  Future<void> fetchData() async {
    DocumentSnapshot orderSnapshot = await FirebaseFirestore.instance
        .collection("orders").doc(widget.orderID).get();
    if (orderSnapshot.exists) {
      var orderID = orderSnapshot["orderId"];
      var riderUID = orderSnapshot["riderUID"];
      var productsIDs = orderSnapshot["productsIDs"];
      var sellerUID = orderSnapshot["sellerUID"];

      if (sellerUID is String && productsIDs is List<dynamic>) {
        // Extracting only the valid IDs from productsIDs list
        List<String> itemIDs = [];

        for (var productID in productsIDs) {
          if (productID is String && productID != "garbageValue") {
            var pos = productID.lastIndexOf(":");
            var validID = (pos != -1) ? productID.substring(0, pos) : productID;
            itemIDs.add(validID);
          }
        }

        String productsIDString = itemIDs.join(', ');

        print("riderUID: ${riderUID}");
        print("productsIDs: ${productsIDString}");
        print("sellerUID: ${sellerUID}");

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RatingScreen(
              orderID: orderID,
              riderUID: riderUID,
              productsID: productsIDString,
              sellerUID: sellerUID,
            ),
          ),
        );
      } else {
        print("sellerUID is not a String or productsIDs is not a List<dynamic>");
        // Handle the case where sellerUID is not a String or productsIDs is not a List<dynamic>
      }
    }
  }


}
