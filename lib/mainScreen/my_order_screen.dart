import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../CustomersWidgets/delivered_order_card.dart';
import '../CustomersWidgets/order_card.dart';

import '../global/global.dart';
import '../models/menus.dart';
import '../theme/colors.dart';
import 'chat_screen.dart';

import 'home_screen.dart';

class MyOrderScreen extends StatefulWidget {
  final Menus? model;
  String? addressID;
  double? totalAmount;
  String? sellerUID;
  String? paymentMode;

  MyOrderScreen({this.model, this.addressID, this.paymentMode, this.sellerUID, this.totalAmount});

  @override
  _MyOrderScreenState createState() => _MyOrderScreenState();
}

class _MyOrderScreenState extends State<MyOrderScreen> {
  final List<String> _tabs = ['To Pay', 'Picking', 'Delivered', 'To Rate'];
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: SafeArea(
        child: DefaultTabController(
          length: _tabs.length,
          child: Scaffold(
            backgroundColor: AppColors().white1,
            appBar: AppBar(
              backgroundColor: AppColors().red,
              title:  Text(
                "Orders",
                style: TextStyle(fontFamily: "Poppins", fontSize: 14.sp, color: AppColors().white),
              ),
              bottom: TabBar(
                indicatorColor: AppColors().white,
                labelColor: AppColors().white,
                unselectedLabelColor: AppColors().white,
                tabs: [

                  Tab(
                    icon: Icon(Icons.directions_bike, size: 16.sp),
                    child: Text(
                      'To Pay',
                      style: TextStyle(
                        fontSize: 6.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  Tab(
                    icon: Icon(Icons.directions_bike, size: 16.sp),
                    child: Text(
                      'Order Placed',
                      style: TextStyle(
                        fontSize: 6.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),

                  Tab(
                    icon: Icon(Icons.directions_bike, size: 16.sp),
                    child: Text(
                      'Delivered',
                      style: TextStyle(
                        fontSize: 6.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  Tab(
                    icon: Icon(Icons.directions_bike, size: 16.sp),
                    child: Text(
                      'To Rate',
                      style: TextStyle(
                        fontSize: 6.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _buildOrderListNormal('To Pay'),
                _buildOrderListAccepted('Order Placed'),
                _buildOrderListDelivered('Delivered'),
                _buildOrderListToRate('To Rate'),

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
          ),
        ),
      ),
    );
  }

  Widget _buildOrderListNormal(String status) {
    return
      StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(sharedPreferences!.getString("uid"))
            .collection("orders")
            .where("status", isEqualTo: "ToPay")
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
      );
  }

  Widget _buildOrderListAccepted(String status) {
    return
      StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(sharedPreferences!.getString("uid"))
            .collection("orders")
            .where("status", isEqualTo: "normal")
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
      );
  }

  Widget _buildOrderListDelivered(String status) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc(sharedPreferences!.getString("uid"))
          .collection("orders")
          .where("status", isEqualTo: "ended")
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

            dynamic productsData = orders[index].get("products");
            List<Map<String, dynamic>> productList = [];
            if (productsData != null && productsData is List) {
              productList =
              List<Map<String, dynamic>>.from(productsData);
            }

            print("Product List: $productList"); // Print productList

            return Column(
              children: [
                DeliveredOrderCard(
                  itemCount: productList.length,
                  data: productList,
                  orderID: snapshot.data!.docs[index].id,
                  sellerName: "", // Pass the seller's name
                  totalAmount: snapshot.data!.docs[index].get("totalAmount").toString(),
                  cartItems: productList,
                    status: status, // Pass the products list
                ),
                if (productList.length > 1)
                  SizedBox(height: 10), // Adjust the height as needed
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildOrderListToRate(String status) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc(sharedPreferences!.getString("uid"))
          .collection("orders")
          .where("status", isEqualTo: "rated")
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

            dynamic productsData = orders[index].get("products");
            List<Map<String, dynamic>> productList = [];
            if (productsData != null && productsData is List) {
              productList =
              List<Map<String, dynamic>>.from(productsData);
            }

            print("Product List: $productList"); // Print productList

            return Column(
              children: [
                DeliveredOrderCard(
                  itemCount: productList.length,
                  data: productList,
                  orderID: snapshot.data!.docs[index].id,
                  sellerName: "", // Pass the seller's name
                  totalAmount: snapshot.data!.docs[index].get("totalAmount").toString(),
                  cartItems: productList,
                  status: status, // Pass the products list
                ),
                if (productList.length > 1)
                  SizedBox(height: 10), // Adjust the height as needed
              ],
            );
          },
        );
      },
    );
  }



  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Use Navigator to navigate to the corresponding page based on the selected index
    switch (index) {
      case 0:
      // Navigate to HomeScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
        break;
      case 1:
      // Navigate to Favorites
      // Replace PlaceholderWidget with the actual widget for Favorites
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => FavoritesScreen()),
        );
        break;
      case 2:
      // Navigate to Notifications
      // Replace PlaceholderWidget with the actual widget for Notifications
      //   Navigator.pushReplacement(
      //     // context,
      //     // MaterialPageRoute(builder: (context) => PlaceholderWidget(label: 'Notifications')),
      //   );
        break;
      case 3:
      // Navigate to ChatScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ChatScreen()),
        );
        break;
    }
  }
}