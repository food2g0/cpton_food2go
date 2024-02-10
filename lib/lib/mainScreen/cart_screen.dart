import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_foodtogo/lib/mainScreen/check_out.dart';
import 'package:cpton_foodtogo/lib/mainScreen/home_screen.dart';
import 'package:cpton_foodtogo/lib/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../CustomersWidgets/cart_item_design.dart';
import '../assistantMethods/assistant_methods.dart';
import '../assistantMethods/total_ammount.dart';
import '../global/global.dart';
import '../models/menus.dart';

class CartScreen extends StatefulWidget {
  final String? sellersUID;
  final Menus? model;

  const CartScreen({Key? key, this.sellersUID, this.model}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {

  bool isEditing = false;
  List<int>? separateItemQuantityList;
  bool isCartEmpty = false; // Initially set to true

  @override
  Widget build(BuildContext context) {
    double defaultShippingFee = 50.0;

    return Scaffold(
      backgroundColor: Colors.white70,
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
              if (!cartSnapshot.hasData || cartSnapshot.data!.docs.isEmpty) {
                return SliverToBoxAdapter(child: Center(child: Text("Your cart is empty.")));
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    var cartItem = cartSnapshot.data!.docs[index];
                    String foodItemId = cartItem['foodItemId'];
                    int itemCount = cartItem['itemCounter'];
                    String thumbnailUrl = cartItem['thumbnailUrl'];
                    String productTitle = cartItem['productTitle'];
                    String productPrice = cartItem['productPrice'].toString();
                    String cartID = cartItem.id;

                    return CartItemDesign(
                      foodItemId: foodItemId,
                      thumbnailUrl: thumbnailUrl,
                      productTitle: productTitle,
                      productPrice: productPrice,
                      quanNumber: itemCount,
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
      bottomNavigationBar: Container(
        height: isCartEmpty ? null : 200.h,
        decoration: BoxDecoration(
          color: AppColors().white,
          border: Border.all(color: AppColors().red, width: 1),
        ),
        child: isCartEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Your cart is empty.",
                style: TextStyle(fontSize: 12.sp, fontFamily: "Poppins", color: AppColors().black),
              ),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (c) => const HomeScreen()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors().red,
                  minimumSize: Size(150.w, 50.h),
                ),
                child: Text(
                  "Shop Now",
                  style: TextStyle(fontSize: 12.sp, fontFamily: "Poppins", color: AppColors().white),
                ),
              ),
            ],
          ),
        )
            : Padding(
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
                              fontWeight: FontWeight.w600,
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
                          color: AppColors().black,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "${defaultShippingFee.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors().black,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w600,
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
                        (totalAmountProvider.tAmount + defaultShippingFee).toStringAsFixed(2),
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
              SizedBox(height: 10.h),
              Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (c) => CheckOut(
                              totalAmount: Provider.of<TotalAmount>(context, listen: false).tAmount + defaultShippingFee,
                              sellersUID: widget.sellersUID,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors().red,
                        minimumSize: Size(300.w, 50.h),
                      ),
                      child: Text(
                        "Check Out",
                        style: TextStyle(fontSize: 16.sp, fontFamily: "Poppins", color: AppColors().white,),
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
