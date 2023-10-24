import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_foodtogo/lib/CustomersWidgets/text_field.dart';
import 'package:cpton_foodtogo/lib/global/global.dart';
import 'package:cpton_foodtogo/lib/models/address.dart';
import 'package:cpton_foodtogo/lib/theme/colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../CustomersWidgets/dimensions.dart';

class SaveAddressScreen extends StatelessWidget {
  final _name = TextEditingController();
  final _phoneNumber = TextEditingController();
  final _locationController = TextEditingController();
  final _state = TextEditingController();
  final _city = TextEditingController();
  final _flatNumber = TextEditingController();
  final _completeAddress = TextEditingController();
  final formKey = GlobalKey<FormState>();
  List<Placemark>? placemarks;
  Position? position;


  getUserLocationAddress() async
  {
    Position newPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    position = newPosition;
    placemarks =  await placemarkFromCoordinates(position!.latitude, position!.longitude);

    Placemark pMark = placemarks![0];

    String fullAddress = '${pMark.subThoroughfare} ${pMark.thoroughfare}, ${pMark.subLocality}, ${pMark.locality}, ${pMark.subAdministrativeArea}, ${pMark.administrativeArea}, ${pMark.postalCode}, ${pMark.country}';

    _locationController.text = fullAddress;
    _flatNumber.text = '${pMark.subThoroughfare} ${pMark.thoroughfare}, ${pMark.subLocality}, ${pMark.locality}';
    _city.text = '${pMark.subAdministrativeArea}, ${pMark.administrativeArea},';
    _state.text = '${pMark.country}';
    _city.text = '${pMark.postalCode}';
    _completeAddress.text = fullAddress;

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF890010),
        title: const Text(
          "New Address",
          style: TextStyle(fontFamily: "Poppins"),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  "Contact",
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: Dimensions.font14,
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
            Form(
              key: formKey,
              child: Column(
                children: [
                  MyTextField(
                    hint: "Full Name",
                    controller: _name,
                  ),
                  MyTextField(
                    hint: "Phone Number",
                    controller: _phoneNumber,
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  "Address",
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: Dimensions.font14,
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.pin_drop,
                color: Colors.black87,
                size: 35,
              ),
              title: Container(
                width: 300,
                child: TextField(
                  style: const TextStyle(color: Colors.black87),
                  controller: _locationController,
                  decoration: const InputDecoration(
                      hintText: "Whats your address?",
                      hintStyle: TextStyle(fontFamily: "Poppins")),
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: ()
              {
                getUserLocationAddress();
              },
              icon: const Icon(
                Icons.location_on,
                color: Colors.amber,
              ),
              label: const Text(
                "Get my current location",
                style: TextStyle(color: Colors.white, fontFamily: "Poppins"),
              ),
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStatePropertyAll<Color>(AppColors().endColor),
                  shape: MaterialStatePropertyAll<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  )),
            ),
            MyTextField(
              hint: "Address Line",
              controller: _flatNumber,
            ),
            MyTextField(
              hint: "City/Municipality",
              controller: _city,
            ),
            MyTextField(
              hint: "State/Country",
              controller: _state,
            ),

            MyTextField(
              hint: "Complete Address",
              controller: _completeAddress,
            ),
            Container(
              width: 200,
              child: ElevatedButton(
                onPressed: ()
                {
                  if(formKey.currentState!.validate())
                  {
                    final model = Address(
                      name: _name.text.trim(),
                      phoneNumber: _phoneNumber.text.trim(),
                      flatNumber: _flatNumber.text.trim(),
                      city: _city.text.trim(),
                      state: _state.text.trim(),
                      fullAddress: _completeAddress.text.trim(),
                      lat: position!.latitude,
                      lng: position!.longitude,
                    ).toJson();

                    FirebaseFirestore.instance.collection("users")
                        .doc(sharedPreferences!.getString("uid"))
                        .collection("userAddress").doc(DateTime.now()
                        .millisecondsSinceEpoch.toString()).set(model).then((value)
                    {
                      Fluttertoast.showToast(msg: "New Address has been saved.");
                      formKey.currentState!.reset();
                    });
                  }
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(AppColors().endColor),
                  // Change the color here
                ),
                child: Text(
                  "Submit",
                  style: TextStyle(
                    fontSize: Dimensions.font16,
                    fontFamily: "Poppins",
                  ),
                ),
              ),
            )

          ],
        ),
      ),
    );
  }
}
