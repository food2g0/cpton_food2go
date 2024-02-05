import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_foodtogo/lib/CustomersWidgets/delivered_order_card.dart';
import 'package:cpton_foodtogo/lib/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../CustomersWidgets/order_card.dart';
import '../CustomersWidgets/progress_bar.dart';
import '../assistantMethods/assistant_methods.dart';
import '../global/global.dart';
import '../models/menus.dart';
import 'chat_screen.dart';
import 'food_page_body.dart';
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
  final List<String> _tabs = ['To Pay', 'Picking', 'Delivered'];
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
                  icon: Icon(Icons.shopping_cart, size: 16.sp),
                  text: 'To Pay',

                ),
                Tab(
                  icon: Icon(Icons.directions_bike, size: 16.sp,),
                  text: 'Picking',
                ),
                Tab(
                  icon: Icon(Icons.check_circle, size: 16.sp),
                  text: 'Delivered',
                ),
              ],
              labelStyle: TextStyle(fontSize: 12.sp, fontFamily: "Poppins", fontWeight: FontWeight.w600),
            ),
          ),
          body: TabBarView(
            children: [
              _buildOrderListNormal('To Pay'),
              _buildOrderListAccepted('Picking'),
              _buildOrderListDelivered('Delivered'),

            ],
          ),
          bottomNavigationBar: Theme(
            data: Theme.of(context).copyWith(
              canvasColor: AppColors().black,
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
  }

  Widget _buildOrderListNormal(String status) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc(sharedPreferences!.getString("uid"))
          .collection("orders")
          .where("status", isEqualTo: "ToPay")
          .snapshots(),
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            return FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection("items")
                  .where("productsID", whereIn: separateOrderItemIDs((snapshot.data!.docs[index].data()! as Map<String, dynamic>)["productsIDs"]))
                  .where("orderBy", whereIn: (snapshot.data!.docs[index].data()! as Map<String, dynamic>)["uid"])
                  .orderBy("publishedDate", descending: true)
                  .get(),
              builder: (context, snap) {
                return snap.hasData
                    ? OrderCard(
                  itemCount: snap.data!.docs.length,
                  data: snap.data!.docs,
                  sellerName: widget.model?.sellersName,
                  orderID: snapshot.data!.docs[index].id,
                  status: status,
                  seperateQuantitiesList: separateOrderItemQuantities((snapshot.data!.docs[index].data()! as Map<String, dynamic>)["productsIDs"]),
                )
                    : Center(child: circularProgress());
              },
            );
          },
        )
            : Center(child: circularProgress());
      },
    );
  }

  Widget _buildOrderListAccepted(String status) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc(sharedPreferences!.getString("uid"))
          .collection("orders")
          .where("status", isEqualTo: "accepted")
          .snapshots(),
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            return FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection("items")
                  .where("productsID", whereIn: separateOrderItemIDs((snapshot.data!.docs[index].data()! as Map<String, dynamic>)["productsIDs"]))
                  .where("orderBy", whereIn: (snapshot.data!.docs[index].data()! as Map<String, dynamic>)["uid"])
                  .orderBy("publishedDate", descending: true)
                  .get(),
              builder: (context, snap) {
                return snap.hasData
                    ? OrderCard(
                  itemCount: snap.data!.docs.length,
                  data: snap.data!.docs,
                  sellerName: widget.model?.sellersName,
                  orderID: snapshot.data!.docs[index].id,
                  status: status,
                  seperateQuantitiesList: separateOrderItemQuantities((snapshot.data!.docs[index].data()! as Map<String, dynamic>)["productsIDs"]),
                )
                    : Center(child: circularProgress());
              },
            );
          },
        )
            : Center(child: circularProgress());
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
        return snapshot.hasData
            ? ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            return FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection("items")
                  .where("productsID", whereIn: separateOrderItemIDs((snapshot.data!.docs[index].data()! as Map<String, dynamic>)["productsIDs"]))
                  .where("orderBy", whereIn: (snapshot.data!.docs[index].data()! as Map<String, dynamic>)["uid"])
                  .orderBy("publishedDate", descending: true)
                  .get(),
              builder: (context, snap) {
                return snap.hasData
                    ? DeliveredOrderCard(
                  itemCount: snap.data!.docs.length,
                  data: snap.data!.docs,
                  sellerName: widget.model?.sellersName,
                  orderID: snapshot.data!.docs[index].id,
                  status: status,
                  seperateQuantitiesList: separateOrderItemQuantities((snapshot.data!.docs[index].data()! as Map<String, dynamic>)["productsIDs"]),
                )
                    : Center(child: circularProgress());
              },
            );
          },
        )
            : Center(child: circularProgress());
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
