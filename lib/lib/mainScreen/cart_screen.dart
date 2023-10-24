import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_foodtogo/lib/CustomersWidgets/dimensions.dart';
import 'package:cpton_foodtogo/lib/mainScreen/check_out.dart';
import 'package:cpton_foodtogo/lib/mainScreen/home_screen.dart';
import 'package:cpton_foodtogo/lib/theme/colors.dart';
import 'package:flutter/material.dart';
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
  List<int>? separateItemQuantityList;
  num totalAmount = 0;

  @override
  void initState() {
    super.initState();

    totalAmount = 0;
    Provider.of<TotalAmount>(context, listen: false).displayTotalAmount(0);

    separateItemQuantityList = separateItemQuantities();
  }

  @override
  Widget build(BuildContext context) {
    double defaultShippingFee = 10.0;
    double totalAmount = Provider.of<TotalAmount>(context).tAmount + defaultShippingFee;

    // Check if the cart is empty

    bool isCartEmpty = separateItemQuantities().isEmpty;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF890010),
        title: const Text(
          "Shopping Cart",
          style: TextStyle(fontFamily: "Poppins"),
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
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
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
                    const Text(
                      "Your cart is empty.",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Poppins",
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors().startColor, AppColors().endColor], // Define your gradient colors
                          begin: Alignment.topLeft, // Define the start point of the gradient
                          end: Alignment.bottomRight, // Define the end point of the gradient
                        ),
                        borderRadius: BorderRadius.circular(8.0), // Add border radius for rounded corners
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (c) => HomeScreen()));
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.transparent, // Set the button's background to transparent
                          minimumSize: const Size(180, 50),
                        ),
                        child: const Text(
                          "Continue Shopping",
                          style: TextStyle(fontSize: 16, fontFamily: "Poppins", color: Colors.white),
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
                          totalAmount += (model.productPrice! * separateItemQuantityList![index]);
                        } else {
                          totalAmount += (model.productPrice! * separateItemQuantityList![index]);
                        }

                        if (snapshot.data!.docs.length - 1 == index) {
                          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                            Provider.of<TotalAmount>(context, listen: false).displayTotalAmount(totalAmount.toDouble());
                          });
                        }

                        return CartItemDesign(
                          model: model,
                          context: context,
                          quanNumber: separateItemQuantityList![index],
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
          ? null // Set to null when the cart is empty
          : Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              offset: Offset(0, -15),
              blurRadius: 20,
              color: Color(0xFFDADADA).withOpacity(0.15),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              if (!isCartEmpty)
              // Show cart total and buttons
                Column(
                  children: [
                    // Subtotal Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Sub Total:",
                          style: TextStyle(
                            fontSize: Dimensions.font16,
                            color: Colors.black54,
                            fontFamily: "Poppins",
                          ),
                        ),
                        Text(
                          "${Provider.of<TotalAmount>(context).tAmount}",
                          style: TextStyle(
                            fontSize: Dimensions.font16,
                            color: Colors.black54,
                            fontFamily: "Poppins",
                          ),
                        ),
                      ],
                    ),

                    // Shipping Fee Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Shipping Fee:",
                          style: TextStyle(
                            fontSize: Dimensions.font16,
                            color: Colors.black54,
                            fontFamily: "Poppins",
                          ),
                        ),
                        Text(
                          "${defaultShippingFee.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: Dimensions.font16,
                            color: Colors.black54,
                            fontFamily: "Poppins",
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              // Total Amount Row (unchanged)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total Amount:",
                    style: TextStyle(
                      fontSize: Dimensions.font20,
                      color: Colors.black,
                      fontFamily: "Poppins",
                    ),
                  ),
                  Text(
                    totalAmount.toStringAsFixed(2),
                    style: TextStyle(
                      fontSize: Dimensions.font20,
                      color: Colors.black,
                      fontFamily: "Poppins",
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
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
                        backgroundColor: Colors.red,
                        minimumSize: const Size(140, 50),
                      ),
                      child: const Text(
                        "Clear All",
                        style: TextStyle(fontSize: 16, fontFamily: "Poppins"),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Handle the logic when "Clear Selected" is pressed
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        minimumSize: const Size(140, 50),
                      ),
                      child: const Text(
                        "Delete Selected",
                        style: TextStyle(fontSize: 16, fontFamily: "Poppins"),
                      ),
                    ),
                  ],
                )
                    : ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (c)=> checkOut(
                      totalAmount: totalAmount.toDouble(),
                      sellersUID: widget.sellersUID,
                    )));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF890010),
                    minimumSize: const Size(300, 50),
                  ),
                  child: const Text(
                    "Check Out",
                    style: TextStyle(fontSize: 16, fontFamily: "Poppins"),
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
