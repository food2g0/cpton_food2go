import 'package:cloud_firestore/cloud_firestore.dart';

class Message{
  final String senderId;
  final String senderEmail;
  final String receiverId;
  final String message;
  final Timestamp timestamp;
  final String messageId;
  final String senderName;
  final String status;


  Message( {
    required this.status,
    required this.senderId,
    required this.senderName,
    required this.senderEmail,
    required this.receiverId,
    required this.message,
    required this.timestamp,
    required this.messageId, required
   ,

  });

  Map<String, dynamic> toMap(){
    return{
      'status': status,
      'senderName': senderName,
      'senderId': senderId,
      'senderEmail': senderEmail,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp,
      'messageId': messageId,
    };
  }
}