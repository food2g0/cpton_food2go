import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;

class MyMap extends StatefulWidget {


  final String user_id;

  MyMap({

    required this.user_id,

  });

  @override
  _MyMapState createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {
  final loc.Location location = loc.Location();
  late double destinationLatitude;
  late double destinationLongitude;
  late double originlatitude;
  late double originlongitude;
  StreamSubscription<loc.LocationData>? _locationSubscription;
  GoogleMapController? _googleMapController;
  Marker? _origin;

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscribeToLocationUpdates();
    // _fetchLocationData(); // Add this line
  }

  @override
  void dispose() {
    _locationSubscription?.cancel(); // Add this line
    super.dispose();
  }

  Future<void> _subscribeToLocationUpdates() async {
    FirebaseFirestore.instance
        .collection('location')
        .doc(widget.user_id)
        .snapshots()
        .listen((DocumentSnapshot snapshot) {
      _updateUserLocationOnMap(snapshot);
    });
  }

  Future<void> _updateUserLocationOnMap(DocumentSnapshot snapshot) async {
    double originlatitude = snapshot['latitude1'];
    double originlongitude = snapshot['longitude1'];

    setState(() {
      _origin = Marker(
        markerId: const MarkerId('origin'),
        infoWindow: const InfoWindow(title: 'Origin'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        position: LatLng(originlatitude, originlongitude),
      );

      if (_googleMapController != null) {
        _googleMapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(originlatitude, originlongitude),
              zoom: 15.0,
              tilt: 45.0,
            ),
          ),
        );
      }
    });
  }
  Set<Marker> _getMarkers() {
    final Set<Marker> markers = {};

    if (_origin != null) markers.add(_origin!);


    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF890010),
        title: Text(
          "Track Order",
          style: TextStyle(
            color: Colors.white,
            fontFamily: "Poppins",
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              mapType: MapType.normal,
              onMapCreated: (controller) {
                _googleMapController = controller;
              },
              markers: _getMarkers(),

              initialCameraPosition: const CameraPosition(
                target: LatLng(0.0, 0.0),
              ),
            ),
          ),
          Card(
            elevation: 5.0,
            margin: EdgeInsets.all(16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Rider's Name: John Doe",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Poppins",
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }




  // Future<void> _updateUserLocation(double latitude, double longitude) async {
  //   try {
  //     await FirebaseFirestore.instance.collection('location').doc(widget.user_id).set(
  //       {
  //         'latitude1': latitude,
  //         'longitude1': longitude,
  //       },
  //       SetOptions(merge: true),
  //     );
  //   } catch (e) {
  //     print("Error updating user location: $e");
  //   }
  // }



  // Future<void> _fetchLocationData() async {
  //   try {
  //     _locationSubscription = location.onLocationChanged.listen((loc.LocationData currentlocation) async {
  //       await _updateUserLocation(currentlocation.latitude!, currentlocation.longitude!);
  //     });
  //   } catch (e) {
  //     print("Error fetching location data: $e");
  //   }
  // }
}
