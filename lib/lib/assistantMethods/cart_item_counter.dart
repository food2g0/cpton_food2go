import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import '../global/global.dart';

class CartItemCounter extends ChangeNotifier {
  int _cartListItemCounter = 0; // Initialize the counter to 0
  int get count => _cartListItemCounter; // Getter for the counter

  Future<void> displayCartListItemNumber() async {
    try {
      QuerySnapshot cartSnapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(firebaseAuth.currentUser!.uid)
          .collection("cart")
          .get();
      _cartListItemCounter = cartSnapshot.docs.length; // Update the counter with the number of documents in the "cart" collection

      // Notify listeners after a delay
      await Future.delayed(const Duration(milliseconds: 100), () {
        notifyListeners();
      });
    } catch (e) {
      print("Error fetching cart items: $e");
      _cartListItemCounter = 0; // Set the counter to 0 if there's an error
    }
  }
}
