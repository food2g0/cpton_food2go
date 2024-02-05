import 'package:cpton_foodtogo/lib/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late User? _user;
  late Future<DocumentSnapshot<Map<String, dynamic>>> _userData;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _userData = FirebaseFirestore.instance.collection('users').doc(_user!.uid).get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors().red,
        title: Text(
          'Profile',
          style: TextStyle(
            fontFamily: "Poppins",
            color: AppColors().white,
            fontSize: 12.sp,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Handle edit profile action
              // You can navigate to an edit profile screen or show a modal bottom sheet for editing
            },
            icon: Icon(
              Icons.edit,
              color: AppColors().white,
            ),
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _userData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('User data not found.'));
          } else {
            Map<String, dynamic> userData = snapshot.data!.data()!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.person, color: AppColors().red, size: 20.sp),
                      SizedBox(width: 8.w),
                      Text(
                        ' ${userData['customersName']}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontFamily: "Poppins",
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.email, color: AppColors().red, size: 20.sp),
                      SizedBox(width: 8.w),
                      Text(
                        ' ${userData['customersEmail']}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontFamily: "Poppins",
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  // Add more profile information here based on your database structure
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
