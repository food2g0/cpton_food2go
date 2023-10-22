import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../CustomersWidgets/card_design.dart';
import '../CustomersWidgets/dimensions.dart';
import '../CustomersWidgets/menu_design.dart';
import '../CustomersWidgets/progress_bar.dart';
import '../assistantMethods/cart_item_counter.dart';
import '../models/items.dart';
import '../models/menus.dart';
import 'cart_screen.dart';

class MenuScreen extends StatefulWidget {
  final dynamic model;
  final String? sellersUID;

  const MenuScreen({super.key, this.model, this.sellersUID});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.model?.sellersImageUrl ?? 'default_image_url.jpg';

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
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.center,
                          colors: [
                            Colors.black, // Transparent at the top
                            Colors.black.withOpacity(0.5), // Dark gradient at the bottom
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                Stack(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (c)=> CartScreen(sellersUID: widget.model!.sellersUID)));
                      },
                      icon: const Icon(
                        Icons.shopping_cart_rounded,
                        color: Colors.white, // Set the icon color
                      ),
                    ),
                    Positioned(
                      top: 2,
                      right: 2,
                      child: Consumer<CartItemCounter>(
                        builder: (context, counter, c) {
                          return Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            padding: const EdgeInsets.all(4.0), // Adjust the padding as needed
                            child: Text(
                              counter.count.toString(),
                              style: const TextStyle(
                                color: Colors.red,
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
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Store Information',
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontSize: Dimensions.font20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10,),
                        Row(
                          children: [
                            Icon(
                              Icons.store,
                              size: Dimensions.font16,
                              color: Colors.amber,
                            ),
                            Text(
                              ' ${widget.model!.sellersName}',
                              style: TextStyle(
                                fontSize: Dimensions.font16,
                                color: Colors.black87,
                                fontWeight: FontWeight.w700,
                                overflow: TextOverflow.ellipsis,
                                fontFamily: "Poppins",
                              ), // Adjust the text style as needed
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.pin_drop,
                              size: Dimensions.font16,
                              color: Colors.red,
                            ),
                            Text(
                              '${widget.model!.sellersAddress}'.substring(0, 37) + '...', // Truncate text to 20 characters
                              style: TextStyle(
                                fontSize: Dimensions.font16,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                                overflow: TextOverflow.ellipsis,
                                fontFamily: "Poppins",
                              ),
                            )
                          ],
                        )

                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Category',
                  style: TextStyle(
                    fontFamily: "Poppins",
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("sellers")
                  .doc(widget.model?.sellersUID)
                  .collection("menus")
                  .orderBy("publishedDate", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return SliverToBoxAdapter(
                    child: Center(child: circularProgress()),
                  );
                } else {
                  return SliverToBoxAdapter(
                    child: SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal, // Set horizontal scroll direction
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          Menus menu = Menus.fromJson(
                            snapshot.data!.docs[index].data()
                            as Map<String, dynamic>,
                          );
                          return MenuDesignWidget(
                            model: menu,
                            context: context,
                          );
                        },
                      ),
                    ),
                  );
                }
              },
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Items',
                  style: TextStyle(
                    fontFamily: "Poppins",
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("items")
                  .where("sellersUID", isEqualTo: widget.model?.sellersUID)
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
                      return CardDesignWidget(
                        model: item,
                        context: context,
                      );
                    },
                    itemCount: itemsList.length,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
