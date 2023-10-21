import 'package:flutter/cupertino.dart';

import 'dimensions.dart';

@immutable
class BigText extends StatelessWidget {
  final Color? color;
  final String text;
  final double? size; // Change to double?
  final TextOverflow overFlow;

  const BigText({
    Key? key,
    this.color = const Color(0xFA271BFF),
    required this.text,
    this.size,
    this.overFlow = TextOverflow.ellipsis,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Set a default size if size is null
    final fontSize = size ?? Dimensions.font20;

    return Text(
      text,
      maxLines: 1,
      overflow: overFlow,
      style: TextStyle(
        fontFamily: 'Roboto',
        color: color,
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
