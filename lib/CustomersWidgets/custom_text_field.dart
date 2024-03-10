import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/colors.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final IconData? data;
  final String? hintText;
  final TextStyle? hintStyle;
  final bool isObscure; // Mark as final
  final Widget? suffixIcon;
  final bool enabled;
  final TextStyle? inputTextStyle; // Mark as final
  final TextInputType? keyboardType; // Add keyboardType parameter

  const CustomTextField({
    Key? key,
    this.controller,
    this.data,
    this.hintText,
    this.isObscure = true,
    this.enabled = true,
    this.inputTextStyle,
    this.hintStyle,
    this.keyboardType,
    this.suffixIcon, // Initialize keyboardType parameter as required
  }) : super(key: key);

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Email is required";
    } else if (!RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$')
        .hasMatch(value)) {
      return "Please enter a valid Email";
    }
    return null; // Input is valid
  }

  @override
  Widget build(BuildContext context) {
    // Conditionally apply inputFormatters based on keyboardType
    List<TextInputFormatter>? inputFormatters;
    if (keyboardType == TextInputType.text) {
      inputFormatters = [
        FilteringTextInputFormatter.allow(RegExp(r'^[a-z A-Z]+$')),
        // Only allow alphabetic characters
      ];
    } else if (keyboardType == TextInputType.number) {
      inputFormatters = [
        LengthLimitingTextInputFormatter(11),
        // Limit to 11 characters
        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
        // Only allow digits
      ];
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: Colors.black),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.all(7),
      child: TextFormField(
        enabled: enabled,
        controller: controller,
        obscureText: isObscure,
        inputFormatters: inputFormatters,
        validator: _validateEmail,
        cursorColor: AppColors().red,
        style: inputTextStyle,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          prefixIcon: Icon(
            data,
            color: AppColors().red,
          ),
          hintText: hintText,
          hintStyle: hintStyle,
        ),
      ),
    );
  }
}
