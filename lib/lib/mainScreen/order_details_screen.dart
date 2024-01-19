import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_foodtogo/lib/CustomersWidgets/progress_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../global/global.dart';

class OrderDetailsScreen extends StatefulWidget {

  final String? orderID;

  OrderDetailsScreen({this.orderID}),

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {

  String orderStatus = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: FutureBuilder<DocumentSnapshot>(future:  FirebaseFirestore.instance
            .collection("users")
        .doc(sharedPreferences!.getString("uid"))
        .collection("orders")
        .doc(widget.orderID)
        .get(),
    builder: (c, snapshot)
    {
      Map dataMap;
      if(snapshot.hasData)
        {
          dataMap = snapshot.data!.data()! as Map<String, dynamic>;
          orderStatus = dataMap["status"].toString();
        }
      return snapshot.hasData ?  Container(
        child: Column(
          children: [

          ],
        ),
      ) : Center(child: circularProgress(),);
    },
      ),
      ),
    );
  }
}
