import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_foodtogo/lib/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:cpton_foodtogo/lib/CustomersWidgets/sellers_design.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/menus.dart'; // Import the Menus model

class FastFoodScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors().red,
        title: Text('Fast Food Restaurant',
        style: TextStyle(
          color: AppColors().white,
          fontFamily: "Poppins",
          fontSize: 12.sp
        ),),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('sellers')
            .where('sellersCategory', isEqualTo: 'Fast Food')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No Milk Tea Sellers found.'),
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
