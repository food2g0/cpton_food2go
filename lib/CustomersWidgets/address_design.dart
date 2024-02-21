
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../assistantMethods/address_changer.dart';
import '../mainScreen/check_out.dart';
import '../maps/maps.dart';
import '../models/address.dart';
import '../theme/colors.dart';

class AddressDesign extends StatefulWidget {
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
    final isAddressSelected = widget.value == Provider.of<AddressChanger>(context).count;

    return InkWell(
      onTap: () {
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
                  onChanged: (val) {
                    Provider.of<AddressChanger>(context, listen: false).displayResult(val);
                    print(val);
                  },
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: Table(
                        children: [
                          TableRow(
                            children: [
                              Text(widget.model!.name.toString()),
                            ],
                          ),
                          TableRow(
                            children: [
                              Text(widget.model!.phoneNumber.toString()),
                            ],
                          ),
                          TableRow(
                            children: [
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //button
                ElevatedButton(
                  child: const Text("Check on Maps"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black54,
                  ),
                  onPressed: ()
                  {
                    MapsUtils.openMapWithPosition(widget.model!.lat!, widget.model!.lng!);

                    //MapsUtils.openMapWithAddress(widget.model!.fullAddress!);
                  },
                ),


                ElevatedButton(
                  onPressed: () {
                    if (widget.addressId != null) {
                      // Call the deleteAddress method when the delete button is pressed
                      Provider.of<AddressChanger>(context, listen: false)
                          .deleteAddress(widget.addressId!);
                    }
                  },
                  child: Text("Delete", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors().red,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Handle Proceed button action for the selected address.
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (c) => CheckOut(
                              addressId: widget.addressId,
                              sellersUID: widget.sellersUID,
                              totalAmount: widget.totalAmount,
                            )));
                  },
                  child: Text("Choose", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),

              ],
            )
          ],
        ),
      ),
    );
  }
}
