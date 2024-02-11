import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_foodtogo/lib/assistantMethods/total_ammount.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../global/global.dart';
import 'cart_item_counter.dart';


separateOrderItemIDs(orderId)
{
  List<String> separateItemIDsList=[], defaultItemList=[];
  int i=0;

  defaultItemList = List<String>.from(orderId ?? []);


  for(i; i<defaultItemList.length; i++)
  {
    //56557657:7
    String item = defaultItemList[i].toString();
    var pos = item.lastIndexOf(":");

    //56557657
    String getItemId = (pos != -1) ? item.substring(0, pos) : item;



    separateItemIDsList.add(getItemId);
  }



  return separateItemIDsList;
}

separateItemIDs()
{
  List<String> separateItemIDsList=[], defaultItemList=[];
  int i=0;

  defaultItemList = sharedPreferences!.getStringList("userCart")!;

  for(i; i<defaultItemList.length; i++)
  {
    //56557657:7
    String item = defaultItemList[i].toString();
    var pos = item.lastIndexOf(":");

    //56557657
    String getItemId = (pos != -1) ? item.substring(0, pos) : item;
    //
    // if (kDebugMode) {
    //   print("\nThis is itemID now = $getItemId");
    // }

    separateItemIDsList.add(getItemId);
  }

  // if (kDebugMode) {
  //   print("\nThis is Items List now = ");
  // }
  // if (kDebugMode) {
  //   print(separateItemIDsList);
  // }

  return separateItemIDsList;
}

void addItemToCart(
    String? foodItemId,
    BuildContext context,
    int itemCounter,
    String? thumbnailUrl,
    String? productTitle,
    double price,
    ) async {
  try {
    // Get the current user
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Handle case where user is not authenticated
      return;
    }

    // Reference to the user's cart collection
    CollectionReference cartCollection = FirebaseFirestore.instance.collection("users").doc(user.uid).collection("cart");

    // Query to check if the foodItemId already exists in the cart
    QuerySnapshot querySnapshot = await cartCollection.where("foodItemId", isEqualTo: foodItemId).get();

    if (querySnapshot.docs.isNotEmpty) {
      // Item already exists in the cart, show a message
      Fluttertoast.showToast(msg: "Item is already in the cart");
      return;
    }

    // Generate a unique cart ID
    String cartID = cartCollection.doc().id;

    // Create a new cart item object
    Map<String, dynamic> cartItem = {
      "cartID": cartID,
      "foodItemId": foodItemId,
      "itemCounter": itemCounter,
      "thumbnailUrl": thumbnailUrl,
      "productTitle": productTitle,
      "productPrice": price,
      // Add other properties as needed
    };

    // Add the cart item to the cart collection
    await cartCollection.doc(cartID).set(cartItem);

    // Show success message
    Fluttertoast.showToast(msg: "Item Added Successfully.");

    // Update the badge
    Provider.of<CartItemCounter>(context, listen: false).displayCartListItemNumber();
  } catch (error) {
    print("Error adding item to cart: $error");
    // Handle error as needed
  }
}


addItemToCartnoItemCounter(String? foodItemId, BuildContext context)
{
  List<String>? tempList = sharedPreferences!.getStringList("userCart");
  tempList!.add(foodItemId!); //56557657:7

  FirebaseFirestore.instance.collection("users")
      .doc(firebaseAuth.currentUser!.uid).update({
    "userCart": tempList,
  }).then((value)
  {
    Fluttertoast.showToast(msg: "Item Added Successfully.");

    sharedPreferences!.setStringList("userCart", tempList);

    //update the badge
    Provider.of<CartItemCounter>(context, listen: false).displayCartListItemNumber();
  });
}
separateOrderItemQuantities(orderID)
{
  List<String> separateItemQuantityList=[];
  List<String> defaultItemList=[];
  int i=1;

  defaultItemList = List<String>.from(orderID);

  for(i; i<defaultItemList.length; i++)
  {
    //56557657:7
    String item = defaultItemList[i].toString();


    //0=:
    //1=7
    //:7
    List<String> listItemCharacters = item.split(":").toList();

    //7
    var quanNumber = int.parse(listItemCharacters[1].toString());

    // if (kDebugMode) {
    //   print("\nThis is Quantity Number = $quanNumber");
    // }

    separateItemQuantityList.add(quanNumber.toString());
  }

  // if (kDebugMode) {
  //   print("\nThis is Quantity List now = ");
  // }
  // if (kDebugMode) {
  //   print(separateItemQuantityList);
  // }

  return separateItemQuantityList;
}



