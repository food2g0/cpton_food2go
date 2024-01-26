import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';

import '../mainScreen/myMap.dart';
import '../mainScreen/my_order_screen.dart';
import '../models/address.dart';
import '../splashScreen/splash_screen.dart';

class ShipmentAddressDesign extends StatefulWidget {
  final Address? model;

  ShipmentAddressDesign({this.model});

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
    // location.changeSettings(interval: 300, accuracy: loc.LocationAccuracy.high);
    // location.enableBackgroundMode(enable: true);
  }

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
              style: TextStyle(color: Colors.black,fontFamily: "Poppins", fontWeight: FontWeight.bold),
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
                    Text(widget.model!.name!,style: TextStyle(fontFamily: "Poppins"),),
                  ],
                ),
                TableRow(
                  children: [
                    const Text(
                      "Phone Number",
                      style: TextStyle(color: Colors.black),
                    ),
                    Text(widget.model!.phoneNumber!,style: TextStyle(fontFamily: "Poppins"),),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
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
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Center(
              child: InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>  MyOrderScreen()));
                },
                child: Container(
                  decoration: const BoxDecoration(
                      color: Color(0xFF890010),),
                  width: MediaQuery.of(context).size.width - 40,
                  height: 50,
                  child: const Center(
                    child: Text(
                      "Go Back",
                      style: TextStyle(color: Colors.white, fontSize: 15.0,
                      fontFamily: "Poppins"),
                    ),
                  ),
                ),
              ),
            ),
          ),




          StreamBuilder(
              stream: FirebaseFirestore.instance.collection('location').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                  shrinkWrap: true, // Set shrinkWrap to true
                  itemCount: snapshot.data?.docs.length,
                  itemBuilder: (context, index) {

                    return ListTile(
                      subtitle: Row(
                        children: [
                          Text(snapshot.data!.docs[index]['latitude']
                              .toString()),
                          SizedBox(
                            width: 20,
                          ),
                          Text(snapshot.data!.docs[index]['longitude']
                              .toString()),
                        ],
                      ),
                      trailing: IconButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => MyMap(snapshot.data!.docs[index].id)));
                        },
                        icon: Icon(Icons.directions),
                      ),
                    );
                  },
                );
              }),


        ],
      ),
    );
  }


  Future<void> _listenLocation() async {
    _locationSubscription = location.onLocationChanged.handleError((onError) {
      print(onError);
      _locationSubscription?.cancel();
      setState(() {
        _locationSubscription = null;
      });
    }).listen((loc.LocationData currentlocation) async {
      await FirebaseFirestore.instance.collection('location').doc('user1').set({
        'latitude': currentlocation.latitude,
        'longitude': currentlocation.longitude,

      }, SetOptions(merge: true));
    });
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
