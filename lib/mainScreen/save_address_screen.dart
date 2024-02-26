import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../CustomersWidgets/text_field.dart';
import '../theme/colors.dart';
import '../global/global.dart';
import '../models/address.dart';
import '../CustomersWidgets/dimensions.dart';
import '../mainScreen/check_out.dart'; // Importing CheckOut screen if not already imported

class SaveAddressScreen extends StatefulWidget {
  @override
  _SaveAddressScreenState createState() => _SaveAddressScreenState();
}

class _SaveAddressScreenState extends State<SaveAddressScreen> {
  final _name = TextEditingController();
  final _phoneNumber = TextEditingController(text: '+63'); // Prefixing with +63
  final _locationController = TextEditingController();
  final _state = TextEditingController();
  final _city = TextEditingController();
  final _flatNumber = TextEditingController();
  final _completeAddress = TextEditingController();
  final _postalCode = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  List<Placemark>? placemarks;
  Position? position;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors().red,
        title: Text(
          "New Address",
          style: TextStyle(
            fontFamily: "Poppins",
            fontSize: 14,
            color: AppColors().white,
          ),
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
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  "Address",
                  style: TextStyle(
                    color: AppColors().black1,
                    fontSize: 12,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.pin_drop,
                color: AppColors().black,
                size: 20,
              ),
              title: Container(
                width: 300,
                child: TextField(
                  style: const TextStyle(color: Colors.black87),
                  controller: _locationController,
                  decoration: InputDecoration(
                    hintText: "What's your address?",
                    hintStyle: TextStyle(fontFamily: "Poppins", fontSize: 12),
                  ),
                  onEditingComplete: () {},
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                await getUserLocationAddress();
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
                backgroundColor: MaterialStateProperty.all<Color>(AppColors().endColor),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  MyTextField(
                    hint: "Full Name",
                    controller: _name,
                    keyboardType: TextInputType.text,
                  ),
                  MyTextField(
                    hint: "Phone Number",
                    controller: _phoneNumber,
                    keyboardType: TextInputType.phone,
                    maxLength: 14, // Setting maximum length
                    validator: phoneNumberValidator,
                  ),
                  MyTextField(
                    hint: "Address Line",
                    controller: _flatNumber,
                    keyboardType: TextInputType.text,
                  ),
                  MyTextField(
                    hint: "City/Municipality",
                    controller: _city,
                    keyboardType: TextInputType.text,
                  ),
                  MyTextField(
                    hint: "State/Country",
                    controller: _state,
                    keyboardType: TextInputType.text,
                  ),
                  MyTextField(
                    hint: "Postal Code",
                    controller: _postalCode,
                    keyboardType: TextInputType.number,
                    validator: postalCodeValidator,
                  ),
                  MyTextField(
                    hint: "Complete Address",
                    controller: _completeAddress,
                    keyboardType: TextInputType.text,
                  ),
                ],
              ),
            ),
            Container(
              width: 200,
              child: ElevatedButton(
                onPressed: () {



                  if (_formKey.currentState!.validate()) {
                    final model = Address(
                      name: _name.text.trim(),
                      phoneNumber: _phoneNumber.text.trim(),
                      flatNumber: _flatNumber.text.trim(),
                      city: _city.text.trim(),
                      state: _state.text.trim(),
                      postalCode: _postalCode.text.trim(),
                      fullAddress: _completeAddress.text.trim(),
                      lat: position!.latitude,
                      lng: position!.longitude,
                    ).toJson();

                    FirebaseFirestore.instance
                        .collection("users")
                        .doc(sharedPreferences!.getString("uid"))
                        .collection("userAddress")
                        .doc(DateTime.now().millisecondsSinceEpoch.toString())
                        .set(model)
                        .then((value) {
                      Fluttertoast.showToast(msg: "New Address has been saved.");
                      _formKey.currentState!.reset();
                    });
                  }


                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(AppColors().red),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                child: Text(
                  "Submit",
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: "Poppins",
                    color: AppColors().white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getUserLocationAddress() async {
    Position newPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
    position = newPosition;
    placemarks = await placemarkFromCoordinates(
      position!.latitude,
      position!.longitude,
    );

    if (placemarks != null && placemarks!.isNotEmpty) {
      Placemark pMark = placemarks![0];

      // Construct the full address
      String fullAddress =
          '${pMark.subThoroughfare ?? ''} ${pMark.thoroughfare ?? ''}, ${pMark.subLocality ?? ''}, ${pMark.locality ?? ''}, ${pMark.subAdministrativeArea ?? ''}, ${pMark.administrativeArea ?? ''}, ${pMark.postalCode ?? ''}, ${pMark.country ?? ''}';

      setState(() {
        _locationController.text = fullAddress;
        _flatNumber.text =
        '${pMark.subThoroughfare ?? ''} ${pMark.thoroughfare ?? ''}, ${pMark.subLocality ?? ''}, ${pMark.locality ?? ''}';
        _city.text = '${pMark.subAdministrativeArea ?? ''}, ${pMark.administrativeArea ?? ''}';
        _state.text = '${pMark.country ?? ''}';
        _postalCode.text = pMark.postalCode ?? '';
        _completeAddress.text = fullAddress;
      });
    } else {
      print('Placemarks not found.');
    }
  }

  String? postalCodeValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Postal code is required';
    }
    if (value != '5208') {
      return 'Invalid postal Code';
    }
    return null;
  }

  String? phoneNumberValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (!value.startsWith('+63')) {
      return 'Must be valid number';
    }
    if (value.length != 13) {
      return 'Phone number must be 13 digits including +63';
    }
    return null;
  }
}