separateItemQuantities()
{
  List<int> separateItemQuantityList=[];
  List<String> defaultItemList=[];
  int i=1;

  defaultItemList = sharedPreferences!.getStringList("userCart")!;

  for(i; i<defaultItemList.length; i++)
  {
    //56557657:7
    String item = defaultItemList[i].toString();


    //0=:
    //1=7
    //:7
    List<String> listItemCharacters = item.split(":").toList();

    //7
    var quanNumber = int.parse(listItemCharacters[1].toString());

    // if (kDebugMode) {
    //   print("\nThis is Quantity Number = $quanNumber");
    // }

    separateItemQuantityList.add(quanNumber);
  }

  // if (kDebugMode) {
  //   print("\nThis is Quantity List now = ");
  // }
  // if (kDebugMode) {
  //   print(separateItemQuantityList);
  // }

  return separateItemQuantityList;
}




void clearCartNow(BuildContext context) {
  FirebaseFirestore.instance
      .collection("users")
      .doc(firebaseAuth.currentUser!.uid)
      .collection("cart")
      .get()
      .then((querySnapshot) {
    querySnapshot.docs.forEach((doc) {
      doc.reference.delete();
    });
  }).then((_) {
    Provider.of<CartItemCounter>(context, listen: false).displayCartListItemNumber();
    Provider.of<TotalAmount>(context, listen: false).updateSubtotal(0); // Update subtotal to 0 after clearing the cart
  }).catchError((error) {
    print("Failed to clear cart: $error");
  });
}

void removeCartItemFromCart(String cartID, BuildContext context) {
  // Remove the cart item from Firestore
  FirebaseFirestore.instance
      .collection("users")
      .doc(firebaseAuth.currentUser!.uid)
      .collection("cart")
      .doc(cartID)
      .delete()
      .then((_) {
    // Show success message
    Fluttertoast.showToast(msg: "Item removed from cart.");

    // Update the local cart if needed
    // Not required in this scenario as we are not updating any local cart list

    // Notify listeners to update the UI
    Provider.of<CartItemCounter>(context, listen: false).displayCartListItemNumber();
  }).catchError((error) {
    // Handle error
    print("Error removing item from cart: $error");
    // You can show an error message or handle the error as needed
  });
}














class CartManager {
  SharedPreferences? _sharedPreferences;

  CartManager(this._sharedPreferences);

  void updateItemQuantity(String productId, int newQuantity) {
    List<String>? defaultItemList = _sharedPreferences!.getStringList("userCart");
    List<String> updatedItemList = [];

    if (defaultItemList != null) {
      for (String item in defaultItemList) {
        List<String> listItemCharacters = item.split(":");
        String currentProductId = listItemCharacters[0];

        if (currentProductId == productId) {
          listItemCharacters[1] = newQuantity.toString();
        }

        updatedItemList.add(listItemCharacters.join(":"));
      }

      _sharedPreferences!.setStringList("userCart", updatedItemList);
    }
  }

  List<int> separateItemQuantities() {
    List<int> separateItemQuantityList = [];
    List<String>? defaultItemList = _sharedPreferences!.getStringList("userCart");

    if (defaultItemList != null) {
      for (String item in defaultItemList) {
        List<String> listItemCharacters = item.split(":");
        int quanNumber = int.parse(listItemCharacters[1]);
        separateItemQuantityList.add(quanNumber);
      }
    }

    return separateItemQuantityList;
  }
}