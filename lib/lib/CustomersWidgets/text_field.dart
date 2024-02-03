// text_field.dart
import 'package:cpton_foodtogo/lib/theme/colors.dart';
import 'package:flutter/material.dart';

class MyTextField extends StatefulWidget {
  final String? hint;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final FocusNode? focusNode;

  MyTextField({
    this.hint,
    this.controller,
    required this.keyboardType,
    this.focusNode,
  });

  @override
  _MyTextFieldState createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors().black,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          focusNode: widget.focusNode,
          decoration: InputDecoration(
            hintText: widget.hint,
            contentPadding: EdgeInsets.all(10),
            border: InputBorder.none,
          ),
          validator: (value) => value!.isEmpty ? "Field cannot be empty" : null,
        ),
      ),
    );
  }
}
