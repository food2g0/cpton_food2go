import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_foodtogo/lib/CustomersWidgets/custom_text_field.dart';

import 'package:cpton_foodtogo/lib/theme/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
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
            canvasColor: AppColors().black,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors().red,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
              ),
              child: BottomNavigationBar(
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.favorite_border),
                    label: 'Favorites',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.notifications_on_rounded),
                    label: 'Notification',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.chat_bubble_outline),
                    label: 'Messages',
                  ),
                ],
                currentIndex: _selectedIndex,
                selectedItemColor: AppColors().red,
                unselectedItemColor: AppColors().white,
                selectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: "Poppins",
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
          backgroundColor: AppColors().white1,
          appBar: AppBar(

            iconTheme: IconThemeData(color: AppColors().black),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                color: AppColors().white1,
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
                      color: AppColors().black,
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
                      color: AppColors().red, // Adjust color as needed
                      fontSize: 10.sp, // Adjust font size as needed
                      fontFamily: "Poppins",
                    ),
                  ),
                ),
              ],
            ),

            centerTitle: false,
            automaticallyImplyLeading: true,
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
                          padding: EdgeInsets.all(4.0.w),
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
                height: 80.h,
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
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
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
              SizedBox(height: 20.h),
              Expanded(
                child: SafeArea(
                  child: _pages[_selectedIndex],
                ),
              ),
            ],
          ),
          bottomNavigationBar: Theme(
            data: Theme.of(context).copyWith(
              canvasColor: AppColors().black,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10.0),
                topRight: Radius.circular(10.0),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors().red,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0),
                  ),
                ),
                child: BottomNavigationBar(
                  items: const <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home_outlined),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.favorite_border),
                      label: 'Favorites',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.notifications_on_rounded),
                      label: 'Notification',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.chat_bubble_outline),
                      label: 'Messages',
                    ),
                  ],
                  currentIndex: _selectedIndex,
                  selectedItemColor: AppColors().red,
                  unselectedItemColor: AppColors().white,
                  selectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: "Poppins",
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
                childAspectRatio: 0.67,
              ),
              itemCount: itemsList.length,
              itemBuilder: (context, index) {
                Items item = itemsList[index];
                return FavoriteDesignWidget(
                  model: item,
                  context: context,
                  onRemove: () {
                    removeFromFavorites(item.productsID);
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
