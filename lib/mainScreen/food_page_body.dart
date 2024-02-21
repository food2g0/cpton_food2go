import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../CustomersWidgets/Category_design_widget.dart';
import '../CustomersWidgets/dimensions.dart';

import '../CustomersWidgets/progress_bar.dart';
import '../CustomersWidgets/sellers_design.dart';

import '../models/menus.dart';
import '../theme/colors.dart';
import 'fastfood_screen.dart';
import 'milktea_screen.dart';

class FoodPageBody extends StatefulWidget {
  final String? sellersUID;
  final dynamic model;
  const FoodPageBody({Key? key, this.sellersUID, this.model}) : super(key: key);

  @override
  State<FoodPageBody> createState() => _FoodPageBodyState();
}

class _FoodPageBodyState extends State<FoodPageBody> {
  PageController pageController = PageController(viewportFraction: 0.85);
  var _currPageValue = 0.0;
  final double _scaleFactor = 0.8;
  final double _height = Dimensions.pageViewContainer;

  List<String> categoryImages = [
    'images/fast-food.png', // Fast food image path
    'images/coffee.png', // Fast food image path
    'images/tea.png', // Fast food image path
    'images/tray.png', // Fast food image path
    'images/desserts.png', // Fast food image path

  ];

  List<String> categoryLabels = [
    'Fast Food',
    'Coffee',
    'Milk Tea',
    'Buffet',
    'Dessert',
  ];




  @override
  void initState() {
    super.initState();
    pageController.addListener(() {
      setState(() {
        _currPageValue = pageController.page!;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

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
                        // Navigate to CoffeeScreen
                        // Add code for navigation to CoffeeScreen here
                          break;
                        case 2:
                        // Navigate to MilkTeaScreen
                        // Add code for navigation to MilkTeaScreen here
                        // Navigate to FastFoodScreen
                          Navigator.push(
                            context,
                             MaterialPageRoute(builder: (context) => MilkTeaScreen()));
                          break;
                        case 3:
                        // Navigate to BuffetScreen
                        // Add code for navigation to BuffetScreen here

                          break;
                        case 4:
                        // Navigate to DessertScreen
                        // Add code for navigation to DessertScreen here
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
            stream: FirebaseFirestore.instance.collection("sellers").snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: circularProgress());
              } else {
                final data = snapshot.data!.docs;
                return SizedBox(
                  height: 220.h, // Adjust the height as needed
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: data.length, // Adjust the count as needed
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
SizedBox(height: 10.h,),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("items")
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: circularProgress());
              } else {
                final data = snapshot.data!.docs;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Number of items in each row
                    crossAxisSpacing: 8.0, // Spacing between items horizontally
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 0.8, // Spacing between items vertically
                  ),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    Menus model = Menus.fromJson(
                      data[index].data()! as Map<String, dynamic>,
                    );
                    return CategoryDesignWidget(
                      model: model,
                      context: context,
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


  Widget _buildPageItem(int index) {
    Matrix4 matrix = Matrix4.identity();
    // if (index == _currPageValue.floor()) {
    //   var currScale = 1 - (_currPageValue - index) * (1 - _scaleFactor);
    //   var currTrans = _height * (1 - currScale) / 2;
    //   matrix = Matrix4.diagonal3Values(1, currScale, 1)
    //     ..setTranslationRaw(0, currTrans, 0);
    // } else if (index == _currPageValue.floor() + 1) {
    //   var currScale =
    //       _scaleFactor + (_currPageValue - index + 1) * (1 - _scaleFactor);
    //   var currTrans = _height * (1 - currScale) / 2;
    //   matrix = Matrix4.diagonal3Values(1, currScale, 1);
    //   matrix = Matrix4.diagonal3Values(1, currScale, 1)
    //     ..setTranslationRaw(0, currTrans, 0);
    // } else if (index == _currPageValue.floor() - 1) {
    //   var currScale = 1 - (_currPageValue - index) * (1 - _scaleFactor);
    //   var currTrans = _height * (1 - currScale) / 2;
    //   matrix = Matrix4.diagonal3Values(1, currScale, 1);
    //   matrix = Matrix4.diagonal3Values(1, currScale, 1)
    //     ..setTranslationRaw(0, currTrans, 0);
    // } else {
    //   var currScale = 0.8;
    //   matrix = Matrix4.diagonal3Values(1, currScale, 1)
    //     ..setTranslationRaw(0, _height * (1 - _scaleFactor) / 2, 1);
    // }

    return Transform(
      transform: matrix,
      child: Stack(
        children: [
          Container(
            height: 170.h,
            margin: EdgeInsets.only(left: 5, right: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.w),
              color: AppColors().black,
              image: const DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage("images/foodbanner.jpg"),
              ),
            ),
          ),

        ],
      ),
    );

  }
}
