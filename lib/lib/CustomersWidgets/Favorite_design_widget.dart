import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../assistantMethods/assistant_methods.dart';
import '../mainScreen/item_details_screen.dart';
import '../theme/colors.dart';

class FavoriteDesignWidget extends StatefulWidget {
  final dynamic model;
  final BuildContext? context;
  final VoidCallback? onRemove;

  const FavoriteDesignWidget({super.key, this.model, this.context, this.onRemove});

  @override
  State<FavoriteDesignWidget> createState() => _FavoriteDesignWidgetState();
}

class _FavoriteDesignWidgetState extends State<FavoriteDesignWidget> {






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
            color: AppColors().white,
            border: Border.all(color: AppColors().red, width: 1.0), // Add border styling
          ),
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              SizedBox(
                height: 125.h,
                width: MediaQuery.of(context).size.width,
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
                              color: AppColors().yellow,
                            ),
                          ),
                        ),
                        TextSpan(
                          text:  widget.model!.productTitle!.length <= 14
                              ? widget.model!.productTitle!
                              : widget.model!.productTitle!.substring(0, 14) + '...',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: AppColors().black,
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
                              color: AppColors().green,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.0.w),
                    child: Container(
                      height: 40.h,
                      width: 80.w,
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
                            color:AppColors().red,
                            borderRadius: BorderRadius.circular(8.0.w),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(8.0.w),
                            child: Icon(
                              Icons.shopping_cart,
                              size: 20.sp,
                              color: AppColors().white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0.w),
                    child: Container(
                      height: 40.h,
                      width: 60.w,
                      child: InkWell(
                        onTap: () {
                          // ... existing onTap code
                          if (widget.onRemove != null) {
                            widget.onRemove!();
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors().yellow,
                            borderRadius: BorderRadius.circular(8.0.w),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(8.0.w),
                            child: Icon(
                              Icons.favorite,
                              size: 28.sp,
                              color: AppColors().red,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
