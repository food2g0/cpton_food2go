
import 'package:cpton_foodtogo/mainScreen/about_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../authentication/auth_screen.dart';
import '../global/global.dart';
import '../mainScreen/Proflie_screen.dart';
import '../mainScreen/home_screen.dart';
import '../mainScreen/my_order_screen.dart';
import '../theme/colors.dart';


class CustomersDrawer extends StatelessWidget {
 const CustomersDrawer({super.key });

  String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    String imageUrl = sharedPreferences!.getString("customerImageUrl") ?? '';
    return Drawer(
      backgroundColor: AppColors().white,
      child: ListView(
        children: [
          Container(
            color: Colors.black87,
            padding: EdgeInsets.only(top: 25, bottom: 10).r,
            child: Column(
              children: [
                Material(
                  borderRadius: BorderRadius.all(Radius.circular(80.w)),
                  elevation: 10,
                  child: Padding(
                    padding: EdgeInsets.all(1.0.w),
                    child: SizedBox(
                      height: 100.h,
                      width: 100.w,
                      child: SizedBox(
                        height: 100.h,
                        width: 100.w,
                        child: CircleAvatar(
                          backgroundImage: imageUrl.isNotEmpty
                              ? NetworkImage(imageUrl)
                              : AssetImage('images/boy.png') as ImageProvider<Object>, // Provide a placeholder image
                        ),
                      ),


                    ),
                  ),

                ),
                SizedBox(height: 30.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Text(
                      capitalize(sharedPreferences!.getString("name")!),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontFamily: "Poppins",
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          //body drawer
          ListTile(
            leading: Icon(
              Icons.account_circle,
              color: AppColors().red,
            ),
            title: Text("Profile",
            style: TextStyle(
              fontFamily: "Poppins",
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors().black
            ),),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (c)=> ProfileScreen()));
            },
          ),
          ListTile(
            leading: Icon(
              Icons.fastfood_rounded,
              color: AppColors().red,
            ),
            title: Text("Orders",
              style: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors().black
              ),),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (c)=> MyOrderScreen()));
            },
          ),
          ListTile(
            leading: Icon(
              Icons.info_rounded,
              color: AppColors().red,
            ),
            title: Text("About",
              style: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors().black
              ),),
            onTap: () {
              // Handle the About item tap
              Navigator.push(context, MaterialPageRoute(builder: (c)=>AboutScreen()));
            },
          ),
          ListTile(
            leading: Icon(
              Icons.favorite,
              color: AppColors().red,
            ),
            title: Text("Favorites",
              style: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors().black
              ),),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (c)=> FavoritesScreen()));
            },
          ),
          ListTile(
            leading: Icon(
              Icons.logout_rounded,
              color: AppColors().red,
            ),
            title: Text("Logout",
              style: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors().black
              ),),
            onTap: () {
              firebaseAuth.signOut().then((value){
                Navigator.push(context, MaterialPageRoute(builder: (c)=> const AuthScreen()));
              });
            },
          ),
        ],
      ),
    );
  }
}
