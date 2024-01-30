import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_foodtogo/lib/CustomersWidgets/Favorite_design_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../CustomersWidgets/card_design.dart';
import '../CustomersWidgets/progress_bar.dart';
import '../models/items.dart';

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
          ..doc(productsID)
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
        title: Text('Favorites'),
      ),
      body: CustomScrollView(
        slivers: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('favorites')
                .doc(customersUID)
                .collection('items')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return SliverToBoxAdapter(
                  child: Center(child: circularProgress()),
                );
              } else {
                List<Items> itemsList = snapshot.data!.docs.map((doc) {
                  return Items.fromJson(doc.data() as Map<String, dynamic>);
                }).toList();

                return SliverStaggeredGrid.countBuilder(
                  crossAxisCount: 2,
                  staggeredTileBuilder: (index) => const StaggeredTile.fit(1),
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
                  itemCount: itemsList.length,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
