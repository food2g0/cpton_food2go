import 'package:cpton_foodtogo/lib/theme/colors.dart';
import 'package:flutter/material.dart';

class ErrorDialog extends StatelessWidget
{
  final String? message;
  const ErrorDialog({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      key: key,
      content: Text(message!),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          onPressed: ()
          {
            Navigator.pop(context);
          },
          child: Center(
            child: Text("Ok",
            style: TextStyle(
              color: AppColors().white,
              fontFamily: "Poppins"
            ),),
          ),
        )
      ],
    );
  }
}
