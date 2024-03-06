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

  const CartScreen({Key? key,  this.sellersUID, this.model, this.calculateShippingFee, this.distanceInKm}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool isEditing = false;
  List<int>? separateItemQuantityList;
  bool isCartEmpty = true; // Initially set to true

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
    // Set the initial value of isCartEmpty based on the cart data
    checkCartEmpty();
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

  @override
  Widget build(BuildContext context) {
    double? defaultShippingFee = calculateShippingFeeForItem(widget.distanceInKm ?? 0.0);



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
      body: CustomScrollView(
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
                      context: context,
                      onQuantityChanged: (newQuantity) async {
                        // Update quantity in Firestore
                        await FirebaseFirestore.instance
                            .collection("users")
                            .doc(firebaseAuth.currentUser!.uid)
                            .collection("cart")
                            .doc(cartID)
                            .update({"itemCounter": newQuantity});

                        // Recalculate subtotal and update TotalAmount provider
                        calculateSubtotalAndUpdateTotalAmount();
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Sub Total:",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors().black1,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Consumer<TotalAmount>(
                        builder: (context, totalAmountProvider, _) {
                          return Text(
                            "${totalAmountProvider.tAmount}",
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors().black1,
                              fontFamily: "Poppins",
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Shipping Fee:",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors().black1,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        "${defaultShippingFee?.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors().black1,
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
                        (totalAmountProvider.tAmount + defaultShippingFee!).toStringAsFixed(2),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors().black,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w600,
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
    calculateSubtotalAndUpdateTotalAmount();
  }

  Future<void> calculateSubtotalAndUpdateTotalAmount() async {
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
    Provider.of<TotalAmount>(context, listen: false).updateSubtotal(subtotal);
  }
}