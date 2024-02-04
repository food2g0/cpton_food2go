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
  final Menus? model;

  const CartScreen({Key? key, this.sellersUID, this.model}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool isEditing = false;
  List<int>? seperateItemQuantityList;

  @override
  void initState() {
    super.initState();
    seperateItemQuantityList = separateItemQuantities();
  }

  @override
  Widget build(BuildContext context) {
    double defaultShippingFee = 50.0;
    double totalAmount = Provider.of<TotalAmount>(context).tAmount + defaultShippingFee;

    bool isCartEmpty = separateItemQuantities().isEmpty;

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

                        return Container(
                          height: 750.0, // Set a fixed height or adjust based on your design
                          child: CartItemDesign(
                            sellersUID: widget.sellersUID,
                            model: model,
                            context: context,
                            quanNumber: seperateItemQuantityList![index],
                            onQuantityChanged: (newQuantity) {
                              double newTotalAmount = model.productPrice! * newQuantity.toDouble();
                              Provider.of<TotalAmount>(context, listen: false).displayTotalAmount(newTotalAmount);

                              // Print the totalAmount
                              print("Total Amount: ${Provider.of<TotalAmount>(context, listen: false).tAmount}");
                            },
                          ),
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

    );
  }
}
