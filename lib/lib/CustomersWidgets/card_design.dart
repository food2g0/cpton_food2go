import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';


import '../assistantMethods/assistant_methods.dart';
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
        padding: const EdgeInsets.all(4.0),
        child: Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0), // Set the border radius here
          ),
          child: Container(
          color: Colors.white,
            width: MediaQuery.of(context).size.width,
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
                  child: Container(
                    alignment: Alignment.centerLeft, // Adjust the alignment as needed
                    child: RichText(
                      text: TextSpan(
                        children: [
                          const WidgetSpan(
                            child: Icon(
                              Icons.fastfood,
                              size: 16,
                              color: Colors.amber,
                            ),
                          ),
                          TextSpan(
                            text: ' ${widget.model!.productTitle}',
                            style: TextStyle(
                              fontSize: Dimensions.font16,
                              color: Colors.black87,
                              fontWeight: FontWeight.w700,
                              overflow: TextOverflow.ellipsis,
                              fontFamily: "Poppins",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    Text(
                      "Php: "'${widget.model!.productPrice}',
                      style:  TextStyle(fontSize: Dimensions.font14, color: Colors.black87, fontFamily: "Poppins"),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(width: Dimensions.width10), // Add spacing between price and button
                    ElevatedButton(
                      onPressed: () {
                        int itemCounter = 1;

                        List<String> seperateItemIDsList = separateItemIDs();
                        seperateItemIDsList.contains(widget.model.productsID)
                            ? Fluttertoast.showToast(msg: "Item is already in a cart")
                            :

                        //2.add to cart
                        addItemToCart(
                            widget.model.productsID, context, itemCounter);
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
