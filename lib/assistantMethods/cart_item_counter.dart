import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import '../global/global.dart';

class CartItemCounter extends ChangeNotifier {
  int _cartListItemCounter = 0; // Initialize the counter to 0
  int get count => _cartListItemCounter; // Getter for the counter

  Future<void> displayCartListItemNumber() async {
    try {
      // Listen for real-time updates to the cart collection
      FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection("cart")
          .snapshots()
          .listen((querySnapshot) {
        if (querySnapshot.docs.isEmpty) {
          _cartListItemCounter = 0;
        } else {
          _cartListItemCounter = querySnapshot.size;
        }


        // Notify listeners
        notifyListeners();
      });

    } catch (e) {
      print("Error fetching cart items: $e");
      _cartListItemCounter = 0;
    }
  }


}


