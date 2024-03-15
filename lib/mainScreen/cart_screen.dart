import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../CustomersWidgets/cart_item_design.dart';
import '../assistantMethods/assistant_methods.dart';
import '../assistantMethods/total_ammount.dart';
import '../global/global.dart';
import '../models/menus.dart';
import '../theme/colors.dart';
import 'check_out.dart';
import 'home_screen.dart';

class CartScreen extends StatefulWidget {
  final String? sellersUID;
  final Menus? model;
  final double? distanceInKm;
  final double? Function(double)? calculateShippingFee;

  const CartScreen({Key? key, this.sellersUID, this.model, this.calculateShippingFee, this.distanceInKm}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool isEditing = false;
  List<int>? separateItemQuantityList;
  bool isCartEmpty = true; // Initially set to true
  double? defaultShippingFee;

  double? calculateShippingFeeForItem(double distanceInKm) {
    if (widget.calculateShippingFee != null) {
      return widget.calculateShippingFee!(distanceInKm);
    } else {
      // Handle if calculateShippingFee is not provided
      return 0.0;
    }
  }

  @override
  void initState() {
    super.initState();
    calculateShippingFee();
    // Set the initial value of isCartEmpty based on the cart data
    checkCartEmpty();
  }

  void calculateShippingFee() {
    double? defaultShippingFee = calculateShippingFeeForItem(widget.distanceInKm ?? 0.0);
    setState(() {
      // Update the shipping fee
      this.defaultShippingFee = defaultShippingFee;
    });
  }

  Future<void> checkCartEmpty() async {
    QuerySnapshot cartSnapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(firebaseAuth.currentUser!.uid)
        .collection("cart")
        .get();
    setState(() {
      isCartEmpty = cartSnapshot.docs.isEmpty;
    });
  }
  Future<void> deleteCart() async {
    // Delete all documents in the cart collection for the current user
    await FirebaseFirestore.instance
        .collection("users")
        .doc(firebaseAuth.currentUser!.uid)
        .collection("cart")
        .get()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.delete();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double? defaultShippingFee = calculateShippingFeeForItem(widget.distanceInKm ?? 0.0);

    // Check if sellersUID is null
    if (widget.sellersUID == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors().red,
          title: Text("Shopping Cart",
          style: TextStyle(
            fontFamily: "Poppins",
            fontSize: 12.sp
          ),),
          actions: [
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Remove Cart Items", style: TextStyle(
                        color: AppColors().red,
                        fontFamily: "Poppins"
                      ),),
                      content: Text("Are you sure you want to remove all items from the cart?", style: TextStyle(
                          color: AppColors().black,
                          fontFamily: "Poppins"
                      ),),
                      actions: <Widget>[
                        TextButton(
                          child: Text("Cancel", style: TextStyle(
                              color: AppColors().red,
                              fontFamily: "Poppins"
                          ),),
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog
                          },
                        ),
                        TextButton(
                          child: Text("Remove"),
                          onPressed: () async {
                            await deleteCart(); // Delete the cart items
                            Navigator.of(context).pop(); // Close the dialog
                            Navigator.of(context).pop(); // Pop the CartScreen
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
        body: Center(
          child: Text("The seller is not available. Please remove items from the cart."),
        ),
      );
    }

    // Continue with the original build logic
    return Scaffold(
      backgroundColor: AppColors().backgroundWhite,
      appBar: AppBar(
        backgroundColor: AppColors().red,
        title: Text(
          "Shopping Cart",
          style: TextStyle(
            fontFamily: "Poppins",
            color: AppColors().white,
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              clearCartNow(context);
              Navigator.push(context, MaterialPageRoute(builder: (c) => const HomeScreen()));
              Fluttertoast.showToast(msg: "Cart has been cleared.");
            },
            icon: Icon(
              Icons.remove_shopping_cart_outlined,
              size: 20.sp,
              color: AppColors().white,
            ),
          ),
          SizedBox(width: 16.w),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Perform the refresh action, such as fetching updated data
          calculateShippingFee();
          calculateSubtotalAndUpdateTotalAmount(context);// Example: replace fetchData with your actual data fetching method
        },
        child: CustomScrollView(
          slivers: [
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .doc(firebaseAuth.currentUser!.uid)
                  .collection("cart")
                  .snapshots(),
              builder: (context, cartSnapshot) {
                if (cartSnapshot.connectionState == ConnectionState.waiting) {
                  return SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
                }

                // Check if the cart is empty
                bool isCartEmpty = cartSnapshot.data!.docs.isEmpty;

                return isCartEmpty
                    ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Your cart is empty.",
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors().black1,
                            fontFamily: "Poppins",
                          ),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (c) => const HomeScreen()));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors().red,
                            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text(
                            "Start Shopping",
                            style: TextStyle(fontSize: 12.sp, fontFamily: "Poppins", color: AppColors().white),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                    : SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      var cartItem = cartSnapshot.data!.docs[index];
                      String foodItemId = cartItem['foodItemId'];
                      int itemCount = cartItem['itemCounter'];
                      String thumbnailUrl = cartItem['thumbnailUrl'];
                      String productTitle = cartItem['productTitle'];
                      String productPrice = cartItem['productPrice'].toString();
                      String selectedFlavorsName = cartItem['selectedFlavorsName'];
                      String selectedVariationName = cartItem['selectedVariationName'].toString();
                      String cartID = cartItem.id;

                      return CartItemDesign(
                        foodItemId: foodItemId,
                        thumbnailUrl: thumbnailUrl,
                        productTitle: productTitle,
                        productPrice: productPrice,
                        quanNumber: itemCount,
                        selectedVariationName: selectedVariationName,
                        selectedFlavorsName: selectedFlavorsName,
                        onQuantityChanged: (newQuantity) async {
                          // Update quantity in Firestore
                          await FirebaseFirestore.instance
                              .collection("users")
                              .doc(firebaseAuth.currentUser!.uid)
                              .collection("cart")
                              .doc(cartID)
                              .update({"itemCounter": newQuantity});

                          // Recalculate subtotal and update TotalAmount provider
                          calculateSubtotalAndUpdateTotalAmount(context);
                        },
                        cartID: cartID, // Pass the cartID to the CartItemDesign widget
                      );
                    },
                    childCount: cartSnapshot.data!.docs.length,
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: isCartEmpty
          ? null
          : Container(
        height: 200.h,
        decoration: BoxDecoration(
          color: AppColors().white,
        ),
        child: Padding(
          padding: EdgeInsets.all(19.w),
          child: Column(
            children: [
              Column(
                children: [
                  SizedBox(height: 6.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Shipping Fee:",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors().black,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        "${defaultShippingFee?.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors().black,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 6.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total Amount:",
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors().black,
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Consumer<TotalAmount>(
                    builder: (context, totalAmountProvider, _) {
                      return Text(
                        "${totalAmountProvider.tAmount}",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors().black,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        double? defaultShippingFee = calculateShippingFeeForItem(widget.distanceInKm ?? 0.0);
                        await FirebaseFirestore.instance
                            .collection("perDelivery")
                            .doc("b292YYxmdWdVF729PMoB") // Use your document ID here
                            .update({"amount": defaultShippingFee});
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (c) => CheckOut(
                              totalAmount: Provider.of<TotalAmount>(context, listen: false).tAmount + defaultShippingFee!,
                              sellersUID: widget.sellersUID,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)
                        ),
                        backgroundColor: AppColors().red,
                        minimumSize: Size(180.w, 45.h),
                      ),
                      child: Text(
                        "Check Out",
                        style: TextStyle(fontSize: 12.sp, fontFamily: "Poppins", color: AppColors().white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    calculateSubtotalAndUpdateTotalAmount(context); // Pass the context to the method
  }

  Future<void> calculateSubtotalAndUpdateTotalAmount(BuildContext context) async {
    double subtotal = 0;
    QuerySnapshot cartSnapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(firebaseAuth.currentUser!.uid)
        .collection("cart")
        .get();
    cartSnapshot.docs.forEach((cartItem) {
      double price = cartItem['productPrice']; // Directly assign the value
      int quantity = cartItem['itemCounter'];
      subtotal += (price * quantity);
    });

    double? defaultShippingFee = calculateShippingFeeForItem(widget.distanceInKm ?? 0.0);

    double totalAmount = subtotal + (defaultShippingFee ?? 0.0);
    Provider.of<TotalAmount>(context, listen: false).updateSubtotal(totalAmount);
  }
}
