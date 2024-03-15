import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Components/chat_bubble.dart';
import '../services/chat_services.dart';
import '../theme/colors.dart';

class ChatPage extends StatefulWidget {
  final String receiverUserEmail;
  final String receiverUserID;

  const ChatPage({required this.receiverUserEmail, required this.receiverUserID});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final ImagePicker _imagePicker = ImagePicker();

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(widget.receiverUserID, _messageController.text);
      _messageController.clear();
    }
  }

  Future<void> sendImage() async {
    final XFile? imageFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (imageFile != null) {
      // Upload the image to Firebase Storage
      Reference ref = FirebaseStorage.instance.ref().child('chat_images').child(DateTime.now().toString());
      UploadTask uploadTask = ref.putFile(File(imageFile.path));

      // Get the download URL once the image is uploaded
      String imageUrl = await (await uploadTask).ref.getDownloadURL();

      // Send the image URL along with the message
      await _chatService.sendMessage(widget.receiverUserID, imageUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors().red,
        title: Text(widget.receiverUserEmail,
          style: TextStyle(color: AppColors().white,
              fontFamily: "Poppins",
              fontSize: 12.sp),),
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(),
          ),
          _buildMessageInput(),
          SizedBox(height: 20.sp,)
        ],
      ),
    );
  }

  Widget _buildMessageList(){
    return StreamBuilder(
        stream: _chatService.getMessages(widget.receiverUserID, _firebaseAuth.currentUser!.uid),
        builder: (context, snapshot){
          if (snapshot.hasError){
            return Text('Error${snapshot.error}');
          }
          if (snapshot.connectionState == ConnectionState.waiting){
            return const Text('Loading..');
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot document = snapshot.data!.docs[index];
              return _buildMessageItems(document);
            },
          );
        }
    );
  }

  Widget _buildMessageItems(DocumentSnapshot document){
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    var alignment = (data['senderId'] == _firebaseAuth.currentUser!.uid)
        ? Alignment.centerRight
        : Alignment.centerLeft;

    DateTime timeStamp = (data['timestamp'] as Timestamp).toDate();

    return Container(
      alignment: alignment,
      child: Padding(
        padding: EdgeInsets.all(8.0.w),
        child: Column(
          crossAxisAlignment: (data['senderId'] == _firebaseAuth.currentUser!.uid) ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisAlignment: (data['senderId'] == _firebaseAuth.currentUser!.uid) ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Text(  data['senderName'] ?? 'Unknown Sender', style: TextStyle(fontFamily: "Poppins",
                fontSize: 10.sp)),
            SizedBox(height: 5.sp),
            if (data['message'] != null && data['message'].toString().startsWith('http')) // Check if message is a URL (image)
              Image.network(data['message'], width: 150, height: 150),
            if (data['message'] != null && !data['message'].toString().startsWith('http')) // Display text message if not an image URL
              ChatBubble(message: data['message']),
            SizedBox(height: 2.sp),
            Text(
              '${timeStamp.hour}:${timeStamp.minute}',
              style: TextStyle(fontSize: 10.sp, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput(){
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 25.w),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Enter your Message',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          IconButton(
            onPressed: sendMessage,
            icon: Icon(Icons.send, size: 25.sp,),
          ),
          IconButton(
            onPressed: sendImage,
            icon: Icon(Icons.image, size: 25.sp,),
          ),
        ],
      ),
    );
  }
}
