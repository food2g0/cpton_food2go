import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';

import '../mainScreen/menu_screen.dart';
import '../models/menus.dart';
import '../theme/colors.dart';
import 'dimensions.dart';

class InfoDesignWidget extends StatefulWidget {
  final Menus? model;
  final BuildContext? context;

  const InfoDesignWidget({Key? key, this.model, this.context}) : super(key: key);

  @override
  State<InfoDesignWidget> createState() => _InfoDesignWidgetState();
}

class _InfoDesignWidgetState extends State<InfoDesignWidget> {
  Position? _currentUserPosition;
  double? distanceInMeter = 0.0;

  Future _getDistance(double storeLat, double storeLng) async {
    _currentUserPosition =
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    distanceInMeter = await Geolocator.distanceBetween(
      _currentUserPosition!.latitude,
      _currentUserPosition!.longitude,
      storeLat,
      storeLng,
    );


  }

  @override
  void initState() {
    super.initState();
    _fetchStoreLocation();
  }

  Future<void> _fetchStoreLocation() async {
    // Fetch the store location from Firestore collection
    DocumentSnapshot storeSnapshot = await FirebaseFirestore.instance
        .collection('sellers')
        .doc(widget.model!.sellersUID)
        .get();

    if (storeSnapshot.exists) {
      Map<String, dynamic> storeData = storeSnapshot.data() as Map<String, dynamic>;
      double storeLat = storeData['lat'];
      double storeLng = storeData['lng'];
      await _getDistance(storeLat, storeLng); // Wait for _getDistance to complete
      print("Distance between user and store: $distanceInMeter meters"); // Print distance
    } else {
      print('Store not found in Firestore');
    }
  }










  @override
  Widget build(BuildContext context) {
    double containerHeight = 200;
    double imageBorderRadius = 10.0; // Set the desired border radius

    IconData statusIcon = Icons.circle; // Default icon for status
    Color statusColor = Colors.green; // Default color for status text

    if (widget.model!.Open == 'open') {
      statusIcon = Icons.circle; // Change this to your active icon
      statusColor = Colors.green; // Change the color as needed
    } else if (widget.model!.Open == 'close') {
      statusIcon = Icons.circle; // Change this to your inactive icon
      statusColor = Colors.red; // Change the color as needed
    }

    return SizedBox(
      child: Container(
        child: InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (c) => MenuScreen(model: widget.model, sellersName: widget.model!.sellersName,)));
          },
          child: Padding(
            padding: EdgeInsets.all(12.0.w),
            child: SizedBox(
              width: 250.w,
              height: containerHeight,
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: ClipRRect( // Wrap the image with ClipRRect
                        borderRadius: BorderRadius.circular(imageBorderRadius),
                        child: Image.network(
                          widget.model!.sellersImageUrl!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Center(
                      child: Container(
                        padding: EdgeInsets.all(8.0.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.fastfood, // Replace with your desired icon
                                  color: AppColors().red,
                                  size: 12.sp,
                                ),
                                SizedBox(width: 4.w), // Add spacing between the icon and text
                                Expanded(
                                  child: Text(
                                    widget.model!.sellersName!,
                                    style: TextStyle(
                                      color: AppColors().black1,
                                      fontFamily: "Poppins",
                                      fontWeight: FontWeight.w600,
                                      fontSize: 9.sp,
                                    ),
                                    overflow: TextOverflow.ellipsis, // Add ellipsis when text overflows
                                  ),
                                ),
                                Icon(
                                  statusIcon,
                                  color: statusColor,
                                  size: 12.sp,
                                ),
                                SizedBox(width: 2.w), // Add spacing between the icon and text
                                Text(
                                  widget.model!.Open == 'open' ? 'Open' : 'Close',
                                  style: TextStyle(
                                    color: statusColor,
                                    fontFamily: "Poppins",
                                    fontWeight: FontWeight.w600,
                                    fontSize: 9.sp,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4.h), // Add spacing between seller's name/status and distance
                            if (distanceInMeter != null) // Display distance if available
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Distance: ${distanceInMeter!.toStringAsFixed(2)} meters',
                                  style: TextStyle(
                                    color: AppColors().black1,
                                    fontFamily: "Poppins",
                                    fontWeight: FontWeight.w500,
                                    fontSize: 9.sp,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

  }
}


