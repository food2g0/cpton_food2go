import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_foodtogo/lib/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../CustomersWidgets/order_card.dart';
import '../CustomersWidgets/progress_bar.dart';
import '../assistantMethods/assistant_methods.dart';
import '../global/global.dart';
import '../models/menus.dart';

class MyOrderScreen extends StatefulWidget {
  final Menus? model;

  const MyOrderScreen({Key? key, this.model}) : super(key: key);

  @override
  _MyOrderScreenState createState() => _MyOrderScreenState();
}

class _MyOrderScreenState extends State<MyOrderScreen> {
  final List<String> _tabs = ['Normal', 'Picking', 'Delivered'];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DefaultTabController(
        length: _tabs.length,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors().red,
            title: const Text(
              "Orders",
              style: TextStyle(fontFamily: "Poppins", fontSize: 16, color: Colors.white),
            ),
            bottom: TabBar(
              indicatorColor: AppColors().white,
              labelColor: AppColors().white,
              unselectedLabelColor: AppColors().white,
              tabs: [
                Tab(
                  icon: Icon(Icons.shopping_cart,size: 16.sp), // Add icon to the tab
                  text: 'To Pay',
                ),
                Tab(
                  icon: Icon(Icons.directions_bike,size: 16.sp,),
                  text: 'Picking',
                ),
                Tab(
                  icon: Icon(Icons.check_circle,size: 16.sp),
                  text: 'Delivered',
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _buildOrderListNormal('To Pay'),
              _buildOrderListAccepted('Picking'),
              _buildOrderListDelivered('Delivered'),
            ],
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
          .where("status", isEqualTo: "normal")
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
  _buildOrderListAccepted(String status){
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
  _buildOrderListDelivered(String status){
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
                    ? OrderCard(
                  itemCount: snap.data!.docs.length,
                  data: snap.data!.docs,
                  sellerName: widget.model?.sellersName,
                  orderID: snapshot.data!.docs[index].id,
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
}
