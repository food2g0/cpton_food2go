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
  String selectedFlavorsPrice = '';
  String selectedVariationName = ''; // Define selected variation name
  String selectedFlavorsName = '';

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
      backgroundColor: AppColors().white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(200.0), // Set the preferred height of the AppBar
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0, // Remove elevation
          flexibleSpace: Container(
            decoration: BoxDecoration(
            ),
            child: ClipRRect(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                  ),
                  Container(
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
      ),
      body: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0), // Adjust the radius as needed
            topRight: Radius.circular(20.0), // Adjust the radius as needed
          ),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: CustomScrollView(
            slivers: <Widget>[
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
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          ),
                        ],
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
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors().black,
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
                                  color: AppColors().red,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10.0),
                          Row(
                            children: [
                              Image.asset(
                                'images/peso.png',
                                width: 14.w,
                                height: 14.h,
                                color: AppColors().red,
                              ),
                              SizedBox(width: 10.0),
                              Text(
                                ' ${selectedVariationPrice != '' ? selectedVariationPrice : widget.model.productPrice?.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontFamily: "Poppins",
                                  fontSize: 12.0.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors().black1,
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
                          Icon(Icons.delivery_dining, size: 24.sp, color: AppColors().red),
                          Text(
                            "  Cost ",
                            style: TextStyle(
                                fontFamily: "Poppins",
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors().black),
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
                  SizedBox(height: 10.h,),
                  // Product Description
                  Container(
                    color: AppColors().white,
                    child: Padding(
                      padding: EdgeInsets.all(16.0.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.description, size: 15.0.sp),
                              SizedBox(width: 10.0.w),
                              Text(
                                "Product Description",
                                style: TextStyle(
                                    fontFamily: "Poppins",
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors().black),
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
                                color: AppColors().black1,
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
                        Icon(Icons.reviews, size: 15.0.sp),
                        SizedBox(width: 10.0.w),
                        Text(
                          "Product Reviews",
                          style: TextStyle(
                              color: AppColors().black,
                              fontSize: 10.sp,
                              fontFamily: "Poppins",
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 10.0.w),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'View All Reviews',
                            style: TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors().red,
                            ),
                          ),
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
                        return Center(child: CircularProgressIndicator(
                        ));
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
                ],
                ),
              ),
            ]
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: AppColors().backgroundWhite,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ElevatedButton(
            onPressed: () {
              _showVariationsBottomSheet(context);
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.w)
              ),
              backgroundColor: AppColors().red,
            ),
            child: Text(
              'Add to Cart',
              style: TextStyle(
                fontFamily: "Poppins",
                fontSize: 10.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );




  }

  void _showVariationsBottomSheet(BuildContext context) {


    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allow the bottom sheet to occupy full screen height
      builder: (context) {
        return SingleChildScrollView( // Enable scrolling if content exceeds screen height
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Your bottom sheet content
                Text(
                  'Variations',
                  style: TextStyle(fontSize: 10.0.sp,
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 16.0),
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

                    var variations = (snapshot.data!)['variations'] ?? [];


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
                                  child: Text(firstLetter,
                                    style: TextStyle(
                                        color: AppColors().black,
                                        fontSize: 10.sp,
                                        fontFamily: "Poppins"
                                    ),),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
                // Add your variation widgets here
                Text(
                  'Flavors',
                  style: TextStyle(fontSize: 10.0.sp,
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 16.0.h),
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

                    var flavors = (snapshot.data!)['flavors'] ?? [];

                    if (flavors.isNotEmpty) {
                      // If variations exist, show variation options UI
                      return Wrap(
                        children: flavors.map<Widget>((variation) {
                          String flavorsName = variation['name'];
                          String firstLetter = flavorsName;

                          // Return a button for each variation wrapped in padding for spacing
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0), // Adjust the spacing as needed
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.w)
                                  )
                              ),
                              onPressed: () {},
                              child: Text(
                                firstLetter,
                                style: TextStyle(
                                    color: AppColors().black,
                                    fontSize: 10.sp,
                                    fontFamily: "Poppins"
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    } else {
                      return Container();
                    }
                  },
                ),

                // Add your flavors widgets here
                Row(
                  children: [
                    IconButton(
                      icon: Image.asset(
                        'images/minus.png',
                        width: 26.h,
                        height: 26.h,
                        color: AppColors().red,
                      ),
                      onPressed: () {
                        setState(() {
                          int currentValue = int.tryParse(counterTextEditingController.text) ?? 1;
                          if (currentValue > 1) {
                            counterTextEditingController.text = (currentValue - 1).toString();
                          }
                        });
                      },
                    ),
                    SizedBox(
                      width: 60.w,
                      child: TextField(
                        controller: counterTextEditingController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Image.asset(
                        'images/adds.png',
                        width: 26.h,
                        height: 26.h,
                        color: AppColors().red,
                      ),
                      onPressed: () {
                        setState(() {
                          int currentValue = int.tryParse(counterTextEditingController.text) ?? 1;
                          if (currentValue < 5) { // Limit the increment to 5
                            counterTextEditingController.text = (currentValue + 1).toString();
                          }
                        });
                      },
                    ),

                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    int itemCounter = int.tryParse(counterTextEditingController.text) ?? 1;

                    if (itemCounter <= 0) {
                      Fluttertoast.showToast(msg: "Quantity must not be 0");
                      return;
                    }

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
                          selectedVariationName,
                          selectedFlavorsName,

                        );

                      } else {
                        // If no variation is selected, use the default product price
                        double price = widget.model.productPrice.toDouble(); // Convert integer to double

                        addItemToCart(
                          widget.model.productsID,
                          context,
                          itemCounter,
                          widget.model.thumbnailUrl,
                          widget.model.productTitle,
                          price,
                          selectedVariationName,
                          selectedFlavorsName,
                        );
                      }

                    }
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    backgroundColor: AppColors().red,
                  ),
                  child: Text(
                    'Add to Cart',
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }



  Widget buildReviewItem(Map<String, dynamic> reviewData) {
    return Padding(
      padding: EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(

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