import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../CustomersWidgets/Category_design_widget.dart';
import '../CustomersWidgets/dimensions.dart';
import '../CustomersWidgets/progress_bar.dart';
import '../CustomersWidgets/sellers_design.dart';
import '../models/menus.dart';
import '../theme/colors.dart';
import 'DessertScreen.dart';
import 'fastfood_screen.dart';
import 'milktea_screen.dart';
import 'buffet_screen.dart';
import 'japanese_restaurant.dart';
import 'pizza_shop.dart';
import 'burger_shop.dart';
import 'coffee_screen.dart';

class FoodPageBody extends StatefulWidget {
  final String? sellersUID;
  final dynamic model;
  const FoodPageBody({Key? key, this.sellersUID, this.model}) : super(key: key);

  @override
  State<FoodPageBody> createState() => _FoodPageBodyState();
}

class _FoodPageBodyState extends State<FoodPageBody> {
  PageController pageController = PageController(viewportFraction: 0.85);
  bool calculatingDistance = false;

  List<String> categoryImages = [
    'images/fast-food.png', // Fast food image path
    'images/coffee.png', // Coffee image path
    'images/tea.png', // Milk tea image path
    'images/tray.png', // Buffet image path
    'images/desserts.png', // Dessert image path
    'images/asian-restaurant.png', // Japanese Restaurant image path
    'images/pizza.png', // Pizza image path
    'images/burger1.png', // Pizza image path
  ];

  List<String> categoryLabels = [
    'Fast Food',
    'Coffee',
    'Milk Tea',
    'Buffet',
    'Dessert',
    'Japanese',
    'Pizza',
    'Burger'
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 25.h),
          Container(
            margin: EdgeInsets.only(left: 25.w),
            child: Row(
              children: [
                Text(
                  "Category",
                  style: TextStyle(
                    color: AppColors().black,
                    fontSize: 10.sp,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          Container(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categoryImages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      switch (index) {
                        case 0:
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => FastFoodScreen()));
                          break;
                        case 1:
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => CoffeeScreen()));
                          break;
                        case 2:
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => MilkTeaScreen()));
                          break;
                        case 3:
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => BuffetScreen()));
                          break;
                        case 4:
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => DessertScreen()));
                          break;
                        case 5:
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => JapaneseRestaurant()));
                          break;
                        case 6:
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => PizaaShop()));
                          break;
                        case 7:
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => BurgerShop()));
                          break;
                        default:
                          break;
                      }
                    },
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 35,
                          backgroundColor: AppColors().white,
                          child: Image.asset(
                            categoryImages[index],
                            height: 40,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          categoryLabels[index],
                          style: TextStyle(
                            fontSize: 8.sp,
                            fontFamily: "Poppins",
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 25.h),
          Container(
            margin: EdgeInsets.only(left: 25.w),
            child: Row(
              children: [
                Text(
                  "Restaurants near me",
                  style: TextStyle(
                    color: AppColors().black,
                    fontSize: 10.sp,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          // List of restaurants
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection("sellers").where("status", isEqualTo: "approved").where("open", isEqualTo: "open").snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || calculatingDistance) {
                return SizedBox(
                  height: 220.h,
                  child: Center(child: circularProgress()),
                );
              } else {
                final data = snapshot.data!.docs;
                return SizedBox(
                  height: 220.h,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      Menus model = Menus.fromJson(
                        data[index].data()! as Map<String, dynamic>,
                      );
                      return InfoDesignWidget(
                        model: model,
                        context: context,
                      );
                    },
                  ),
                );
              }
            },
          ),
          SizedBox(height: Dimensions.height10),
          Container(
            margin: EdgeInsets.only(left: 25.w),
            child: Row(
              children: [
                Text(
                  "All Products",
                  style: TextStyle(
                    color: AppColors().black,
                    fontSize: 10.sp,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection("items").where("status", isEqualTo: "available").snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: circularProgress());
              } else {
                final data = snapshot.data!.docs;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    Menus model = Menus.fromJson(
                      data[index].data()! as Map<String, dynamic>,
                    );
                    String? sellersUID = data[index].get('sellersUID');
                    return CategoryDesignWidget(
                      model: model,
                      context: context,
                      sellersUID: sellersUID,
                    );
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
