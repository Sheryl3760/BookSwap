import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bookswap/models/chat_message_model.dart';

class ChatProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String getChatId(String userId1, String userId2) {
    final sortedIds = [userId1, userId2]..sort();
    return '${sortedIds[0]}_${sortedIds[1]}';
  }

  Stream<List<ChatMessageModel>> getChatMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ChatMessageModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<bool> sendMessage({
    required String chatId,
    required String recipientId,
    required String message,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        _errorMessage = 'User not authenticated';
        notifyListeners();
        return false;
      }

      if (message.trim().isEmpty) {
        _errorMessage = 'Message cannot be empty';
        notifyListeners();
        return false;
      }

      _isLoading = true;
      notifyListeners();

      // Create chat document if it doesn't exist
      final chatRef = _firestore.collection('chats').doc(chatId);
      final chatDoc = await chatRef.get();

      if (!chatDoc.exists) {
        await chatRef.set({
          'participants': [user.uid, recipientId],
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        await chatRef.update({
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      // Add message
      await chatRef.collection('messages').add({
        'chatId': chatId,
        'senderId': user.uid,
        'senderEmail': user.email ?? '',
        'message': message.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error sending message: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> markMessagesAsRead(String chatId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final messagesSnapshot = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('senderId', isNotEqualTo: user.uid)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (var doc in messagesSnapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      // Silently fail for read updates
    }
  }
}

