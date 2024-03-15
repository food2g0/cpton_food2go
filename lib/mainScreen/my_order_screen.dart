import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_foodtogo/CustomersWidgets/Cancelled_OrderCard.dart';

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
  final List<String> _tabs = ['To Pay', 'Order Placed', 'Picked', 'Delivered', 'Cancelled'];
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (c)=>HomeScreen()));
        return false;
      },
      child: SafeArea(
        child: DefaultTabController(
          length: 5,
          child: Scaffold(
            backgroundColor: AppColors().white1,
            appBar: AppBar(
              automaticallyImplyLeading: true,
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
                    icon: Icon(Icons.payment, size: 16.sp),
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
                    icon: Icon(Icons.reorder, size: 16.sp),
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
                    icon: Icon(Icons.check, size: 16.sp),
                    child: Text(
                      'Picked',
                      style: TextStyle(
                        fontSize: 6.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),

                  Tab(
                    icon: Icon(Icons.delivery_dining, size: 16.sp),
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
                    icon: Icon(Icons.cancel, size: 16.sp),
                    child: Text(
                      'Cancelled',
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
                _buildOrderListPick('Order Picked'),
                _buildOrderListDelivered('Delivered'),
                _buildOrderListCancelled('Cancelled'),


              ],
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
            return Center(
              child: SizedBox(
                  height: 24.h,
                  width: 24.w,
                  child: CircularProgressIndicator()),
            );
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
            return Center(
              child: SizedBox(
                  height: 24.h,
                  width: 24.w,
                  child: CircularProgressIndicator()),
            );
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
  Widget _buildOrderListPick(String status) {
    return
      StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(sharedPreferences!.getString("uid"))
            .collection("orders")
            .where("status", isEqualTo: "accepted")
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
          return Center(
            child: SizedBox(
                height: 24.h,
                width: 24.w,
                child: CircularProgressIndicator()),
          );
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

  Widget _buildOrderListCancelled(String status) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc(sharedPreferences!.getString("uid"))
          .collection("orders")
          .where("status", isEqualTo: "cancel")
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: SizedBox(
                height: 24.h,
                width: 24.w,
                child: CircularProgressIndicator()),
          );
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
                CancelledOrderCard(
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
