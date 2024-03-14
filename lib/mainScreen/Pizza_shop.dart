import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../CustomersWidgets/sellers_design.dart';
import '../models/menus.dart';
import '../theme/colors.dart'; // Import the Menus model

class PizaaShop extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors().red,
        title: Text('Pizza Shop',
          style: TextStyle(
              color: AppColors().white,
              fontFamily: "Poppins",
              fontSize: 12.sp
          ),),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('sellers')
            .where('sellersCategory', isEqualTo: 'Pizza')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No Pizza Shop found.'),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var sellerData = snapshot.data!.docs[index];
              // Create a Menus object from the sellerData
              Menus sellerMenus = Menus.fromJson(sellerData.data() as Map<String, dynamic>);
              return InfoDesignWidget(
                model: sellerMenus, // Pass the Menus object to the InfoDesignWidget
                context: context,
              );
            },
          );
        },
      ),
    );
  }
}
