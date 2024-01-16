import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PlacedOrderScreen extends StatefulWidget
{
  String? addressID;
  double? totalAmount;
  String? sellerUID;
  String? paymentMode;

  PlacedOrderScreen({this.addressID,this.paymentMode,this.sellerUID,this.totalAmount});


  @override
  State<PlacedOrderScreen> createState() => _PlacedOrderScreenState();
}

class _PlacedOrderScreenState extends State<PlacedOrderScreen>
{

  @override
  Widget build(BuildContext context) {
    return Material();
  }
}
