import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/menus.dart';
import 'dimensions.dart';

class CartItemDesign extends StatelessWidget {
  final Menus? model;
  final int? quanNumber;
  final BuildContext? context;

  const CartItemDesign({super.key,
    this.model,
    this.quanNumber,
    this.context, required ,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
        child: SizedBox(
          height: 120,
          width: double.infinity,
          child: Card(
            elevation: 1,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                Container(
                  width: 140,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
                    image: DecorationImage(
                      image: NetworkImage(model!.thumbnailUrl!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Title, Quantity, Price
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        model!.productTitle!,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontFamily: "Poppins",
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Quantity
                      Row(
                        children: [
                          Text(
                            "Quantity: ",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: Dimensions.font14,
                              fontFamily: "Poppins",
                            ),
                          ),
                          Text(
                            quanNumber.toString(),
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: Dimensions.font14,
                              fontFamily: "Poppins",
                            ),
                          ),
                        ],
                      ),

                      // Price
                      Text(
                        "Php ${model!.productPrice}",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
