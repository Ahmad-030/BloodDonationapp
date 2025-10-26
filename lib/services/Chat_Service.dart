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
    try {
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
    } catch (e) {
      print('Error creating chat room: $e');
      rethrow;
    }
  }

  // Send message
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String message,
  }) async {
    try {
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
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
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
    try {
      final messages = await _firestore
          .collection(AppConstants.chatsCollection)
          .doc(chatId)
          .collection(AppConstants.messagesCollection)
          .where('senderId', isNotEqualTo: userId)
          .where('read', isEqualTo: false)
          .get();

      // Update all unread messages
      final batch = _firestore.batch();
      for (var doc in messages.docs) {
        batch.update(doc.reference, {'read': true});
      }
      await batch.commit();
    } catch (e) {
      print('Error marking messages as read: $e');
      // Don't rethrow - this is not critical
    }
  }

  // Delete a chat (optional - for future use)
  Future<void> deleteChat(String chatId) async {
    try {
      // Delete all messages first
      final messages = await _firestore
          .collection(AppConstants.chatsCollection)
          .doc(chatId)
          .collection(AppConstants.messagesCollection)
          .get();

      final batch = _firestore.batch();
      for (var doc in messages.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      // Delete chat document
      await _firestore
          .collection(AppConstants.chatsCollection)
          .doc(chatId)
          .delete();
    } catch (e) {
      print('Error deleting chat: $e');
      rethrow;
    }
  }

  // Get unread message count for a user in a specific chat
  Future<int> getUnreadMessageCount(String chatId, String userId) async {
    try {
      final unreadMessages = await _firestore
          .collection(AppConstants.chatsCollection)
          .doc(chatId)
          .collection(AppConstants.messagesCollection)
          .where('senderId', isNotEqualTo: userId)
          .where('read', isEqualTo: false)
          .get();

      return unreadMessages.docs.length;
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }
}