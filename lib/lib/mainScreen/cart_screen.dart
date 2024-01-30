import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_foodtogo/lib/mainScreen/check_out.dart';
import 'package:cpton_foodtogo/lib/mainScreen/home_screen.dart';
import 'package:cpton_foodtogo/lib/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../CustomersWidgets/cart_item_design.dart';
import '../CustomersWidgets/progress_bar.dart';
import '../assistantMethods/assistant_methods.dart';
import '../assistantMethods/total_ammount.dart';
import '../models/menus.dart';

class CartScreen extends StatefulWidget {
  final String? sellersUID;

  const CartScreen({super.key, required this.sellersUID});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool isEditing = false;
  List<int>? seperateItemQuantityList;
  num totalAmount = 0;

  @override
  void initState() {
    super.initState();

    totalAmount = 0;
    Provider.of<TotalAmount>(context, listen: false).displayTotalAmount(0);

    seperateItemQuantityList = separateItemQuantities();
  }

  @override
  Widget build(BuildContext context) {

    double defaultShippingFee = 50.0;
    double totalAmount = Provider.of<TotalAmount>(context).tAmount + defaultShippingFee;

    // Check if the cart is empty
    bool isCartEmpty = separateItemQuantities().isEmpty;
    print("Is Cart Empty: $isCartEmpty");

    return Scaffold(
      backgroundColor: Colors.white70,
      appBar: AppBar(
        backgroundColor: AppColors().red,
        title: Text(
          "Shopping Cart",
          style: TextStyle(fontFamily: "Poppins", color: AppColors().white, fontSize: 14.sp),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              setState(() {
                isEditing = !isEditing;
              });
            },
            child: Text(
              isEditing ? "Done" : "Edit",
              style: TextStyle(
                color: AppColors().white,
                fontSize: 14.sp,
              ),
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          if (isCartEmpty)
          // Show an empty cart message and "Continue Shopping" button
            SliverToBoxAdapter(
              child: Container(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Text(
                      "Your cart is empty.",
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Poppins",
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors().startColor, AppColors().endColor],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(8.0.r),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (c) => HomeScreen()));
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(180.w, 50.h),
                        ),
                        child: Text(
                          "Continue Shopping",
                          style: TextStyle(fontSize: 16.sp, fontFamily: "Poppins", color: AppColors().red),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
          else
          // Display cart items with quantity number
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("items")
                  .where("productsID", whereIn: separateItemIDs())
                  .orderBy("publishedDate", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return SliverToBoxAdapter(child: Center(child: circularProgress()));
                } else if (snapshot.data!.docs.isEmpty) {
                  return SliverToBoxAdapter(child: Container());
                } else {
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        Menus model = Menus.fromJson(
                          snapshot.data!.docs[index].data()! as Map<String, dynamic>,
                        );

                        if (index == 0) {
                          totalAmount = 0;
                          totalAmount += (model.productPrice! * seperateItemQuantityList![index]);
                        } else {
                          totalAmount += (model.productPrice! * seperateItemQuantityList![index]);
                        }

                        if (snapshot.data!.docs.length - 1 == index) {
                          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                            Provider.of<TotalAmount>(context, listen: false).displayTotalAmount(totalAmount.toDouble());
                          });
                        }

                        return CartItemDesign(
                          model: model,
                          context: context,
                          quanNumber: seperateItemQuantityList![index],
                        );
                      },
                      childCount: snapshot.hasData ? snapshot.data!.docs.length : 0,
                    ),
                  );
                }
              },
            ),
        ],
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
                          "${Provider.of<TotalAmount>(context).tAmount}",
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
