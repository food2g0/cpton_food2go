import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../assistantMethods/address_changer.dart';
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
  final double? shippingFee;
  final String? sellersUID;

  AddressDesign({
    this.model,
    this.currentIndex,
    this.value,
    this.addressId,
    this.totalAmount,
    this.sellersUID,
    this.shippingFee,
  });

  @override
  State<AddressDesign> createState() => _AddressDesignState();
}

class _AddressDesignState extends State<AddressDesign> {
  @override
  Widget build(BuildContext context) {
    final isAddressSelected = widget.value == Provider.of<AddressChanger>(context).count;

    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
        ),
      ),
      onDismissed: (direction) {
        if (widget.addressId != null) {
          Provider.of<AddressChanger>(context, listen: false).deleteAddress(widget.addressId!);
        }
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(10),
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (c) => CheckoutOrderScreen(
                          addressId: widget.addressId,
                          sellersUID: widget.sellersUID,
                          totalAmount: widget.totalAmount,

                        ),
                      ),
                    );
                    print('Shipping fee Php${widget.shippingFee}');
                  },
                  child: Text("Choose", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.w)),
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
