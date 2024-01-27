import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import '../global/global.dart';

class AddressChanger with ChangeNotifier {
  int _counter = 0;
  int get count => _counter;

  displayResult(dynamic newValue) {
    _counter = newValue;
    notifyListeners();
  }

  Future<void> deleteAddress(String addressId) async {
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(sharedPreferences!.getString("uid"))
          .collection("userAddress")
          .doc(addressId)
          .delete();

      // If you have additional logic after deletion, you can place it here.

      notifyListeners();
    } catch (error) {
      print("Error deleting address: $error");
    }
  }
}

class SelectedAddress with ChangeNotifier {
  int? selectedAddressIndex;

  void selectAddress(int index) {
    selectedAddressIndex = index;
    notifyListeners();
  }
}
