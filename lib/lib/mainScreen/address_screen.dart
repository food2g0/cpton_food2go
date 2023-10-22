import 'package:cpton_foodtogo/lib/CustomersWidgets/dimensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../global/global.dart';
import '../models/menus.dart';

class AddressScreen extends StatefulWidget
{
  final double? totalAmount;
  final String? sellersUID;
  final Menus? model;

  AddressScreen({this.sellersUID, this.totalAmount, this.model});


  @override
  State<AddressScreen> createState() => _AddressScreenState();
}


class _AddressScreenState extends State<AddressScreen>
{


  @override
  Widget build(BuildContext context) {
    print(sharedPreferences!.getKeys());
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF890010),
        title: const Text(
          "Checkout",
          style: TextStyle(fontFamily: "Poppins"),
        ),
      ),
      body: Container(

        color: Colors.black12,
        child:  InkWell(
          onTap: (){},
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [

              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                    padding: EdgeInsets.all(8),
                child: Text("Select Address", style:
                  TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: "Poppins"
                  ),
                ),
                ),

              ),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    children: [
                      Text(
                        (sharedPreferences!.getString("name")!),
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          fontFamily: "Poppins",
                        ),
                      ),



                    ],
                  ),
                ),
              ),

              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Text((sharedPreferences!.getString("phone").toString()), style:
                  TextStyle(
                      color: Colors.black87,
                      fontSize: Dimensions.font14,
                      fontWeight: FontWeight.w500,
                      fontFamily: "Poppins"
                  ),
                  ),
                ),

              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Text((sharedPreferences!.getString("address").toString()), style:
                 TextStyle(
                      color: Colors.black87,
                      fontSize: Dimensions.font14,
                      fontWeight: FontWeight.w500,
                      fontFamily: "Poppins"
                  ),
                  ),
                ),

              ),
              SizedBox(height: 10,)
            ],

          ),
        ),
      ),
    );
  }
}
