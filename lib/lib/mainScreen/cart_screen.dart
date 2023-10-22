import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_foodtogo/lib/CustomersWidgets/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../CustomersWidgets/cart_item_design.dart';
import '../CustomersWidgets/progress_bar.dart';
import '../CustomersWidgets/text_widget_header.dart';
import '../assistantMethods/assistant_methods.dart';
import '../assistantMethods/cart_item_counter.dart';
import '../assistantMethods/total_ammount.dart';
import '../models/menus.dart';
import '../splashScreen/splash_screen.dart';

class CartScreen extends StatefulWidget {
  final String? sellerUID;

  const CartScreen({super.key, this.sellerUID, required sellersUID});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
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

    return Scaffold(
      appBar: AppBar(
        // Add your app bar content here
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const SizedBox(width: 10),
          Align(
            alignment: Alignment.bottomLeft,
            child: FloatingActionButton.extended(
              label: const Text(
                "Clear Cart",
                style: TextStyle(fontSize: 16),
              ),
              backgroundColor: Colors.cyan,
              icon: const Icon(Icons.clear_all),
              onPressed: () {
                clearCartNow(context);

                Navigator.push(context, MaterialPageRoute(builder: (c) => const MySplashScreen()));

                Fluttertoast.showToast(msg: "Cart has been cleared.");
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: FloatingActionButton.extended(
              label: const Text(
                "Check Out",
                style: TextStyle(fontSize: 16),
              ),
              backgroundColor: Colors.cyan,
              icon: const Icon(Icons.navigate_next),
              onPressed: () {
                // Add your checkout logic here
              },
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Overall total amount
          SliverPersistentHeader(
            pinned: true,
            delegate: TextWidgetHeader(title: "My Cart List"),
          ),
          SliverToBoxAdapter(
            child: Consumer2<TotalAmount, CartItemCounter>(
              builder: (context, amountProvider, cartProvider, c) {
                return Padding(
                  padding: const EdgeInsets.all(8),
                  child: Center(
                    child: cartProvider.count == 0
                        ? Container()
                        : Text(
                      "Total Price: ${amountProvider.tAmount}",
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
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

        bottomNavigationBar: Container(
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
                // Total Amount Row
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
                      "${totalAmount.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: Dimensions.font20,
                        color: Colors.black,
                        fontFamily: "Poppins",
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20,),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: ElevatedButton(
                    onPressed: () {
                      // Add your checkout logic here
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF890010),
                      minimumSize: Size(300, 50),
                    ),
                    child: Text(
                      "Check Out",
                      style: TextStyle(fontSize: 16, fontFamily: "Poppins"),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )





    );

  }
}
