import 'package:flutter/material.dart';

import '../mainScreen/menu_screen.dart';
import '../models/menus.dart';
import 'dimensions.dart';

class InfoDesignWidget extends StatefulWidget {
  final Menus? model;
  final BuildContext? context;

  const InfoDesignWidget({super.key, this.model, this.context});

  @override
  State<InfoDesignWidget> createState() => _InfoDesignWidgetState();
}

class _InfoDesignWidgetState extends State<InfoDesignWidget> {
  @override
  Widget build(BuildContext context) {
    double containerWidth = 200;
    double containerHeight = 200;
    double imageBorderRadius = 10.0; // Set the desired border radius

    return SizedBox(
      child: Container(
        color: Colors.white,
        child: InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (c) => MenuScreen(model: widget.model,)));
          },
          child: Padding(
            padding: const EdgeInsets.all(13.0),
            child: SizedBox(
              width: containerWidth,
              height: containerHeight,
              child: Container(
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: ClipRRect( // Wrap the image with ClipRRect
                        borderRadius: BorderRadius.circular(imageBorderRadius),
                        child: Image.network(
                          widget.model!.sellersImageUrl!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        color: Colors.white,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.fastfood, // Replace with your desired icon
                              color: Color(0xFF890010),
                              size: 12,
                            ),
                            const SizedBox(width: 4), // Add spacing between the icon and text
                            Expanded(
                              child: Text(
                                widget.model!.sellersName!,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: "Poppins",
                                  fontWeight: FontWeight.bold,
                                  fontSize: Dimensions.font12,
                                ),
                                overflow: TextOverflow.ellipsis, // Add ellipsis when text overflows
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
