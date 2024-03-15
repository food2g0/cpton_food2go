import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';

import 'package:provider/provider.dart';
import '../CustomersWidgets/CustomShape.dart';
import '../CustomersWidgets/Favorite_design_widget.dart';
import '../CustomersWidgets/customers_drawer.dart';
import '../CustomersWidgets/order_card.dart';
import '../CustomersWidgets/progress_bar.dart';
import '../assistantMethods/cart_item_counter.dart';
import '../assistantMethods/message_counter.dart';
import '../global/global.dart';
import '../models/items.dart';
import '../models/menus.dart';
import '../push_notification/push_notification_system.dart';
import '../theme/colors.dart';
import 'SearchResultScreen.dart';
import 'cart_screen.dart';
import 'food_page_body.dart';
import 'chat_screen.dart'; // Import the ChatScreen

class HomeScreen extends StatefulWidget {
  final Menus? model;
  final String? sellersUID;
  final BuildContext? context;
  const HomeScreen({Key? key, this.model, this.sellersUID, this.context})
      : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List<Widget> _pages = [];
  Position? _currentUserPosition;
  double? distanceInMeter = 0.0;
  double? distanceInKm;

  Future<void> _getDistance(double storeLat, double storeLng) async {
    _currentUserPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    distanceInMeter = await Geolocator.distanceBetween(
      _currentUserPosition!.latitude,
      _currentUserPosition!.longitude,
      storeLat,
      storeLng,
    );
    _convertDistanceToKm(); // Convert distance to kilometers
  }

  void _convertDistanceToKm() {
    if (distanceInMeter != null) {
      setState(() {
        distanceInKm = distanceInMeter! / 1000; // Convert meters to kilometers
      });
    }
  }
  double calculateShippingFee(double distanceInKm) {
    if (distanceInKm <= 4) {
      // If distance is less than or equal to 5km, shipping fee is 50
      return 50.0;
    } else {
      // If distance is more than 5km, add 10 to the shipping fee for every extra km
      return 50.0 + (distanceInKm - 4) * 10.0;
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchStoreLocation();
    readCurrentRiderInformation();
    // Initialize the _pages list here
    _pages = [
      const FoodPageBody(),
      FavoritesScreen(),
      NotificationScreen(),
      ChatScreen(),
    ];
  }
  readCurrentRiderInformation()async
  {
    PushNotificationSystem pushNotificationSystem = PushNotificationSystem();
    pushNotificationSystem.initializeCloudMessaging();
    pushNotificationSystem.generatingAndGetToken();
  }
  Future<void> _fetchStoreLocation() async {
    // Fetch the store location from Firestore collection
    DocumentSnapshot storeSnapshot = await FirebaseFirestore.instance
        .collection('sellers')
        .doc(widget.model?.sellersUID)
        .get();

    if (storeSnapshot.exists) {
      Map<String, dynamic> storeData = storeSnapshot.data() as Map<String, dynamic>;
      double storeLat = storeData['lat'];
      double storeLng = storeData['lng'];
      await _getDistance(storeLat, storeLng); // Wait for _getDistance to complete

    } else {
      print('Store not found in Firestore');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      if (index >= 0 && index < _pages.length) {
        _selectedIndex = index;
      }
    });
  }

