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
    required this.onQuantityChanged, this.cartID, this.selectedFlavorsName, this.selectedVariationName,
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
      Provider.of<CartItemCounter>(context, listen: false).displayCartListItemNumber();
    } catch (error) {
      print("Failed to update item counter in Firestore: $error");
    }
  }

  void _incrementQuantity() {
    if (quantity < 5) { // Limit the increment to 5
      setState(() {
        quantity++;
        print("Total Quantity: $quantity");
        widget.onQuantityChanged(quantity);
        _updateItemCounter(quantity);
      });
    }
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
      key: Key(widget.cartID!), // Unique key for the Dismissible widget
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
        // Handle when the item is dismissed (deleted)
        String? cartIDToRemove = widget.cartID;
        // Check if cartID is not null and then remove the item from the cart
        if (cartIDToRemove != null) {
          await removeCartItemFromCart(cartIDToRemove, context);
        }
        // Check the number of items in the cart
        QuerySnapshot cartSnapshot = await FirebaseFirestore.instance
            .collection("users")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection("cart")
            .get();
        if (cartSnapshot.size == 0) {
          // If the cart is empty, navigate to the home screen
          Navigator.push(context, MaterialPageRoute(builder: (c) => const HomeScreen()));
        } else {
          // If there are items in the cart, simply refresh the page
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const CartScreen()));
        }
        Fluttertoast.showToast(msg: "Cart item removed.");
      },
      child: Padding(
        padding: EdgeInsets.only(left: 10, right: 10, top: 10).w,
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
                                    'images/peso.png', // Replace with the path to your currency icon image file
                                    width: 15, // Adjust the width as needed
                                    height: 15, // Adjust the height as needed
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
                                onPressed: quantity > 1 ? _decrementQuantity : null,
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
  }
}
