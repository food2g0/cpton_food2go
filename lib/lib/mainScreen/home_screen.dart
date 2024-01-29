import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../CustomersWidgets/customers_drawer.dart';
import '../CustomersWidgets/dimensions.dart';
import '../assistantMethods/cart_item_counter.dart';
import '../global/global.dart';
import '../models/menus.dart';
import 'cart_screen.dart';
import 'food_page_body.dart';
import 'chat_screen.dart'; // Import the ChatScreen

class HomeScreen extends StatefulWidget {
  final dynamic model;
  final String? sellersUID;
  final BuildContext? context;
  const HomeScreen({Key? key, this.model, this.sellersUID, this.context})
      : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();

    // Initialize the _pages list here
    _pages = [
      const FoodPageBody(),
      PlaceholderWidget(label: 'Favorites'),
      PlaceholderWidget(label: 'Notifications'),
      ChatScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      if (index >= 0 && index < _pages.length) {
        _selectedIndex = index;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: // Check if it's not the ChatScreen
           AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF890010),
          ),
        ),
        title: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              sharedPreferences!.getString("name")!,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontFamily: "Poppins",
              ),
            ),
          ),
        ),
        centerTitle: false,
        automaticallyImplyLeading: true,
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (c) => CartScreen(sellersUID: '',)));
                },
                icon: const Icon(
                  Icons.shopping_cart_rounded,
                  color: Colors.white,
                ),
              ),
              Positioned(
                top: 2,
                right: 2,
                child: Consumer<CartItemCounter>(
                  builder: (context, counter, c) {
                    return Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      padding: EdgeInsets.all(4.0.w), // Adjust the padding as needed
                      child: Text(
                        counter.count.toString(),
                        style: const TextStyle(
                          color: Color(0xFF890010),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(80.h),
          child: Container(
            margin: EdgeInsets.all(7.w),
            padding: EdgeInsets.all(7.w),
            child: TextFormField(
              decoration: InputDecoration(
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(vertical: 16.h),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30.w)),
                  borderSide: BorderSide(color: Colors.white),
                ),
                hintText: "Search...",
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
        ),
      ) ,// If it's ChatScreen, set AppBar to null
      drawer: const CustomersDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20.h,),
          Expanded(
            child: SafeArea(
              child: SingleChildScrollView(
                child: _pages[_selectedIndex],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: const Color(0xFF890010),
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              label: 'Favorites',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_on_rounded),
              label: 'Notification',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              label: 'Messages',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xFFFBCD42),
          unselectedItemColor: Colors.white,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: "Poppins",
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontFamily: "Poppins",
          ),
          onTap: _onItemTapped,
        ),
      ),
    );

  }
}
class PlaceholderWidget extends StatelessWidget {
  final String label;

  const PlaceholderWidget({Key? key, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Placeholder for $label Page',
        style: TextStyle(fontSize: 20),
      ),
    );
  }
}