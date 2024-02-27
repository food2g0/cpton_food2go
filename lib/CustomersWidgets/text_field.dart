import 'package:cpton_foodtogo/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import this

class MyTextField extends StatefulWidget {
  final String? hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final FocusNode? focusNode;
  final FormFieldValidator<String>? validator;
  final int? maxLength; // Add maxLength property

  MyTextField({
    this.hint,
    this.controller,
 this.keyboardType,
    this.focusNode,
    this.validator,
    this.maxLength, // Initialize maxLength
  });

  @override
  _MyTextFieldState createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  String? _errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(8),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: TextFormField(
              controller: widget.controller,
              keyboardType: widget.keyboardType,
              focusNode: widget.focusNode,
              style: TextStyle(
                fontFamily: "Poppins",
                fontSize: 12,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
              validator: widget.validator,
              inputFormatters: widget.maxLength != null ? [LengthLimitingTextInputFormatter(widget.maxLength)] : null, // Set input formatters
              onChanged: (value) {
                setState(() {
                  _errorText = widget.validator!(value);
                });
              },
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: TextStyle(
                  fontFamily: "Poppins",
                  color: AppColors().black1,
                  fontSize: 12,
                ),
                contentPadding: EdgeInsets.all(10),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        if (_errorText != null)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              _errorText!,
              style: TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }
}
