import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../CustomersWidgets/Chat_page.dart';
import '../theme/colors.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Widget _buildUserList(QuerySnapshot snapshot) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        iconTheme: IconThemeData(color: AppColors().white),
        title: Text(
          'Messages',
          style: TextStyle(
            fontFamily: "Poppins",
            fontSize: 14.sp,
            color: AppColors().white,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: AppColors().red,
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: snapshot.docs.length,
        itemBuilder: (context, index) {
          return _buildUserListItem(snapshot.docs[index]);
        },
      ),
    );
  }

  Widget _buildUserListItem(QueryDocumentSnapshot document,) {
    final sellerData = document.data() as Map<String, dynamic>;
    final sellersUID = sellerData['sellersUID'];
    final sellersImageUrl = sellerData['sellersImageUrl'];

    if (_auth.currentUser!.email != sellerData['sellersEmail']) {
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
                // Update the status to 'seen' when the user clicks on the message
                // FirebaseFirestore.instance
                //     .collection('chat_rooms')
                //     .where('status', isEqualTo: 'not seen')
                //     .get()
                //     .then((querySnapshot) {
                //   querySnapshot.docs.forEach((doc) {
                //     doc.reference.update({'status': 'seen'});
                //   });
                // });

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
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Return false to disable the back button
        return false;
      },
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("sellers").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text('Loading....');
          }

          return _buildUserList(snapshot.data!);
        },
      ),
    );
  }
}