  @override
  Widget build(BuildContext context)
  {
    Future<QuerySnapshot>? restaurantsDocumentsList;
    String sellerNameText = "";
    double displayWidth = MediaQuery.of(context).size.width;


    // Check if it's not the ChatScreen
    if (_selectedIndex != 0) {
      return Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
            canvasColor: AppColors().white,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors().red,
              ),
              child: BottomNavigationBar(
                items: <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Image.asset(
                      'images/home.png',
                      // Replace 'path_to_home_icon' with the path to your home icon asset
                      width: 20.w, // Adjust width as needed
                      height: 20.h, // Adjust height as needed
                    ),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Image.asset(
                      'images/heart.png', // Replace 'path_to_favorites_icon' with the path to your favorites icon asset
                      width: 20,// Adjust width as needed
                      height: 20, // Adjust height as needed
                    ),
                    label: 'Favorites',
                  ),
                  BottomNavigationBarItem(
                    icon: Image.asset(
                      'images/lists.png', // Replace 'path_to_notifications_icon' with the path to your notifications icon asset
                      width: 20, // Adjust width as needed
                      height: 20, // Adjust height as needed
                    ),
                    label: 'Orders',
                  ),
                  BottomNavigationBarItem(
                    icon: Stack(
                      children: [
                        Image.asset(
                          'images/message.png',
                          width: 20,
                          height: 20,
                        ),
                        Positioned(
                          top: -9,
                          right: 2,
                          child: Consumer<ChatRoomProvider>(
                            builder: (context, counter, c) {
                              return Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors().white,
                                ),
                                padding: EdgeInsets.all(4.0.w), // Adjust the padding as needed
                                child: Text(
                                  counter.unseenMessagesCount.toString(),
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
                    label: 'Messages',
                  ),
                ],
                currentIndex: _selectedIndex,
                selectedItemColor: AppColors().red,
                unselectedItemColor: AppColors().black1,
                selectedLabelStyle:  TextStyle(
                  fontWeight: FontWeight.w500,
                  fontFamily: "Poppins",
                  fontSize: 10.sp,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontFamily: "Poppins",
                ),
                onTap: _onItemTapped,
              ),
            ),
          ),
        ),

      );
    } else {
      // If it's the HomeScreen, show the Scaffold with AppBar
      return WillPopScope(
        onWillPop: () async{
          return false;
        },
        child: Scaffold(
          backgroundColor: AppColors().backgroundWhite,
          appBar:
          AppBar(
            backgroundColor: AppColors().backgroundWhite,
            toolbarHeight: 90.h,
            iconTheme: IconThemeData(color: AppColors().white),
            elevation: 0.0,
            flexibleSpace: ClipPath(
              clipper: CustomShape(),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors().red,
                ),
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    sharedPreferences!.getString("name")!,
                    style: TextStyle(
                      color: AppColors().white,
                      fontSize: 12.sp,
                      fontFamily: "Poppins",
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Welcome to Food2Go",
                    style: TextStyle(
                      color: AppColors().black, // Adjust color as needed
                      fontSize: 10.sp, // Adjust font size as needed
                      fontFamily: "Poppins",
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              Stack(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (c) => CartScreen()));
                    },
                    icon:  Icon(
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
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(80.h),
              child: Container(
                height:74.h,
                width: MediaQuery.of(context).size.width * 0.9, // Adjust the width as needed
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.w),
                  child: TextField(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (c)=> SearchResultScreen()));
                    },
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                      filled: true,
                      fillColor: AppColors().white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0), // Curved border
                        borderSide: BorderSide.none,
                      ),
                      hintText: "Search...",
                      suffixIcon:
                      Icon(
                        Icons.search,
                        color: AppColors().red,
                      ),
                      hintStyle: TextStyle(
                        fontFamily: "Poppins",
                        color: AppColors().black1,
                      ),
                    ),
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 12.sp,
                      color: Colors.black,
                    ),
                    cursorColor: AppColors().red,
                  ),
                ),
              ),
            ),

          ),

          drawer:  CustomersDrawer(),

          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SafeArea(
                  child: _pages[_selectedIndex],
                ),
              ),
            ],
          ),








          bottomNavigationBar: Theme(
            data: Theme.of(context).copyWith(
              canvasColor: AppColors().white,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors().red,
                ),
                child: BottomNavigationBar(
                  items: <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                      icon: Image.asset(
                        'images/home-button.png',
                        color: AppColors().red,// Replace 'path_to_home_icon' with the path to your home icon asset
                        width: 20.w, // Adjust width as needed
                        height: 20.h, // Adjust height as needed
                      ),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Image.asset(
                        'images/heart.png', // Replace 'path_to_favorites_icon' with the path to your favorites icon asset
                        width: 20, // Adjust width as needed
                        height: 20, // Adjust height as needed
                      ),
                      label: 'Favorites',
                    ),
                    BottomNavigationBarItem(
                      icon: Image.asset(
                        'images/lists.png', // Replace 'path_to_notifications_icon' with the path to your notifications icon asset
                        width: 20, // Adjust width as needed
                        height: 20, // Adjust height as needed
                      ),
                      label: 'Orders',
                    ),
                    BottomNavigationBarItem(
                      icon: Stack(
                        children: [
                          Image.asset(
                            'images/message.png',
                            width: 20,
                            height: 20,
                          ),
                          Positioned(
                            top: -9,
                            right: 2,
                            child: Consumer<ChatRoomProvider>(
                              builder: (context, counter, c) {
                                // Print the message counter
                                print('Message counter: ${counter.unseenMessagesCount}');

                                return Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors().white,
                                  ),
                                  padding: EdgeInsets.all(4.0.w), // Adjust the padding as needed
                                  child: Text(
                                    counter.unseenMessagesCount.toString(),
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
                      label: 'Messages',
                    ),
                  ],

                  currentIndex: _selectedIndex,
                  selectedItemColor: AppColors().red,
                  unselectedItemColor: AppColors().black1,
                  selectedLabelStyle:  TextStyle(
                    fontWeight: FontWeight.w500,
                    fontFamily: "Poppins",
                    fontSize: 10.sp,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.normal,
                    fontFamily: "Poppins",
                  ),
                  onTap: _onItemTapped,
                ),
              ),
            ),
          ),



        ),
      );
    }
  }
}
class FavoritesScreen extends StatefulWidget {
  final dynamic model;

