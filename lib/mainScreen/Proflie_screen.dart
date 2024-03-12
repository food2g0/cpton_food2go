import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/colors.dart';

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
              // Show modal bottom sheet for editing
              showModalBottomSheet(
                context: context,
                builder: (context) => EditProfileSheet(userData: _userData),
              );
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

class EditProfileSheet extends StatefulWidget {
  final Future<DocumentSnapshot<Map<String, dynamic>>> userData;

  const EditProfileSheet({Key? key, required this.userData}) : super(key: key);

  @override
  _EditProfileSheetState createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set initial values for controllers based on user data
    widget.userData.then((snapshot) {
      Map<String, dynamic> userData = snapshot.data()!;
      _nameController.text = userData['customersName'];
      _emailController.text = userData['customersEmail'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16.0,
          right: 16.0,
          top: 16.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Edit Profile',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () {
                // Implement update profile logic here
                // For simplicity, just print the new values
                print('Name: ${_nameController.text}');
                print('Email: ${_emailController.text}');

                // Save changes to the database
                FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).update({
                  'customersName': _nameController.text,
                  'customersEmail': _emailController.text,
                }).then((value) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Profile updated successfully!'),
                  ));
                  Navigator.pop(context); // Close the bottom sheet after saving changes
                }).catchError((error) {
                  print('Failed to update profile: $error');
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Failed to update profile. Please try again.'),
                  ));
                });
              },
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}

