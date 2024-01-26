
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../CustomersWidgets/item_design.dart';

import '../CustomersWidgets/progress_bar.dart';
import '../models/items.dart';
import '../models/menus.dart';

class categoryScreen extends StatefulWidget {
  final Menus? model;

  const categoryScreen({super.key, this.model});

  @override
  State<categoryScreen> createState() => _categoryScreenState();
}

class _categoryScreenState extends State<categoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey, Colors.white],
          ),
        ),
        child: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              expandedHeight: 200.0,
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: false,
                background: Image.asset("images/food2.jpg"), // Fixed the Image widget
              ),
            ),
            const SliverToBoxAdapter(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 4.0, // Adjust the elevation as needed
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      '${widget.model!.menuTitle}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("sellers")
                  .doc(widget.model!.sellersUID)
                  .collection("menus")
                  .doc(widget.model!.menuID)
                  .collection("items")
                  .orderBy("publishedDate", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return SliverToBoxAdapter(
                    child: Center(child: circularProgress()),
                  );
                } else {
                  return SliverStaggeredGrid.countBuilder(
                    crossAxisCount: 2,
                    staggeredTileBuilder: (index) => const StaggeredTile.fit(1),
                    itemBuilder: (context, index) {
                      Items item = Items.fromJson( snapshot.data!.docs[index].data()! as Map<String, dynamic>,);
                      return ItemsDesignWidget(
                                  model: item,
                                  context: context,
                                );
                    },
                    itemCount: snapshot.data!.docs.length,
                  );
                  // return SliverList(
                  //   delegate: SliverChildBuilderDelegate(
                  //         (context, index) {
                  //       Items item = Items.fromJson(
                  //         snapshot.data!.docs[index].data()! as Map<String, dynamic>,
                  //       );
                  //       return ItemsDesignWidget(
                  //         model: item,
                  //         context: context,
                  //       );
                  //     },
                  //     childCount: snapshot.data!.docs.length,
                  //   ),
                  // );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
