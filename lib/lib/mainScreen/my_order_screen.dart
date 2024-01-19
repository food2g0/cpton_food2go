import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_foodtogo/lib/CustomersWidgets/order_card.dart';
import 'package:cpton_foodtogo/lib/CustomersWidgets/progress_bar.dart';
import 'package:cpton_foodtogo/lib/assistantMethods/assistant_methods.dart';
import 'package:cpton_foodtogo/lib/global/global.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyOrderScreen extends StatefulWidget
{
  @override
  State<MyOrderScreen> createState() => _MyOrderScreenState();
}


class _MyOrderScreenState extends State<MyOrderScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF890010),
          title: const Text(
            "Orders",
            style: TextStyle(fontFamily: "Poppins"),
          ),
        ),

        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("users")
              .doc(sharedPreferences!.getString("uid"))
              .collection("orders")
              .where("status", isEqualTo: "normal")
              .snapshots(),
          builder: (c, snapshot)

          {
            print("UID: ${sharedPreferences!.getString("productsId")}");
            return snapshot.hasData
                ? ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (c, index)
              {
                print("productsID: ${(snapshot.data!.docs[index].data()! as Map<String, dynamic>)["productsID"]}");

                return FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance
                      .collection("items")
                      .where("productsID", whereIn: separateOrderItemIDs((snapshot.data!.docs[index].data()! as Map<String, dynamic>) ["productsIDs"]))
                      .where("orderBy", whereIn: (snapshot.data!.docs[index].data()! as Map<String, dynamic>)["uid"])
                      .orderBy("publishedDate", descending: true)
                      .get(),
                  builder: (c, snap)
                  {
                    return snap.hasData
                        ? OrderCard(
                      itemCount: snap.data!.docs.length,
                      data: snap.data!.docs,
                      orderID: snapshot.data!.docs[index].id,
                      seperateQuantitiesList: separateOrderItemQuantities((snapshot.data!.docs[index].data()! as Map<String, dynamic>)["productsIDs"]),
                    )
                        : Center(child: circularProgress());

                  },
                );
              },
            )
                : Center(child: circularProgress(),);
          },
        ),
      ),
    );
  }
}
