import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_foodtogo/lib/mainScreen/order_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/items.dart';

class OrderCard extends StatelessWidget {
  final int? itemCount;
  final List<DocumentSnapshot>? data;
  final String? orderID;
  final List<String>? seperateQuantitiesList;

  OrderCard({
    this.itemCount,
    this.data,
    this.orderID,
    this.seperateQuantitiesList,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (c)=>OrderDetailsScreen(orderID: orderID)));
      },
      child: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Colors.black87,Colors.black])
        ),
        padding: const EdgeInsets.all(5),
        margin: const EdgeInsets.all(10),
        height: itemCount! * 170, // Adjusted height
        child: ListView.builder(
          itemCount: itemCount,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            Items model =
            Items.fromJson(data![index].data()! as Map<String, dynamic>);
            return placedOrderDesignWidget(
              model,
              context,
              seperateQuantitiesList![index],
              orderID,
            );
          },
        ),
      ),
    );
  }
}

Widget placedOrderDesignWidget(
    Items model,
    BuildContext context,
    String separateQuantities,
    String? orderID,
    ) {
  num productPrice = model.productPrice ?? 0.0;
  int quantity = int.tryParse(separateQuantities) ?? 0;

  num totalAmount = productPrice * quantity;

  return Container(
    margin: const EdgeInsets.symmetric(vertical: 10),
    padding: const EdgeInsets.all(10.0),
    decoration: BoxDecoration(
      color: Colors.grey[200],
      borderRadius: BorderRadius.circular(12.0),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                model.thumbnailUrl!,
                width: 120,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    model.productTitle,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      Text(
                        "Php ${model.productPrice.toString()}",
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        "x $separateQuantities",
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 16,
                          fontFamily: "Poppins",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      const Text(
                        "Total: ",
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "Php ${totalAmount.toStringAsFixed(2)}",
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 16.0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8.0),
        Text(
          'Order ID: $orderID',
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 16.0,
          ),
        ),
      ],
    ),
  );
}