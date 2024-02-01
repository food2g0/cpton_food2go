import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_foodtogo/lib/CustomersWidgets/Category_design_widget.dart';
import 'package:cpton_foodtogo/lib/CustomersWidgets/card_design.dart';
import 'package:cpton_foodtogo/lib/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../CustomersWidgets/dimensions.dart';
import '../CustomersWidgets/progress_bar.dart';
import '../CustomersWidgets/sellers_design.dart';
import '../models/items.dart';
import '../models/menus.dart';

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
          Container(
            height: 200.h,
            child: Stack(
              children: [
                PageView.builder(
                  controller: pageController,
                  itemBuilder: (context, position) {
                    return _buildPageItem(position);
                  },
                ),

              ],
            ),
          ),
          SizedBox(height: 25.w),
          Container(
            margin: EdgeInsets.only(left: 25.w),
            child: Row(
              children: [
                Text(
                  "Restaurants near me",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12.sp,
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
                  height: 210.h, // Adjust the height as needed
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
                    color: Colors.black,
                    fontSize: 12.sp,
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
                    childAspectRatio: 0.8,
                    // Spacing between items vertically
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
          // Align(
          //   alignment: Alignment.bottomCenter,
          //   child: Container(
          //     height: 110.h,
          //     margin: EdgeInsets.only(left: 40.w, right: 40.w, bottom: 40.h,),
          //     decoration: BoxDecoration(
          //       borderRadius: BorderRadius.circular(30),
          //       color: Colors.white,
          //       boxShadow: const [
          //         BoxShadow(
          //           color: Colors.grey,
          //           blurRadius: 5.0,
          //           offset: Offset(0, 5),
          //         )
          //       ],
          //     ),
          //     child: Container(
          //       padding: EdgeInsets.only(top: 15, left: 15, right: 15),
          //       child: Column(
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         children: [
          //           Text(
          //             "Test12",
          //             style: TextStyle(
          //               color: Colors.cyan,
          //               fontSize: 14.sp,
          //             ),
          //           ),
          //           SizedBox(height: Dimensions.height10),
          //           Row(
          //             children: List.generate(5, (index) {
          //               return const Icon(
          //                 Icons.star,
          //                 color: Color(0xFFFBCD42),
          //                 size: 15,
          //               );
          //             }),
          //           ),
          //           SizedBox(height: 10.h),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );

  }
}
