import 'package:cpton_foodtogo/lib/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../CustomersWidgets/Chat_page.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("chat_rooms").snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading....');
        }

        for (QueryDocumentSnapshot doc in snapshot.data!.docs) {
          final receiverId = doc['receiverId'];
          print('Sender Email from chat_rooms: $receiverId');
        }

        return Container(
          height: MediaQuery.of(context).size.height,
          child: CustomScrollView(
            slivers: [
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                    return FutureBuilder<Widget>(
                      future: _buildUserListItem(snapshot.data!.docs[index]),
                      builder: (context, userItemSnapshot) {
                        if (userItemSnapshot.connectionState == ConnectionState.done) {
                          return userItemSnapshot.data!;
                        } else {
                          return const Text('Loading user item...');
                        }
                      },
                    );
                  },
                  childCount: snapshot.data!.docs.length,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<Widget> _buildUserListItem(QueryDocumentSnapshot document) async {
    final sellersUID = document['receiverId'];

    final sellersSnapshot = await FirebaseFirestore.instance
        .collection('sellers')
        .where(sellersUID)
        .get();

    if (sellersSnapshot.docs.isNotEmpty) {
      final sellerData = sellersSnapshot.docs.first.data() as Map<String, dynamic>;

      if (_auth.currentUser!.email != sellerData['sellersEmail']) {
        final sellersUID = sellerData['sellersUID'];
        if (sellersUID is String) {
          return ListTile(
            title: Text(sellerData['sellersEmail']),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (c) => ChatPage(
                    receiverUserEmail: sellerData['sellersEmail'],
                    receiverUserID: sellersUID,
                  ),
                ),
              );
            },
          );
        } else {
          print('sellersUID is not a String: $sellersUID');
        }
      }
    }

    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return _buildUserList();
  }
}
