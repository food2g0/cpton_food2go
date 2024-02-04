import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../assistantMethods/assistant_methods.dart';
import '../assistantMethods/total_ammount.dart';
import '../mainScreen/check_out.dart';
import '../mainScreen/home_screen.dart';
import '../models/menus.dart';
import '../theme/colors.dart';

class CartItemDesign extends StatefulWidget {

  final String? sellersUID;
  final Menus? model;
  final int? quanNumber;
  final BuildContext? context;
  final Function(int) onQuantityChanged;

  const CartItemDesign({
    Key? key,
    this.model,
    this.quanNumber,
    this.context,
    required this.onQuantityChanged, this.sellersUID,
  }) : super(key: key);

  @override
  _CartItemDesignState createState() => _CartItemDesignState();
}
bool isEditing = false;
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
  double calculateSubTotalAmount() {
    double totalAmount = 0;
    // Calculate totalAmount based on the updated quantity
    totalAmount += (widget.model!.productPrice! * quantity);



    return totalAmount;
  }

  void _updateQuantityInDatabase() {
    String? productId = widget.model!.productsID;
    cartManager.updateItemQuantity(productId!, quantity);
  }

  @override
  Widget build(BuildContext context) {

    double defaultShippingFee = 50.0;
    double totalAmount = calculateTotalAmount();
    double subTotalAmount = calculateSubTotalAmount();

    bool isCartEmpty = separateItemQuantities().isEmpty;
    return Scaffold(
      body: InkWell(
        child: Padding(
          padding: EdgeInsets.only(left: 10, right: 10, top: 10).w,
          child: SizedBox(
            height: 120.h,
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors().white,
                borderRadius: BorderRadius.circular(10.w),
                border: Border.all(color: AppColors().red, width: 1),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 140.w,
                    height: 120.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10.w),
                        bottomLeft: Radius.circular(10.w),
                      ),
                      image: DecorationImage(
                        image: NetworkImage(widget.model!.thumbnailUrl!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Padding(
                    padding: EdgeInsets.all(1.0).w,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8.h),
                        Text(
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
                        Row(
                          children: [
                            Text(
                              "Quantity: ",
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 12.sp,
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.w600,
                              ),
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
                            SizedBox(width: 8.w),
                            IconButton(
                              icon: Icon(Icons.add),
                              onPressed: _incrementQuantity,
                            ),
                            IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: _decrementQuantity,
                            ),
                          ],
                        ),
                        Text(
                          "Php ${(widget.model!.productPrice!).toStringAsFixed(2)}",
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
            ),
          ),
        ),

      ),
      bottomNavigationBar: isCartEmpty
          ? Container()
          : Container(
        height: 200.h,
        decoration: BoxDecoration(
          color: AppColors().white,
          border: Border.all(color: AppColors().red, width: 1),
        ),
        child: Padding(
          padding: EdgeInsets.all(19.w),
          child: Column(
            children: [
              if (!isCartEmpty)
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
                        Text(
                          subTotalAmount.toStringAsFixed(2),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors().black,
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h,),
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
              SizedBox(height: 6.h,),
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
                  Text(
                    totalAmount.toStringAsFixed(2),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors().black,
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Align(
                alignment: Alignment.bottomCenter,
                child: isEditing
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        clearCartNow(context);
                        Navigator.push(context, MaterialPageRoute(builder: (c) => const HomeScreen()));
                        Fluttertoast.showToast(msg: "Cart has been cleared.");
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors().yellow,
                        minimumSize: Size(140.w, 50.h),
                      ),
                      child: Text(
                        "Clear All",
                        style: TextStyle(fontSize: 14.sp, fontFamily: "Poppins", color: AppColors().white,),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Handle the logic when "Clear Selected" is pressed
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:  AppColors().red,
                        minimumSize: Size(110.w, 50.h),
                      ),
                      child: Text(
                        "Delete Selected",
                        style: TextStyle(fontSize: 14.sp, fontFamily: "Poppins", color: AppColors().white,),
                      ),
                    ),
                  ],
                )
                    : ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (c) => CheckOut(
                          totalAmount: totalAmount.toDouble(),
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
                    style: TextStyle(fontSize: 16.sp, fontFamily: "Poppins",color: AppColors().white,),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

  }
}