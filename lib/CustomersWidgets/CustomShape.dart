import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomShape extends CustomClipper<Path>{
  @override
  Path getClip(Size size)
  {
    double height = size.height;
    double width = size.width;

    var path = Path();
    path.lineTo(0, height-50.h);

    path.quadraticBezierTo(width/2, height, width, height-50.h);

    path.lineTo(width, 0.w);
    path.close();
    return path;

  }
  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper){
    return true;

  }
}