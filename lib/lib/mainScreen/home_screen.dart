import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_foodtogo/lib/CustomersWidgets/custom_text_field.dart';

import 'package:cpton_foodtogo/lib/theme/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import '../CustomersWidgets/CustomShape.dart';
import '../CustomersWidgets/Favorite_design_widget.dart';
import '../CustomersWidgets/customers_drawer.dart';
import '../CustomersWidgets/progress_bar.dart';
import '../assistantMethods/cart_item_counter.dart';
import '../global/global.dart';
import '../models/items.dart';
import 'SearchResultScreen.dart';
import 'cart_screen.dart';
import 'food_page_body.dart';
import 'chat_screen.dart'; // Import the ChatScreen

class HomeScreen extends StatefulWidget {
  final dynamic model;
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

  @override
  void initState() {
    super.initState();

    // Initialize the _pages list here
    _pages = [
      const FoodPageBody(),
      FavoritesScreen(),
      NotificationScreen(),
      ChatScreen(),
    ];
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
    initSearchingRestaurant(String textEntered) {
          restaurantsDocumentsList = FirebaseFirestore.instance.collection("sellers")
          .where("sellersName", isGreaterThanOrEqualTo: textEntered)
          .get();
    }

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
                      width: 24.w, // Adjust width as needed
                      height: 24.h, // Adjust height as needed
                    ),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Image.asset(
                      'images/heart.png', // Replace 'path_to_favorites_icon' with the path to your favorites icon asset
                      width: 24, // Adjust width as needed
                      height: 24, // Adjust height as needed
                    ),
                    label: 'Favorites',
                  ),
                  BottomNavigationBarItem(
                    icon: Image.asset(
                      'images/bell.png', // Replace 'path_to_notifications_icon' with the path to your notifications icon asset
                      width: 24, // Adjust width as needed
                      height: 24, // Adjust height as needed
                    ),
                    label: 'Notification',
                  ),
                  BottomNavigationBarItem(
                    icon: Image.asset(
                      'images/message.png', // Replace 'path_to_messages_icon' with the path to your messages icon asset
                      width: 24, // Adjust width as needed
                      height: 24, // Adjust height as needed
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
                          MaterialPageRoute(builder: (c) => CartScreen(sellersUID: '',)));
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
                        width: 24.w, // Adjust width as needed
                        height: 24.h, // Adjust height as needed
                      ),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Image.asset(
                        'images/heart.png', // Replace 'path_to_favorites_icon' with the path to your favorites icon asset
                        width: 24, // Adjust width as needed
                        height: 24, // Adjust height as needed
                      ),
                      label: 'Favorites',
                    ),
                    BottomNavigationBarItem(
                      icon: Image.asset(
                        'images/bell.png', // Replace 'path_to_notifications_icon' with the path to your notifications icon asset
                        width: 24, // Adjust width as needed
                        height: 24, // Adjust height as needed
                      ),
                      label: 'Notification',
                    ),
                    BottomNavigationBarItem(
                      icon: Image.asset(
                        'images/message.png', // Replace 'path_to_messages_icon' with the path to your messages icon asset
                        width: 24, // Adjust width as needed
                        height: 24, // Adjust height as needed
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

  @override
  void initState() {
    super.initState();
    customersUID = getCurrentUserUID(); // Initialize customersUID in initState
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
      backgroundColor: AppColors().white1,
      appBar: AppBar(
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
            color: AppColors().black,
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
                childAspectRatio: 0.77,
              ),
              itemCount: itemsList.length,
              itemBuilder: (context, index) {
                Items item = itemsList[index];
                return FavoriteDesignWidget(
                  model: item,
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
    return Container(
      color: Colors.black, // Set the color you want for the notification screen
      child: Center(
        child: Text(
          'Notification Screen',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24.0,
          ),
        ),
      ),
    );
  }
}
