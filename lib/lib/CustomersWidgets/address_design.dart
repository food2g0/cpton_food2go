import 'package:cpton_foodtogo/lib/CustomersWidgets/dimensions.dart';
import 'package:cpton_foodtogo/lib/assistantMethods/address_changer.dart';
import 'package:cpton_foodtogo/lib/models/address.dart';
import 'package:cpton_foodtogo/lib/theme/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class AddressDesign extends StatefulWidget
{
  final Address? model;
  final int? currentIndex;
  final int? value;
  final String? addressId;
  final double? totalAmount;
  final String? sellersUID;

  AddressDesign({
    this.model,
    this.currentIndex,
    this.value,
    this.addressId,
    this.totalAmount,
    this.sellersUID,
});


  @override
  State<AddressDesign> createState() => _AddressDesignState();
}

class _AddressDesignState extends State<AddressDesign> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: ()
      {
        Provider.of<AddressChanger>(context, listen: false).displayResult(widget.value);
      },
      child: Card(
        color: Colors.white,
        child: Column(
          children: [
            Row(
              children: [
                Radio(
                  groupValue: widget.currentIndex,
                  value: widget.value,
                  activeColor: AppColors().startColor,
                  onChanged: (val)
                  {
                    //provider
                    Provider.of<AddressChanger>(context, listen: false).displayResult(val);
                    print(val);
                  },
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      width: MediaQuery.of(context).size.width* 0.8,
                      child: Table(
                        children: [
                          TableRow(
                            children: [
                              Text("Name:",
                                  style: TextStyle(color: Colors.black87,fontFamily: "Poppins", fontSize: Dimensions.font16),),
                              Text(widget.model!.name.toString()),
                            ],
                          ),
                          TableRow(
                            children: [
                              Text("Phone Number:",
                                style: TextStyle(color: Colors.black87,fontFamily: "Poppins", fontSize: Dimensions.font16),),
                              Text(widget.model!.phoneNumber.toString()),
                            ],
                          ),
                          TableRow(
                            children: [
                              Text("Address:",
                                style: TextStyle(color: Colors.black87,fontFamily: "Poppins", fontSize: Dimensions.font16),),
                              Text(widget.model!.fullAddress.toString()),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                )
              ],
            ),

            widget.value == Provider.of<AddressChanger>(context).count
            ? ElevatedButton(onPressed: (){},
                child: Text("Proceed"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors().startColor,
            ),
            )
                : Container(),

          ],
        ),
      ),

    );
  }
}
