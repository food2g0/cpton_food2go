import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../mainScreen/menu_screen.dart';
import '../models/menus.dart';
import '../theme/colors.dart';
import 'dimensions.dart';

class InfoDesignWidget extends StatefulWidget {
  final Menus? model;
  final BuildContext? context;

  const InfoDesignWidget({super.key, this.model, this.context});

  @override
  State<InfoDesignWidget> createState() => _InfoDesignWidgetState();
}

class _InfoDesignWidgetState extends State<InfoDesignWidget> {
  @override
  Widget build(BuildContext context) {
    double containerWidth = 200;
    double containerHeight = 200;
    double imageBorderRadius = 10.0; // Set the desired border radius

    return SizedBox(
      child: Container(
        color: Colors.white,
        child: InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (c) => MenuScreen(model: widget.model, sellersName: widget.model!.sellersName,)));
          },
          child: Padding(
            padding:  EdgeInsets.all(13.0.w),
            child: SizedBox(
              width: containerWidth,
              height: containerHeight,
              child: Container(
                color: AppColors().white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: ClipRRect( // Wrap the image with ClipRRect
                        borderRadius: BorderRadius.circular(imageBorderRadius),
                        child: Image.network(
                          widget.model!.sellersImageUrl!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Center(
                      child: Container(
                        padding:  EdgeInsets.all(8.0.w),
                        color: AppColors().white,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                          Icon(
                              Icons.fastfood, // Replace with your desired icon
                              color: AppColors().red,
                              size: 12.sp,
                            ),
                           SizedBox(width: 4.w), // Add spacing between the icon and text
                            Expanded(
                              child: Text(
                                widget.model!.sellersName!,
                                style: TextStyle(
                                  color: AppColors().black,
                                  fontFamily: "Poppins",
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.sp,
                                ),
                                overflow: TextOverflow.ellipsis, // Add ellipsis when text overflows
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
