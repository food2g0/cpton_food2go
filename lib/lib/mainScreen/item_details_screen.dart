import 'dart:math';
import 'package:cpton_foodtogo/lib/mainScreen/home_screen.dart';
import 'package:cpton_foodtogo/lib/theme/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:number_inc_dec/number_inc_dec.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_star_rating_null_safety/smooth_star_rating_null_safety.dart';
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
  FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController counterTextEditingController = TextEditingController();
  bool isCartEmpty = separateItemIDs().isEmpty;
  int cartItemCount = 0;
  late String customersUID; // Declare customersUID without initialization
  String selectedVariationPrice = '';

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

  // Function to calculate average rating from Firestore document snapshots
  double calculateAverageRating(List<DocumentSnapshot> docs) {
    if (docs.isEmpty) return 0.0;

    var ratings = docs
        .map((doc) => (doc.data() as Map<String, dynamic>)['rating'] as num?)
        .toList();

    double averageRating = 0;
    if (ratings.isNotEmpty) {
      var totalRating = ratings
          .map((rating) => rating ?? 0)
          .reduce((a, b) => a + b);
      averageRating = totalRating / ratings.length;
    }

    return averageRating;
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.model?.thumbnailUrl ?? 'default_image_url.jpg';

    return Scaffold(
      body: Container(
        child: CustomScrollView(
          slivers: <Widget>[
        SliverAppBar(
        expandedHeight: 200.0.h,
          backgroundColor: Colors.transparent,
          elevation: 1.0,
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
                        builder: (c) => CartScreen(sellersUID: widget.model!.sellersUID),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.shopping_cart_rounded,
                    color: AppColors().white,
                  ),
                ),
                Positioned(
                  top: 2,
                  right: 2,
                  child: Consumer<CartItemCounter>(
                    builder: (context, counter, c) {
                      return Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors().white,
                        ),
                        padding: EdgeInsets.all(4.0.w), // Adjust the padding as needed
                        child: Text(
                          counter.count.toString(),
                          style: TextStyle(
                            color: AppColors().red,
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
        SliverList(
          delegate: SliverChildListDelegate([
            SizedBox(height: 15.0.h),
            // Product Title, Price, and Ratings
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Color(0xFF890010), width: 1.0),
                  borderRadius: BorderRadius.circular(10.0), // Adjust the value as needed
                ),
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.fastfood_outlined, size: 20.0.sp, color: AppColors().red),
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
                            addToFavorites(widget.model.productsID, customersUID);
                          },
                          child: Icon(
                            Icons.favorite_border,
                            size: 30.0.sp,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("items")
                          .doc(widget.model.productsID)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }

                        var variations = (snapshot.data! as DocumentSnapshot)['variations'] ?? [];


                        if (variations.isNotEmpty) {
                          // If variations exist, show variation options UI
                          return Row(
                            children: [
                              SizedBox(height: 10),
                              // Display buttons for each variation
                              Row(
                                children: variations.map<Widget>((variation) {
                                  String variationName = variation['name'];
                                  String variationPrice = variation['price'];


                                  // Check if variation price is not null
                                  String firstLetter = variationName.substring(0, 1);

                                  // Return a button for each variation wrapped in padding for spacing
                                  return Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8.0), // Adjust the spacing as needed
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8.w)
                                          )
                                      ),
                                      onPressed: () {
                                        // Set the selected variation price
                                        print('$variationPrice');
                                        setState(() {
                                          selectedVariationPrice = variationPrice;
                                        });
                                        // Handle button press for this variation
                                        // You can implement the logic here to perform actions when a variation button is pressed
                                        print('Selected variation: $variationPrice');
                                      },
                                      child: Text(firstLetter),
                                    ),
                                  );
                                                                }).toList(),
                              ),
                            ],
                          );
                        } else {
                          // If no variations exist, return an empty container
                          return Container();
                        }
                      },
                    ),
                    SizedBox(height: 10.0),
                    Row(
                      children: [
                        Image.asset(
                          'images/peso.png',
                          width: 14,
                          height: 14,
                          color: AppColors().red,
                        ),
                        SizedBox(width: 10.0),
                        Text(
                          ' ${selectedVariationPrice != '' ? selectedVariationPrice : widget.model.productPrice?.toStringAsFixed(2)}',
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
                    buildRatingSection(),
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
                    Icon(Icons.delivery_dining, size: 24.sp, color: Color(0xFF890010)),
                    Text(
                      "  Cost ",
                      style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black),
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
                padding: EdgeInsets.all(16.0.w),
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
                              color: Color(0xFF890010)),
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
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 10.0.w),
                  TextButton(
                      onPressed: () {  },
                      child: Text('View All Reviews', style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors().red,
                      ), )
                  ),
                ],
              ),
            ),

            // Display Single Review
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("items")
                  .doc(widget.model.productsID)
                  .collection("itemRecord")
                  .limit(1)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                var reviews = snapshot.data!.docs.map((doc) {
                  final rating = (doc.data() as Map<String, dynamic>)['rating'] as num?;
                  final comment = (doc.data() as Map<String, dynamic>)['comment'] as String?;
                  final userName = (doc.data() as Map<String, dynamic>)['userName'] as String?;
                  return {'rating': rating, 'comment': comment, 'userName': userName};
                }).toList();

                // Display Single Review
                if (reviews.isNotEmpty) {
                  return buildReviewItem(reviews[0]);
                } else {
                  return Container(); // No reviews to display
                }
              },
            ),

            // "View All Reviews" button

          ],
          )
        )
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
                  int itemCounter = int.parse(counterTextEditingController.text);

                  List<String> separateItemIDsList = separateItemIDs();
                  if (separateItemIDsList.contains(widget.model.productsID)) {
                    Fluttertoast.showToast(msg: "Item is already in a cart");
                  } else {
                    // Check if a variation price is selected
                    if (selectedVariationPrice.isNotEmpty) {
                      double price = double.parse(selectedVariationPrice);


                      addItemToCart(

                        widget.model.productsID,
                        context,
                        itemCounter,
                        widget.model.thumbnailUrl,
                        widget.model.productTitle,
                        price,

                      );

                    } else {
                      // If no variation is selected, use the default product price
                      double price = double.parse(widget.model.productPrice);



                      addItemToCart(

                        widget.model.productsID,
                        context,
                        itemCounter,
                        widget.model.thumbnailUrl,
                        widget.model.productTitle,
                        price,

                      );


                    }
                  }
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


  Widget buildReviewItem(Map<String, dynamic> reviewData) {
    return Padding(
      padding: EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors().red,
                    child: Text(
                      (reviewData['userName'] as String?)?.substring(0, 1) ?? '?',
                      style: TextStyle(fontSize: 12.sp, color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'User', // Replace 'User' with the actual user's name
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors().black1,
                        ),
                      ),
                      SizedBox(height: 5),
                      SmoothStarRating(
                        rating: (reviewData['rating'] as num?)?.toDouble() ?? 0.0,
                        allowHalfRating: false,
                        starCount: 5,
                        size: 16.sp,
                        color: Colors.yellow,
                        borderColor: Colors.black45,
                      ),
                      Text(
                        'Comment: ${(reviewData['comment'] as String?) ?? ""}',
                        style: TextStyle(
                          fontFamily: "Poppins",
                          color: AppColors().black1,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }

  Widget buildRatingSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("items")
          .doc(widget.model.productsID)
          .collection("itemRecord")
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        double averageRating = calculateAverageRating(snapshot.data!.docs);

        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10.h),
                Row(
                  children: [
                    SmoothStarRating(
                      rating: averageRating,
                      allowHalfRating: false,
                      starCount: 5,
                      size: 25,
                      color: Colors.yellow,
                      borderColor: Colors.black45,
                    ),
                    SizedBox(width: 5),
                    Text(
                      '${averageRating.toStringAsFixed(2)}/5.00',
                      style: TextStyle(
                          fontFamily: "Poppins",
                          color: AppColors().black1,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      },
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
        fontSize: 12.sp,
      );

      print('Item added to favorites');
    } catch (e) {
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
