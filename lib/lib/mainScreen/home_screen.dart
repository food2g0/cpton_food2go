import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../CustomersWidgets/customers_drawer.dart';
import '../CustomersWidgets/dimensions.dart';
import '../assistantMethods/cart_item_counter.dart';
import '../models/menus.dart';
import 'cart_screen.dart';
import 'food_page_body.dart';


class HomeScreen extends StatefulWidget {
  final dynamic model;
  final String? sellersUID;
  final BuildContext? context;
  const HomeScreen({super.key, this.model, this.sellersUID, this.context});

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
      CartScreen(sellersUID: widget.sellersUID),
      // Add more pages for other tabs as needed
      // AnotherPage(),
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
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF890010),
          ),
        ),
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "asd",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontFamily: "Roboto",
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
                  Navigator.push(context, MaterialPageRoute(builder: (c) => CartScreen(sellersUID: '',)));

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
                      padding: const EdgeInsets.all(4.0), // Adjust the padding as needed
                      child: Text(
                        counter.count.toString(),
                        style: const TextStyle(
                          color: Colors.red,
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
          preferredSize: const Size.fromHeight(80),
          child: Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(10),
            child: TextFormField(
              decoration: const InputDecoration(
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(vertical: 16),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                  borderSide: BorderSide(color: Colors.white),
                ),
                hintText: "Search...",
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
        ),
      ),
      drawer: const CustomersDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Popular Restaurant',
              style: TextStyle(
                fontSize: Dimensions.font14,
                fontWeight: FontWeight.bold,
                fontFamily: "Poppins",
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: _pages[_selectedIndex],
            ),
          ),
        ],
      ),
      bottomNavigationBar:  Theme(
        data: Theme.of(context).copyWith(
          canvasColor:
          Color(0xFF890010),
        ),// Set the background color here
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
              label: 'Cart',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              label: 'Messages',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Color(0xFFFBCD42),
          unselectedItemColor: Colors.white,
          selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: "Poppins",
          ),
          unselectedLabelStyle: TextStyle(
            fontWeight: FontWeight.normal,
            fontFamily: "Poppins",
          ),
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
