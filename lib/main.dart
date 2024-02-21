import 'package:cpton_foodtogo/splashScreen/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'assistantMethods/address_changer.dart';
import 'assistantMethods/cart_item_counter.dart';
import 'assistantMethods/total_ammount.dart';
import 'global/global.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();


  sharedPreferences = await SharedPreferences.getInstance();


  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyCqwdH0M0TWiLwU6vFGj7StF3MHqjQr9nk",
      appId: "1:82585542874:android:ef64b5755dfecd372cc5e3",
      messagingSenderId: "82585542874",
      projectId: "foodtogo-b2974",
    ),
  );
  runApp(const MyApp());
}




class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      builder: (context, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (c) => CartItemCounter()),
            ChangeNotifierProvider(create: (c) => TotalAmount()),
            ChangeNotifierProvider(create: (c) => AddressChanger()),

          ],
          child: const GetMaterialApp(
            title: 'Food To Go',
            debugShowCheckedModeBanner: false,
            home: MySplashScreen(),
          ),
        );
      },
      designSize: Size(393, 873), // Adjust the design size according to your requirements
    );
  }
}
