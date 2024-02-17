import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../assistantMethods/assistant_methods.dart';
import '../assistantMethods/total_ammount.dart';
import '../models/menus.dart';
import '../theme/colors.dart';

class CartItemDesign extends StatefulWidget {
  final String? foodItemId;
  final String? thumbnailUrl;
  final String? productTitle;
  final String? productPrice;
  final String? cartID;
  final int quanNumber;
  final BuildContext? context;
  final Function(int) onQuantityChanged;

  const CartItemDesign({
    Key? key,
    this.foodItemId,
    this.thumbnailUrl,
    this.productTitle,
    required this.productPrice,
    required this.quanNumber,
    this.context,
    required this.onQuantityChanged, this.cartID,
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
      quantity++;
      print("Total Quantity: $quantity");
      widget.onQuantityChanged(quantity);
      _updateItemCounter(quantity);
    });
  }

  void _decrementQuantity() {
    if (quantity > 0) {
      setState(() {
        quantity--;
        print("Total Quantity: $quantity");
        widget.onQuantityChanged(quantity);
        _updateItemCounter(quantity);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(widget.cartID ?? ''), // Unique key for the dismissible item
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        // Remove the item from the cart when dismissed
        String? cartIDToRemove = widget.cartID;
        if (cartIDToRemove != null) {
          removeCartItemFromCart(cartIDToRemove, context);
        }
      },
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      child: Padding(
        padding: EdgeInsets.only(left: 10, right: 10, top: 10).w,
        child: SizedBox(
          height: 145.h,
          width: double.infinity,
          child: Card(
            elevation: 2,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 2,
                  child: Container(
                    width: 150.w,
                    height: 120.h,
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
                            IconButton(
                              icon: Icon(Icons.delete_forever, color: AppColors().red), // Close (X) button
                              onPressed: () {
                                // Handle close button action
                                // For example, you can call a function to remove the item from the cart.
                                String? cartIDToRemove = widget.cartID;

                                // Check if cartID is not null and then remove the item from the cart
                                if (cartIDToRemove != null) {
                                  removeCartItemFromCart(cartIDToRemove, context);
                                }

                              },
                            ),
                          ],
                        ),
                        Text(
                          "Php ${widget.productPrice}",
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 10,),
                        Container(
                          height: 40.h,
                          width: 110.w,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.add_circle_outlined, color: AppColors().red, size: 20,),
                                onPressed: _incrementQuantity,
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
                                icon: Icon(Icons.remove_circle, color: AppColors().red, size: 20),
                                onPressed: _decrementQuantity,
                              ),
                            ],
                          ),
                        ),
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
  }
}
