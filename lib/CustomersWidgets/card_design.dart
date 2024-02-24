import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../assistantMethods/assistant_methods.dart';
import '../mainScreen/item_details_screen.dart';
import '../models/items.dart';
import '../theme/colors.dart';


class CardDesignWidget extends StatefulWidget {
  final Items model;
  final BuildContext? context;
  final sellersUID;
  final double? distanceInKm;

  const CardDesignWidget({Key? key, required this.model, this.context, this.sellersUID, this.distanceInKm});

  @override
  State<CardDesignWidget> createState() => _CardDesignWidgetState();
}

class _CardDesignWidgetState extends State<CardDesignWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (c) => ItemDetailsScreen(
          distanceInKm: widget.distanceInKm ?? 0.0,

          model: widget.model,
          sellersUID: widget.sellersUID,
        )));
      },
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(4.0.w),
          child: Column(
            children: [
              Card(
                child: Container(
                  height: 150.h,
                  width: MediaQuery.of(context).size.width,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0), // Set the desired border radius
                    child: AspectRatio(
                      aspectRatio: 3 / 4,
                      child: Image.network(
                        widget.model.thumbnailUrl!,
                        fit: BoxFit.cover,
                      ),
                    ),
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
                          text: ' ${widget.model.productTitle}',
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
                          text: "Php: " + '${widget.model.productPrice}',
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
            ],
          ),
        ),
      ),
    );
  }
}
