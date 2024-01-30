import 'dart:math';
import 'package:cpton_foodtogo/lib/mainScreen/home_screen.dart';
import 'package:cpton_foodtogo/lib/theme/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:number_inc_dec/number_inc_dec.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../CustomersWidgets/dimensions.dart';
import '../assistantMethods/assistant_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../assistantMethods/cart_item_counter.dart';
import 'cart_screen.dart';

class ItemDetailsScreen extends StatefulWidget {
  final dynamic model;
  final String? sellersUID;
  const ItemDetailsScreen({Key? key, required this.model, this.sellersUID}) : super(key: key);

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  TextEditingController counterTextEditingController = TextEditingController();
  bool isCartEmpty = separateItemIDs().isEmpty;
  int cartItemCount = 0;
  late String customersUID; // Declare customersUID without initialization

  @override
  void initState() {
    super.initState();
    customersUID = getCurrentUserUID(); // Initialize customersUID in initState
    print('Debug: customersUID in initState: $customersUID');
  }

  String getCurrentUserUID() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    } else {
      print('Debug: User is not signed in. Returning default UID.');
      return 'default_uid';
    }
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
              expandedHeight: 200.0.h,
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              pinned: true,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: FlexibleSpaceBar(
                  centerTitle: false,
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),
              ),


              actions: [
                Stack(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (c) => CartScreen(
                                    sellersUID: widget.model!.sellersUID)));
                      },
                      icon: const Icon(
                        Icons.shopping_cart_rounded,
                        color: Colors.white,
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
                            padding: EdgeInsets.all(
                                4.0.w), // Adjust the padding as needed
                            child: Text(
                              counter.count.toString(),
                              style: const TextStyle(
                                color: Color(0xFF890010),
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
                // Product Title, Price, and Ratings
                SizedBox(height: 15.0.h),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color:Color(0xFF890010), width: 1.0 ),
                      borderRadius: BorderRadius.circular(10.0), // Adjust the value as needed
                    ),
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Title
                        Row(
                          children: [
                            Icon(Icons.fastfood_outlined, size: 20.0.sp, color: Color(0xFF890010)),
                            SizedBox(width: 10.0),
                            Expanded(
                              child: Text(
                                (widget.model!.productTitle.length > 20)
                                    ? ' ${widget.model!.productTitle.substring(0, 20)}...'
                                    : ' ${widget.model!.productTitle}',
                                style: TextStyle(
                                  fontFamily: "Poppins",
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                // Add item to favorites when tapped
                                addToFavorites(widget.model.productsID, customersUID); // Replace 'user123' with the actual user ID
                                // You can get the user ID from your authentication system
                              },
                              child: Icon(
                                Icons.favorite_border,
                                size: 30.0.sp,
                                color: Colors.red,
                              ),
                            ),

                          ],
                        ),

                        SizedBox(height: 10.0),
                        // Product Price
                        Row(
                          children: [
                            Icon(Icons.php, size: 20.0, color: Colors.green,),
                            SizedBox(width: 10.0),
                            Text(
                              ' ${widget.model.productPrice?.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontFamily: "Poppins",
                                fontSize: 14.0.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.0.h),
                        // Star Ratings and Items Sold
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.star, color: Colors.amber, size: 15.h),
                                Icon(Icons.star, color: Colors.amber, size: 15.h),
                                Icon(Icons.star, color: Colors.amber, size: 15.h),
                                Icon(Icons.star, color: Colors.amber, size: 15.h),
                                Icon(Icons.star, color: Colors.amber, size: 15.h),
                                SizedBox(width: 10.w),
                                Text(
                                  '4.5',
                                  style: TextStyle(
                                    fontFamily: "Poppins",
                                    fontSize: 12.0.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '5,000 Sold',
                              style: TextStyle(
                                fontFamily: "Poppins",
                                fontSize: 12.sp,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20.h,),
                Container(
                  color: Colors.white,
                  height: 50.h,
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.delivery_dining,size: 24.sp,color:Color(0xFF890010)),
                        Text(
                          "  Cost ",
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.black
                          ),
                        ),
                        Text(
                          ' Php: 50',
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20.sp,),
                // Product Description
                Container(
                  color: Colors.white,
                  child: Padding(
                    padding:  EdgeInsets.all(16.0.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.description, size: 20.0.sp),
                            SizedBox(width: 10.0.w),
                            Text(
                              "Product Description",
                              style: TextStyle(
                                fontFamily: "Poppins",
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                  color:Color(0xFF890010)
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.0.h),
                        SingleChildScrollView(
                          child: Text(
                            widget.model.productDescription!,
                            style: TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 10.sp,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Product Reviews
                Padding(
                  padding: EdgeInsets.all(10.w),
                  child: Row(
                    children: [
                      Icon(Icons.reviews, size: 20.0.sp),
                      SizedBox(width: 10.0.w),
                      Text(
                        "Product Reviews",
                        style: TextStyle(
                            color: Colors.black87,
                            fontSize: 12.sp,
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ],
                  ),
                ),
                // Product Description (Reviews)
                Container(
                  color: Colors.white,
                  child: Padding(
                    padding:  EdgeInsets.all(16.0.w),
                    child: Row(
                      children: [
                        Icon(Icons.description, size: 20.0.sp),
                        SizedBox(width: 10.0.w),
                        Text(
                          "so good!!",
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontSize: Dimensions.font16,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
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
          height: 60.h, // Adjust the height as needed
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 190.w,
                child: NumberInputPrefabbed.roundedButtons(
                  incDecBgColor: const Color(0xFF890010),
                  controller: counterTextEditingController,
                  min: 1,
                  max: 5,
                  initialValue: 1,
                  buttonArrangement: ButtonArrangement.incRightDecLeft,
                ),
              ),
              SizedBox(width: 10,),
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
                  backgroundColor: const Color(0xFF890010),
                ),
                child: Text(
                  'Add to Cart',
                  style: TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Future<void> addToFavorites(String productsID, String customersUID) async {
    try {
      await FirebaseFirestore.instance
          .collection('favorites')
          .doc(customersUID)
          .collection('items')
          .doc(productsID)
          .set({
        'productsID': widget.model.productsID,
        'thumbnailUrl': widget.model.thumbnailUrl,
        'productTitle': widget.model.productTitle,
        'productPrice': widget.model.productPrice,
        'productQuantity': widget.model.productQuantity,
        'productDescription': widget.model.productDescription,
        'menuID': widget.model.menuID,
        'sellersUID': widget.model.sellersUID,


        'timestamp': FieldValue.serverTimestamp(),
      });
      Fluttertoast.showToast(
        msg: 'Item added to favorites',
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppColors().red,
        textColor: Colors.white,
        fontSize: 12.sp
      );

      print('Item added to favorites');
    } catch (e) {
      // Show a toast message for the error
      Fluttertoast.showToast(
        msg: 'Error adding item to favorites: $e',
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );

      print('Error adding item to favorites: $e');
    }
  }

}
