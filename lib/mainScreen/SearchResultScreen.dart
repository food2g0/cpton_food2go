import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../CustomersWidgets/sellers_design.dart';
import '../models/menus.dart';
import '../theme/colors.dart';

class SearchResultScreen extends StatefulWidget {
  const SearchResultScreen({Key? key}) : super(key: key);

  @override
  _SearchResultScreenState createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  Future<QuerySnapshot>? restaurantsDocumentsList;
  String sellerNameText = "";

  initSearchingRestaurant(String textEntered) {
    restaurantsDocumentsList = FirebaseFirestore.instance
        .collection("sellers")
        .where("sellersName", isEqualTo: textEntered)
        .get();
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors().red,
        title: Text(
          'Search Restaurant',
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColors().white,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.w),
        child: Column(
          children: [
            TextField(
              onTap: () {},
              onChanged: (textEntered) {
                setState(() {
                  sellerNameText = textEntered;
                });
                //init search
                initSearchingRestaurant(textEntered);
              },
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide.none,
                ),
                hintText: 'Search...',
                suffixIcon: IconButton(
                  onPressed: () {
                    // Trigger search when the search icon is clicked
                    initSearchingRestaurant(sellerNameText);
                  },
                  icon: Icon(
                    Icons.search,
                    color: AppColors().red,
                  ),
                ),
                hintStyle: TextStyle(
                  fontFamily: 'Poppins',
                  color: AppColors().black1,
                ),
              ),
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12.sp,
                color: Colors.black,
              ),
              cursorColor: AppColors().red,
            ),
            Expanded(
              child: FutureBuilder<QuerySnapshot>(
                future: restaurantsDocumentsList,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No results found.'));
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        Menus model = Menus.fromJson(
                          snapshot.data!.docs[index].data() as Map<String, dynamic>,
                        );

                        return InfoDesignWidget(
                          model: model,
                          context: context,
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
