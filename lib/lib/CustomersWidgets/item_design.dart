import 'package:flutter/material.dart';

import '../mainScreen/item_details_screen.dart';



class ItemsDesignWidget extends StatefulWidget {
  final dynamic model;
  final BuildContext? context;

  const ItemsDesignWidget({super.key, this.model, this.context});

  @override
  State<ItemsDesignWidget> createState() => _ItemsDesignWidgetState();
}

class _ItemsDesignWidgetState extends State<ItemsDesignWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (c) => ItemDetailsScreen(model:widget.model)));
      },
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Card(
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0), // Set the border radius here
          ),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal, // Allow horizontal scrolling
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 100, // Set a fixed width for the image container
                    child: AspectRatio(
                      aspectRatio: 5 / 4, // Set the aspect ratio you desire
                      child: Image.network(
                        widget.model!.thumbnailUrl!,
                        fit: BoxFit.contain, // Preserve aspect ratio and cover the available space
                      ),
                    ),
                  ),
                  const SizedBox(
                      width: 10), // Add some spacing between the image and text
                  Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start, // Align text to the start
                    children: [
                      const SizedBox(height: 10,),
                      RichText(
                        text: TextSpan(
                          children: [
                            const WidgetSpan(
                              child: Icon(
                                Icons.store, // Replace with your desired icon
                                size: 16, // Adjust the icon size as needed
                                color: Colors
                                    .black87, // Adjust the icon color as needed
                              ),
                            ),
                            TextSpan(
                              text:
                              ' ${widget.model!.productTitle}', // Display the sellersName with a space
                              style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors
                                      .black), // Adjust the text style as needed
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.price_check, // Replace with your desired icon
                            size: 16, // Adjust the icon size as needed
                            color: Colors.redAccent, // Adjust the icon color as needed
                          ),
                          const SizedBox(width: 6), // Add some spacing between the icon and text
                          Text(
                            "Php. " '${widget.model!.productPrice}', // Display the sellersAddress
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                            maxLines: 2, // Limit to 1 line
                            overflow: TextOverflow.ellipsis, // Add ellipsis (...) if text overflows
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
