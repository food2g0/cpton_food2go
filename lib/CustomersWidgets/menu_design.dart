
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


import '../mainScreen/category_screen.dart';
import '../models/menus.dart';
import 'dimensions.dart';

class MenuDesignWidget extends StatefulWidget {
  final Menus? model;
  final BuildContext? context;

  const MenuDesignWidget({super.key, this.model, this.context});

  @override
  State<MenuDesignWidget> createState() => _MenuDesignWidgetState();
}

class _MenuDesignWidgetState extends State<MenuDesignWidget> {
  @override
  Widget build(BuildContext context) {

    return InkWell(
      onTap: () {
       Navigator.push(context, MaterialPageRoute(builder: (c)=> categoryScreen(model: widget.model)));
      },
      child: Padding(
        padding:  EdgeInsets.all(8.0.w), // Reduce the padding to make it smaller
        child: SizedBox(
          width: 80.w, // Set a fixed width for the circular container
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                // Set the image height to make it circular
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent, // Set the background color for the circular container
                ),
                child: Center(
                  child: Image.network(
                    widget.model!.thumbnailUrl!,
                    width: 50.w,
                    height: 50.h,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 8.h), // Add some spacing between the image and text
              Text(
                widget.model!.menuTitle!,
                style:  TextStyle(
                  fontSize: Dimensions.font14,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
