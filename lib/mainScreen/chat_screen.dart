import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../CustomersWidgets/Chat_page.dart';
import '../assistantMethods/message_counter.dart'; // Assuming this is where your ChatRoomProvider is imported from
import '../theme/colors.dart';
import 'food_page_body.dart';
import 'home_screen.dart';

class ChatScreen extends StatefulWidget {


  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  int _selectedIndex = 0;
  List<Widget> _pages = [];
  @override
  void initState() {
    super.initState();

    // Initialize the _pages list here
    _pages = [
      const FoodPageBody(),
      FavoritesScreen(),
      NotificationScreen(),
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
   


    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (c)=>HomeScreen()));
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: AppColors().red,
          title: Text(
            'Messages',
            style: TextStyle(
                color: AppColors().white,
                fontSize: 12.sp,
                fontFamily: "Poppins"
            ),
          ),
        ),

        body: FutureBuilder(
          future: Provider.of<ChatRoomProvider>(context, listen: false)
              .fetchUnseenMessagesCount(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: SizedBox(
                    height: 24.h,
                    width: 24.w,
                    child: CircularProgressIndicator()),
              );;
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              return _buildUserList();
            }
          },
        ),

      ),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("sellers").snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text('Loading....');
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            return _buildUserListItem(snapshot.data!.docs[index]);
          },
        );
      },
    );
  }

  Widget _buildUserListItem(QueryDocumentSnapshot document) {
    final sellerData = document.data() as Map<String, dynamic>;
    final sellersUID = sellerData['sellersUID'];
    final sellersEmail = sellerData['sellersEmail'];
    final sellersImageUrl = sellerData['sellersImageUrl'];
    final currentUserEmail = FirebaseAuth.instance.currentUser!.email;

    print(sellersEmail);

    if (currentUserEmail != sellerData['sellersEmail']) {
      if (sellersUID is String) {
        final userId = FirebaseAuth.instance.currentUser!.uid;
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('chat_rooms')
              .where("receiverId", isEqualTo: userId)
              .where("senderEmail", isEqualTo: sellersEmail)
              .where('status', isEqualTo: 'not seen')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: SizedBox(
                    height: 24.h,
                    width: 24.w,
                    child: CircularProgressIndicator()),
              );;
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            final hasNewMessage = snapshot.data!.docs.isNotEmpty;

            return ListTile(
              title: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: sellersImageUrl != null
                        ? NetworkImage(sellersImageUrl)
                        : null,
                  ),
                  SizedBox(width: 10),
                  Text(
                    sellerData['sellersName'],
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 12.sp,
                      color: AppColors().black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 10),
                  if (hasNewMessage) Icon(Icons.circle, color: Colors.red, size: 12.sp,),

                ],
              ),
              onTap: () async {
                // Update the status of the message to "seen"
                final userId = FirebaseAuth.instance.currentUser!.uid;
                final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
                    .collection('chat_rooms')
                    .where("receiverId", isEqualTo: userId)
                    .where('senderId', isEqualTo: sellersUID)
                    .where('status', isEqualTo: 'not seen')
                    .get();
                querySnapshot.docs.forEach((doc) {
                  doc.reference.update({'status': 'seen'});
                });

                // Navigate to the ChatPage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (c) => ChatPage(
                      receiverUserEmail: sellerData['sellersName'],
                      receiverUserID: sellersUID,
                    ),
                  ),
                );
              },



            );
          },
        );
      } else {
        print('sellersUID is not a String: $sellersUID');
      }
    }

    return Container();
    // Return an empty container by default
  }
}
