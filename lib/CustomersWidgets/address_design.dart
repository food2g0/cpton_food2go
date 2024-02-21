import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../assistantMethods/address_changer.dart';
import '../mainScreen/check_out.dart';
import '../mainScreen/checkout_order_screen.dart';
import '../maps/maps.dart';
import '../models/address.dart';
import '../theme/colors.dart';
import 'package:provider/provider.dart';

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
                Expanded(
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(10),
                            width: MediaQuery.of(context).size.width * 0.7,
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
                      ),
                      Align(
                        alignment: Alignment.topRight, // Align the delete button to the top right
                        child: IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: AppColors().red,
                          ),
                          onPressed: () {
                            if (widget.addressId != null) {
                              // Call the deleteAddress method when the delete button is pressed
                              Provider.of<AddressChanger>(context, listen: false)
                                  .deleteAddress(widget.addressId!);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.map,
                    size: 26.sp,
                  ),
                  color: AppColors().black,
                  onPressed: () {
                    MapsUtils.openMapWithPosition(widget.model!.lat!, widget.model!.lng!);
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    // Handle Proceed button action for the selected address.
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (c) => CheckoutOrderScreen(
                              addressId: widget.addressId,
                              sellersUID: widget.sellersUID,
                              totalAmount: widget.totalAmount,
                            )));
                  },
                  child: Text("Choose", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.w))),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}