  const FavoritesScreen({Key? key, this.model}) : super(key: key);

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  String customersUID = 'default_uid'; // Default UID
  Position? _currentUserPosition;
  double? distanceInMeter = 0.0;
  double? distanceInKm;

  Future<void> _getDistance(double storeLat, double storeLng) async {
    _currentUserPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    distanceInMeter = await Geolocator.distanceBetween(
      _currentUserPosition!.latitude,
      _currentUserPosition!.longitude,
      storeLat,
      storeLng,
    );
    _convertDistanceToKm(); // Convert distance to kilometers
  }

  void _convertDistanceToKm() {
    if (distanceInMeter != null) {
      setState(() {
        distanceInKm = distanceInMeter! / 1000; // Convert meters to kilometers
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchStoreLocation();
    customersUID = getCurrentUserUID();
  }

  Future<void> _fetchStoreLocation() async {
    // Fetch the store location from Firestore collection
    DocumentSnapshot storeSnapshot = await FirebaseFirestore.instance
        .collection('sellers')
        .doc(widget.model.sellersUID)
        .get();

    if (storeSnapshot.exists) {
      Map<String, dynamic> storeData = storeSnapshot.data() as Map<String, dynamic>;
      double storeLat = storeData['lat'];
      double storeLng = storeData['lng'];
      await _getDistance(storeLat, storeLng); // Wait for _getDistance to complete

    } else {
      print('Store not found in Firestore');
    }
  }



  String getCurrentUserUID() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    } else {
      return 'default_uid';
    }
  }

  Future<void> removeFromFavorites(String productsID) async {
    try {
      print('Removing item from favorites. Product ID: $productsID');
      await FirebaseFirestore.instance
          .collection('favorites')
          .doc(customersUID)
          .collection('items')
          .doc(productsID)
          .delete();

      // Show a toast message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Item removed from favorites'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Show a toast message for the error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error removing item from favorites: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors().backgroundWhite,
      appBar: AppBar(
        iconTheme: IconThemeData(
            color: AppColors().white
        ),
        title: Text(
          'Favorites',
          style: TextStyle(
            fontFamily: "Poppins",
            fontSize: 14.sp,
            color: AppColors().white,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: AppColors().red,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('favorites')
            .doc(customersUID)
            .collection('items')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: circularProgress());
          } else {
            List<Items> itemsList = snapshot.data!.docs.map((doc) {
              return Items.fromJson(doc.data() as Map<String, dynamic>);
            }).toList();

            if (itemsList.isEmpty) {
              return Center(
                child: Text(
                  'No items in favorites.',
                  style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors().black1
                  ),
                ),
              );
            }

            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
                childAspectRatio: 0.97,
              ),
              itemCount: itemsList.length,
              itemBuilder: (context, index) {
                Items item = itemsList[index];
                return FavoriteDesignWidget(
                  model: item,
                  distanceInKm: distanceInKm??0.0,
                  context: context,
                  onRemove: () {
                    final productId = item.productsID ?? ""; // Handle null case
                    removeFromFavorites(productId);
                  },
                );
              },
            );

          }
        },
      ),
    );
  }

}

class NotificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async{
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (c)=>HomeScreen()));
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors().backgroundWhite,
        appBar: AppBar(
          iconTheme: IconThemeData(
              color: AppColors().white
          ),
          title: Text(
            'Orders',
            style: TextStyle(
              fontFamily: "Poppins",
              fontSize: 14.sp,
              color: AppColors().white,
            ),
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              color: AppColors().red,
            ),
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("users")
              .doc(sharedPreferences!.getString("uid"))
              .collection("orders")
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            // Extract orders data from snapshot
            List<DocumentSnapshot> orders = snapshot.data!.docs;

            // Build your UI using the orders data
            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                // Extract order details from each document snapshot
                dynamic productsData = orders[index].get("products");
                List<Map<String, dynamic>> productList = [];
                if (productsData != null && productsData is List) {
                  productList =
                  List<Map<String, dynamic>>.from(productsData);
                }

                print("Product List: $productList"); // Print productList

                return Column(
                  children: [
                    OrderCard(
                      itemCount: productList.length,
                      data: productList,
                      orderID: snapshot.data!.docs[index].id,
                      sellerName: "", // Pass the seller's name
                      paymentDetails:
                      snapshot.data!.docs[index].get("paymentDetails"),
                      totalAmount: snapshot.data!.docs[index].get("totalAmount").toString(),
                      cartItems: productList, // Pass the products list
                    ),
                    if (productList.length > 1)
                      SizedBox(height: 10), // Adjust the height as needed
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}