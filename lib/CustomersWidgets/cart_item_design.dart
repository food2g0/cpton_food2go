import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../assistantMethods/assistant_methods.dart';
import '../assistantMethods/cart_item_counter.dart';

import '../mainScreen/cart_screen.dart';
import '../mainScreen/home_screen.dart';
import '../theme/colors.dart';

class CartItemDesign extends StatefulWidget {
  final String? foodItemId;
  final String? thumbnailUrl;
  final String? productTitle;
  final String? productPrice;
  final String? selectedFlavorsName;
  final String? selectedVariationName;
  final String? cartID;
  final int quanNumber;
  final Function(int) onQuantityChanged;

  const CartItemDesign({
    Key? key,
    this.foodItemId,
    this.thumbnailUrl,
    this.productTitle,
    required this.productPrice,
    required this.quanNumber,
    required this.onQuantityChanged,
    this.cartID,
    this.selectedFlavorsName,
    this.selectedVariationName,
  }) : super(key: key);

  @override
  _CartItemDesignState createState() => _CartItemDesignState();
}

class _CartItemDesignState extends State<CartItemDesign> {
  late int quantity;

  @override
  void initState() {
    super.initState();
    quantity = widget.quanNumber ?? 0;
  }

  Future<void> _updateItemCounter(int newQuantity) async {
    // Update the Firestore collection with the new quantity
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection("cart")
          .doc(widget.cartID)
          .update({"itemCounter": newQuantity});
    } catch (error) {
      print("Failed to update item counter in Firestore: $error");
    }
  }

  void _incrementQuantity() {
    setState(() {
      if (quantity < 5) {
        quantity++;
        widget.onQuantityChanged(quantity);
        _updateItemCounter(quantity);
      }
    });
  }

  void _decrementQuantity() {
    setState(() {
      if (quantity > 1) {
        quantity--;
        widget.onQuantityChanged(quantity);
        _updateItemCounter(quantity);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection("cart")
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        bool isCartEmpty = snapshot.data!.docs.isEmpty;

        if (isCartEmpty) {
          WidgetsBinding.instance!.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          });
        }

        return Dismissible(
          key: Key(widget.cartID!),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            child: Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
          ),
          onDismissed: (direction) async {
            try {
              // Handle when the item is dismissed (deleted)
              String? cartIDToRemove = widget.cartID;
              // Check if cartID is not null and then remove the item from the cart
              if (cartIDToRemove != null) {
                await removeCartItemFromCart(cartIDToRemove, context);
              }

              // Check if the cart has only one item left after removing the current item
              QuerySnapshot cartSnapshot = await FirebaseFirestore.instance
                  .collection("users")
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .collection("cart")
                  .get();

              if (cartSnapshot.docs.length <= 0) {
                // If the cart has only one item left, navigate to the home screen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              }

              Fluttertoast.showToast(msg: "Cart item removed.");
            } catch (error) {
              print("Error removing item from cart: $error");
              Fluttertoast.showToast(msg: "Error removing item from cart");
            }
          },


          child: Padding(
            padding: EdgeInsets.all(10).w,
            child: SizedBox(
              height: 135.h,
              width: double.infinity,
              child: Card(
                elevation: 0,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 2,
                      child: Container(
                        width: 100.w,
                        height: 100.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          image: DecorationImage(
                            image: NetworkImage(widget.thumbnailUrl!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(1.0).w,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 8.h),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.productTitle!.length <= 20
                                        ? widget.productTitle!
                                        : widget.productTitle!.substring(0, 20) + '...',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 12.sp,
                                      fontFamily: "Poppins",
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        'images/peso.png',
                                        width: 15,
                                        height: 15,
                                      ),
                                      Text(
                                        widget.productPrice!,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    (widget.selectedVariationName != null && widget.selectedVariationName!.isNotEmpty)
                                        ? widget.selectedVariationName![0].toUpperCase()
                                        : '',
                                    style: TextStyle(
                                      color: AppColors().black,
                                      fontSize: 12.sp,
                                      fontFamily: "Poppins",
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    (widget.selectedFlavorsName != null && widget.selectedFlavorsName!.isNotEmpty)
                                        ? ', ${widget.selectedFlavorsName}'
                                        : '',
                                    style: TextStyle(
                                      color: AppColors().black,
                                      fontSize: 12.sp,
                                      fontFamily: "Poppins",
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Spacer(),
                                ],
                              ),
                            ),
                            SizedBox(height: 10.h,),
                            Container(
                              height: 30.h,
                              width: 100.w,
                              decoration: BoxDecoration(
                                color: AppColors().white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.remove_circle, color: AppColors().red, size: 14),
                                    onPressed: _decrementQuantity,
                                  ),
                                  Text(
                                    quantity.toString(),
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: "Poppins",
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.add_circle_outlined, color: AppColors().red, size: 14,),
                                    onPressed: _incrementQuantity,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 5.h,),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
