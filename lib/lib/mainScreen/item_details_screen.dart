import 'dart:math';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:number_inc_dec/number_inc_dec.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../CustomersWidgets/app_bar.dart';
import '../CustomersWidgets/dimensions.dart';
import '../assistantMethods/assistant_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../assistantMethods/cart_item_counter.dart';
import '../models/items.dart';
import 'cart_screen.dart';


class ItemDetailsScreen extends StatefulWidget {
  final dynamic model;
  final String? sellersUID;
  const ItemDetailsScreen({super.key, required this.model, this.sellersUID});

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  TextEditingController counterTextEditingController = TextEditingController();

  int cartItemCount = 2;
  double deliveryDistance = 0.0; // Declare the deliveryDistance variable

  // Function to calculate the distance using Haversine formula
  double calculateDistance(double customerLatitude, double customerLongitude,
      double sellerLatitude, double sellerLongitude) {
    const int earthRadius = 6371; // Radius of the Earth in kilometers
    double lat1Rad = degreesToRadians(customerLatitude);
    double lng1Rad = degreesToRadians(customerLongitude);
    double lat2Rad = degreesToRadians(sellerLatitude);
    double lng2Rad = degreesToRadians(sellerLongitude);

    double latDiff = lat2Rad - lat1Rad;
    double lngDiff = lng2Rad - lng1Rad;

    double a = pow(sin(latDiff / 2), 2) +
        cos(lat1Rad) * cos(lat2Rad) * pow(sin(lngDiff / 2), 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c; // Distance in kilometers
  }

  // Function to convert degrees to radians
  double degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  Future<void> calculateAndDisplayDistance() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    final String customersUID =
        "customersUID"; // Replace with the customer's ID
    final String sellersUID = "sellersUID"; // Replace with the seller's ID

    final DocumentSnapshot<Map<String, dynamic>> customerSnapshot =
    await firestore.collection("customer").doc(customersUID).get();

    final DocumentSnapshot<Map<String, dynamic>> sellerSnapshot =
    await firestore.collection("sellers").doc(sellersUID).get();

    final customerLatitude = customerSnapshot.get("lat");
    final customerLongitude = customerSnapshot.get("lng");

    final sellerLatitude = sellerSnapshot.get("lat");
    final sellerLongitude = sellerSnapshot.get("lng");

    // Calculate the distance
    deliveryDistance = calculateDistance(
      customerLatitude.toDouble(),
      customerLongitude.toDouble(),
      sellerLatitude.toDouble(),
      sellerLongitude.toDouble(),
    );
  }

  @override
  Widget build(BuildContext context) {

    final imageUrl = widget.model?.thumbnailUrl ?? 'default_image_url.jpg';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey, Colors.white],
          ),
        ),

        child: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              expandedHeight: 200.0,
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: false,
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.center,
                          colors: [
                            Colors.black, // Transparent at the top
                            Colors.black.withOpacity(0.5), // Dark gradient at the bottom
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                Stack(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (c)=> CartScreen(sellersUID: widget.model!.sellersUID)));
                      },
                      icon: const Icon(
                        Icons.shopping_cart_rounded,
                        color: Colors.white, // Set the icon color
                      ),
                    ),
                    Positioned(
                      top: 2,
                      right: 2,
                      child: Consumer<CartItemCounter>(
                        builder: (context, counter, c) {
                          return Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            padding: const EdgeInsets.all(4.0), // Adjust the padding as needed
                            child: Text(
                              counter.count.toString(),
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          );
                        },
                      ),
                    )

                  ],
                ),
              ],
            ),
            // Add product details here
            SliverList(
              delegate: SliverChildListDelegate([
                // Product Title
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    widget.model.productTitle.toString(),
                    style: const TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    '\$${widget.model.productPrice?.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
                // Star Ratings and Items Sold
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          for (int i = 0; i < 5; i++)
                            Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: Dimensions.height15,
                            ),
                          SizedBox(width: Dimensions.height10),
                          const Text(
                            '4.5',
                            style: TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '5,000 Sold',
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: Dimensions.font14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: Dimensions.height20,
                ),
                Container(
                  color: Colors.white,
                  height: 50,
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Delivery Cost",
                          style: TextStyle(
                            fontFamily: "Poppins",
                          ),
                        ),
                        Text(
                          '${deliveryDistance.toStringAsFixed(2)} km',
                          style: const TextStyle(
                            fontFamily: "Poppins",
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: Dimensions.height10,
                ),
                // Product Description
                Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      widget.model.productDescription!,
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: Dimensions.font16,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 60, // Adjust the height as needed
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 250,
                child: NumberInputPrefabbed.roundedButtons(
                  incDecBgColor: Color(0xFF890010),
                  controller: counterTextEditingController,
                  min: 1,
                  max: 5,
                  initialValue: 1,
                  buttonArrangement: ButtonArrangement.incRightDecLeft,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  int itemCounter =
                  int.parse(counterTextEditingController.text);

                  //1.check if item exist already in cart
                  List<String> seperateItemIDsList = separateItemIDs();
                  seperateItemIDsList.contains(widget.model.productsID)
                      ? Fluttertoast.showToast(msg: "Item is already in a cart")
                      :

                  //2.add to cart
                  addItemToCart(
                      widget.model.productsID, context, itemCounter);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF890010),
                ),
                child: Text(
                  'Add to Cart',
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: Dimensions.font14,
                    fontWeight: FontWeight.bold,
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