import 'package:cpton_foodtogo/lib/CustomersWidgets/dimensions.dart';
import 'package:cpton_foodtogo/lib/mainScreen/save_address_screen.dart';
import 'package:cpton_foodtogo/lib/theme/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../global/global.dart';
import '../models/menus.dart';

class addAddress extends StatefulWidget
{
  final double? totalAmount;
  final String? sellersUID;
  final Menus? model;

  addAddress({this.sellersUID, this.totalAmount, this.model});


  @override
  State<addAddress> createState() => _addAddressState();
}


class _addAddressState extends State<addAddress>
{


  @override
  Widget build(BuildContext context) {
    print(sharedPreferences!.getKeys());
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF890010),
        title: const Text(
          "Address Selection",
          style: TextStyle(fontFamily: "Poppins"),
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        label: Text("Add new address"),
        backgroundColor: AppColors().startColor,
        icon: Icon(Icons.add_location_alt_outlined),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (c)=> SaveAddressScreen()));
        },

      ),
    );
  }
}
