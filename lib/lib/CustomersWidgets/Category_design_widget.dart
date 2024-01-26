import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../assistantMethods/assistant_methods.dart';
import '../mainScreen/item_details_screen.dart';



class CategoryDesignWidget extends StatefulWidget {
  final dynamic model;
  final BuildContext? context;

  const CategoryDesignWidget({super.key, this.model, this.context});

  @override
  State<CategoryDesignWidget> createState() => _CategoryDesignWidgetState();
}

class _CategoryDesignWidgetState extends State<CategoryDesignWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (c) => ItemDetailsScreen(model: widget.model,)));
      },
      child: Padding(
        padding: EdgeInsets.all(4.0.w),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Color(0xFF890010), width: 1.0), // Add border styling
          ),
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              SizedBox(
                height: 100.h,
                width: 200.w,
                child: AspectRatio(
                  aspectRatio: 3 / 4,
                  child: Image.network(
                    widget.model!.thumbnailUrl!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: RichText(
                    text: TextSpan(
                      children: [
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Padding(
                            padding: EdgeInsets.only(right: 4.0),
                            child: Icon(
                              Icons.fastfood,
                              size: 16.sp,
                              color: Colors.amber,
                            ),
                          ),
                        ),
                        TextSpan(
                          text: ' ${widget.model!.productTitle}',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.black87,
                            fontWeight: FontWeight.w700,
                            overflow: TextOverflow.ellipsis,
                            fontFamily: "Poppins",
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 5),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: RichText(
                    text: TextSpan(
                      children: [
                        WidgetSpan(
                          child: Padding(
                            padding: EdgeInsets.only(right: 10.0),
                            child: Icon(
                              Icons.currency_ruble,
                              size: 16.sp,
                              color: Colors.green,
                            ),
                          ),
                        ),
                        TextSpan(
                          text: "Php: " + '${widget.model!.productPrice}',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.black45,
                            fontWeight: FontWeight.w700,
                            overflow: TextOverflow.ellipsis,
                            fontFamily: "Poppins",
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.h,),
              Padding(
                padding: EdgeInsets.all(8.0.w),
                child: Container(
                  height: 40.h,
                  width: 150.w,
                  child: InkWell(
                    onTap: () {
                      int itemCounter = 1;

                      List<String> separateItemIDsList = separateItemIDs();
                      if (separateItemIDsList.contains(widget.model.productsID)) {
                        Fluttertoast.showToast(msg: "Item is already in the cart");
                      } else {
                        // Add to cart
                        addItemToCart(widget.model.productsID, context, itemCounter);
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red[900],
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.shopping_cart,
                          size: 20.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
