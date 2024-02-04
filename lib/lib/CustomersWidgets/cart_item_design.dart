import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../assistantMethods/assistant_methods.dart';
import '../assistantMethods/total_ammount.dart';
import '../models/menus.dart';
import '../theme/colors.dart';

class CartItemDesign extends StatefulWidget {
  final Menus? model;
  final int? quanNumber;
  final BuildContext? context;
  final Function(int) onQuantityChanged;

  const CartItemDesign({
    Key? key,
    this.model,
    this.quanNumber,
    this.context,
    required this.onQuantityChanged,
  }) : super(key: key);

  @override
  _CartItemDesignState createState() => _CartItemDesignState();
}

class _CartItemDesignState extends State<CartItemDesign> {
  late int quantity;
  late CartManager cartManager;

  @override
  void initState() {
    super.initState();
    quantity = widget.quanNumber ?? 0;
    _initializeCartManager();

  }

  void _initializeCartManager() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    cartManager = CartManager(sharedPreferences);
  }

  void _incrementQuantity() {
    setState(() {
      quantity++;
      _updateQuantityInDatabase();
      print("Total Quantity: $quantity");
      widget.onQuantityChanged(quantity);
      Provider.of<TotalAmount>(context, listen: false).displayTotalAmount(calculateTotalAmount());
    });
  }

  void _decrementQuantity() {
    if (quantity > 0) {
      setState(() {
        quantity--;
        _updateQuantityInDatabase();
        print("Total Quantity: $quantity");
        widget.onQuantityChanged(quantity);
        Provider.of<TotalAmount>(context, listen: false).displayTotalAmount(calculateTotalAmount());
      });
    }
  }
  double calculateTotalAmount() {
    double totalAmount = 0;
    // Calculate totalAmount based on the updated quantity
    totalAmount += (widget.model!.productPrice! * quantity);

    // Add any additional calculations (shipping fee, taxes, etc.) here
    totalAmount += 50.0; // Example: Adding a shipping fee

    return totalAmount;
  }

  void _updateQuantityInDatabase() {
    String? productId = widget.model!.productsID;
    cartManager.updateItemQuantity(productId!, quantity);
  }

    @override
    Widget build(BuildContext context) {
      return InkWell(
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
                          image: NetworkImage(widget.model!.thumbnailUrl!),
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
                                  widget.model!.productTitle!.length <= 20
                                      ? widget.model!.productTitle!
                                      : widget.model!.productTitle!.substring(0, 20) + '...',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 12.sp,
                                    fontFamily: "Poppins",
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.close, color: Colors.black), // Close (X) button
                                onPressed: () {
                                  // Handle close button action
                                  // For example, you can call a function to remove the item from the cart.

                                  String? productIdToRemove = widget.model?.productsID;

                                  // Print the value for debugging
                                  print('Original productsID: $productIdToRemove');


                                  // Print the value after processing for debugging
                                  print('Processed productsID: $productIdToRemove');

                                  // Call the removeSelectedProductsFromCart function with the selected product ID
                                  removeSelectedProductsFromCart([productIdToRemove ?? ""], context);
                                },







                              ),


                            ],
                          ),

                          Text(
                            "Php ${(widget.model!.productPrice!).toStringAsFixed(2)}",
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






