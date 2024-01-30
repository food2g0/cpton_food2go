import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
import '../theme/colors.dart';
import 'cart_screen.dart';

class MenuScreen extends StatefulWidget {
  final dynamic model;
  final String? sellersUID;
  final String? sellersName;

  const MenuScreen({super.key, this.model, this.sellersUID, this.sellersName});

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
              expandedHeight: 200.0.h,
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
                        Navigator.push(context, MaterialPageRoute(builder: (c)=>
                            CartScreen(sellersUID: widget.model!.sellersUID,
                            )));
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
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors().white,
                            ),
                            padding:  EdgeInsets.all(4.0.w), // Adjust the padding as needed
                            child: Text(
                              counter.count.toString(),
                              style:  TextStyle(
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
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16.0.w),
                child: Container(

                  decoration: BoxDecoration(
                      color: AppColors().white,
                    borderRadius: BorderRadius.circular(10.w),
                    border: Border.all(color: AppColors().red, width: 1),

                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.0.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Store Information',
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      SizedBox(height: 10.h,),
                        Row(
                          children: [
                            Icon(
                              Icons.store,
                              size: 16.sp,
                              color: AppColors().yellow,
                            ),
                            Text(
                              ' ${widget.model!.sellersName}',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppColors().black,
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
                              size: 16.sp,
                              color: AppColors().red,
                            ),
                            Text(
                              '${widget.model!.sellersAddress}'.substring(0, 30) + '...', // Truncate text to 20 characters
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors().black,
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
      SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16.0.w),
                child: Text(
                  'Category',
                  style: TextStyle(
                    fontFamily: "Poppins",
                    color: AppColors().black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
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
                      height: 150.h,
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
         SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16.0.w),
                child: Text(
                  'Items',
                  style: TextStyle(
                    fontFamily: "Poppins",
                    color: AppColors().black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
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