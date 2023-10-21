import 'package:flutter/material.dart';


import '../mainScreen/item_details_screen.dart';
import 'dimensions.dart';


class CardDesignWidget extends StatefulWidget {
  final dynamic model;
  final BuildContext? context;

  const CardDesignWidget({super.key, this.model, this.context});

  @override
  State<CardDesignWidget> createState() => _CardDesignWidgetState();
}

class _CardDesignWidgetState extends State<CardDesignWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (c)=> ItemDetailsScreen(model: widget.model,)));
      },
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Card(
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0), // Set the border radius here
          ),
          child: Container(
          color: Colors.black,
            width: 300,
            child: Column( // Wrap the contents in a Column
              children: [
                SizedBox(
                  height: Dimensions.height150,
                  width: MediaQuery.of(context).size.width, // Set a fixed width for the image container
                  child: AspectRatio(
                    aspectRatio: 3 / 4, // Set the aspect ratio you desire
                    child: Image.network(
                      widget.model!.thumbnailUrl!,
                      fit: BoxFit.cover, // Preserve aspect ratio and cover the available space
                    ),
                  ),
                ),
                const SizedBox(height: 10), // Add some spacing between the image and text
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        const WidgetSpan(
                          child: Icon(
                            Icons.fastfood, // Replace with your desired icon
                            size: 16, // Adjust the icon size as needed
                            color: Colors.amber, // Adjust the icon color as needed
                          ),
                        ),
                        TextSpan(
                          text: ' ${widget.model!.productTitle}', // Display the sellersName with a space
                          style:  TextStyle(
                            fontSize: Dimensions.font16,
                            color: Colors.white,
                            overflow: TextOverflow.ellipsis,
                            fontFamily: "Poppins"
                          ), // Adjust the text style as needed
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: Dimensions.height10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.money_off,
                      size: Dimensions.font16,
                      color: Color(0xFF890010),
                    ),
                     SizedBox(width: Dimensions.width10),
                    Text(
                      "Php. " '${widget.model!.productPrice}',
                      style:  TextStyle(fontSize: Dimensions.font14, color: Colors.white, fontFamily: "Poppins"),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(width: Dimensions.width10), // Add spacing between price and button
                    ElevatedButton(
                      onPressed: () {
                        // Your onPressed logic here
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[900],
                      ),
                      child: Icon(
                        Icons.shopping_cart,
                        size: Dimensions.font20, // Set the icon size
                      ),
                    )


                  ],
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
