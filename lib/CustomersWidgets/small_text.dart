import 'package:flutter/cupertino.dart';

@immutable
class SmallText extends StatelessWidget {
  final Color? color;
  final String text;
  final double size;
  final double height;

  const SmallText({
    super.key,
    this.color = const Color(0xFA3A3434),
    required this.text,
    this.height = 1.2,
    this.size = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Roboto',
        color: color,
        fontSize: size,
        height: height,
      ),
    );
  }
}
