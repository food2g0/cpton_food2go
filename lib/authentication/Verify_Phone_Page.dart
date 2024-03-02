import 'package:cpton_foodtogo/authentication/Otp_Screen.dart';
import 'package:cpton_foodtogo/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VerifyPhonePage extends StatefulWidget {
  const VerifyPhonePage({super.key});

  @override
  State<VerifyPhonePage> createState() => _VerifyPhonePageState();
}

class _VerifyPhonePageState extends State<VerifyPhonePage> {
  TextEditingController phoneController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors().red,
        title: Text("Phone Authentication",
          style: TextStyle(
              color: AppColors().white,
              fontFamily: "Poppins",
              fontSize: 12.sp
          ),),
      ),
      body: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 60),

              child: Center(
                child: Text("Phone Authentication",
                  style: TextStyle(
                      color: AppColors().black,
                      fontFamily: "Poppins",
                      fontSize: 12.sp
                  ),),

              ),
            ),
            Container(
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: "Phone Number",
                  prefix: Padding(
                    padding: EdgeInsets.all(10),
                    child: Text("+63"),
                  ),
                ),
                maxLength: 10,
                keyboardType: TextInputType.number,
                controller: phoneController,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      minimumSize: Size.fromHeight(40),
                      shape: RoundedRectangleBorder(borderRadius:
                      BorderRadius.circular(10)),
                      backgroundColor: AppColors().red
                  ),
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (c)=> OtpScreen(phoneController.text)));
                  },


                  child: Text("Next",style:
                  TextStyle(color: AppColors().white),


                  )),
            )
          ]),

    );
  }
}