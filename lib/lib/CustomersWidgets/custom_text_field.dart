import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final IconData? data;
  final String? hintText;
  final bool isObscure; // Mark as final
  final bool enabled;    // Mark as final

  const CustomTextField({
    Key? key,
    this.controller,
    this.data,
    this.hintText,
    this.isObscure = true,
    this.enabled = true,
  }) : super(key: key);

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Full Name is required";
    } else if (!RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$')
        .hasMatch(value)) {
      return "Please enter a valid Full Name";
    }
    return null; // Input is valid
  }

  @override
  Widget build(BuildContext context) {
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
        validator: _validateEmail,
        cursorColor: Theme.of(context).primaryColor,
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(
            data,
            color: Colors.black,
          ),
          hintText: hintText,
        ),
      ),
    );
  }
}
