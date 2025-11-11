import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String senderEmail;
  final String message;
  final DateTime timestamp;

  ChatMessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderEmail,
    required this.message,
    required this.timestamp,
  });

  factory ChatMessageModel.fromMap(Map<String, dynamic> map, String id) {
    return ChatMessageModel(
      id: id,
      chatId: map['chatId'] ?? '',
      senderId: map['senderId'] ?? '',
      senderEmail: map['senderEmail'] ?? '',
      message: map['message'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'senderId': senderId,
      'senderEmail': senderEmail,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}

