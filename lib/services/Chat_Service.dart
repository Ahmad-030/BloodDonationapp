// ============================================================================
// FILE: lib/services/chat_service.dart
// Firebase Chat Service - Handles unique 1-on-1 messaging
// ============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/constants.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Generate unique chat ID by sorting user IDs
  // This ensures same chat room for both users
  String generateChatId(String userId1, String userId2) {
    List<String> ids = [userId1, userId2];
    ids.sort(); // Always same order
    return "${ids[0]}_${ids[1]}";
  }

  // Create chat room if it doesn't exist
  Future<void> createChatRoom({
    required String chatId,
    required String userId1,
    required String userId2,
    required Map<String, dynamic> user1Details,
    required Map<String, dynamic> user2Details,
  }) async {
    final chatDoc = await _firestore
        .collection(AppConstants.chatsCollection)
        .doc(chatId)
        .get();

    if (!chatDoc.exists) {
      await _firestore
          .collection(AppConstants.chatsCollection)
          .doc(chatId)
          .set({
        'chatId': chatId,
        'participants': [userId1, userId2],
        'participantDetails': {
          userId1: user1Details,
          userId2: user2Details,
        },
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // Send message
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String message,
  }) async {
    // Add message to subcollection
    await _firestore
        .collection(AppConstants.chatsCollection)
        .doc(chatId)
        .collection(AppConstants.messagesCollection)
        .add({
      'senderId': senderId,
      'senderName': senderName,
      'text': message,
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
    });

    // Update last message in chat document
    await _firestore
        .collection(AppConstants.chatsCollection)
        .doc(chatId)
        .update({
      'lastMessage': message,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });
  }

  // Get messages stream for a chat
  Stream<QuerySnapshot> getMessages(String chatId) {
    return _firestore
        .collection(AppConstants.chatsCollection)
        .doc(chatId)
        .collection(AppConstants.messagesCollection)
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // Get all chats for a user
  Stream<QuerySnapshot> getUserChats(String userId) {
    return _firestore
        .collection(AppConstants.chatsCollection)
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots();
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String chatId, String userId) async {
    final messages = await _firestore
        .collection(AppConstants.chatsCollection)
        .doc(chatId)
        .collection(AppConstants.messagesCollection)
        .where('senderId', isNotEqualTo: userId)
        .where('read', isEqualTo: false)
        .get();

    for (var doc in messages.docs) {
      await doc.reference.update({'read': true});
    }
  }
}