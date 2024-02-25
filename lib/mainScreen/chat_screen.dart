import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../CustomersWidgets/Chat_page.dart';
import '../assistantMethods/message_counter.dart'; // Assuming this is where your ChatRoomProvider is imported from
import '../theme/colors.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors().red,
        title: Text('Messages',
        style: TextStyle(color: AppColors().white,
        fontSize: 12.sp,
        fontFamily: "Poppins"),),
      ),
      body: FutureBuilder(
        future: Provider.of<ChatRoomProvider>(context, listen: false)
            .fetchUnseenMessagesCount(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return _buildUserList();
          }
        },
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
    final sellersImageUrl = sellerData['sellersImageUrl'];
    final currentUserEmail = FirebaseAuth.instance.currentUser!.email;

    if (currentUserEmail != sellerData['sellersEmail']) {
      if (sellersUID is String) {
        final userId = FirebaseAuth.instance.currentUser!.uid;
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('chat_rooms')
              .where("receiverId", isEqualTo: userId)
              .where('status', isEqualTo: 'not seen')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
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
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 10),
                  if (hasNewMessage) Text('New Message'),
                ],
              ),
              onTap: () {
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

    return Container(); // Return an empty container by default
  }
}
