import 'package:cloud_firestore/cloud_firestore.dart';
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

addItemToCart(String? foodItemId, BuildContext context, int itemCounter)
{
  List<String>? tempList = sharedPreferences!.getStringList("userCart");
  tempList!.add("${foodItemId!}:$itemCounter"); //56557657:7

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




clearCartNow(context)
{
  sharedPreferences!.setStringList("userCart", ['garbageValue']);
  List<String>? emptyList = sharedPreferences!.getStringList("userCart");

  FirebaseFirestore.instance
      .collection("users")
      .doc(firebaseAuth.currentUser!.uid)
      .update({"userCart": emptyList}).then((value)
  {
    sharedPreferences!.setStringList("userCart", emptyList!);
    Provider.of<CartItemCounter>(context, listen: false).displayCartListItemNumber();
  });
}
removeSelectedProductsFromCart(List<String> productIdsToRemove, context) {
  List<String>? currentCart = sharedPreferences!.getStringList("userCart");

  if (currentCart != null) {
    // Remove selected product IDs from the current cart
    currentCart.removeWhere((productId) {
      // Extract item ID (excluding quantity)
      var pos = productId.lastIndexOf(":");
      String getItemId = (pos != -1) ? productId.substring(0, pos) : productId;

      // Check if the extracted item ID is in the list of product IDs to remove
      return productIdsToRemove.contains(getItemId);
    });

    // Update Firestore and SharedPreferences
    FirebaseFirestore.instance
        .collection("users")
        .doc(firebaseAuth.currentUser!.uid)
        .update({"userCart": currentCart}).then((value) {
      sharedPreferences!.setStringList("userCart", currentCart);
      Provider.of<CartItemCounter>(context, listen: false).displayCartListItemNumber();
    });
  }
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
