// ============================================================================
// FILE: lib/services/chat_service.dart (FIXED)
// ============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/constants.dart';
import 'notification_service.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();

  // Generate unique chat ID
  String generateChatId(String userId1, String userId2) {
    List<String> ids = [userId1, userId2];
    ids.sort();
    return "${ids[0]}_${ids[1]}";
  }

  // Create chat room
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

  // Send message with notification
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

      // Update last message
      await _firestore
          .collection(AppConstants.chatsCollection)
          .doc(chatId)
          .update({
        'lastMessage': message,
        'lastMessageTime': FieldValue.serverTimestamp(),
      });

      // Send push notification to recipient
      await _sendNotificationToRecipient(
        chatId: chatId,
        senderId: senderId,
        senderName: senderName,
        message: message,
      );
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }

  // Send notification to recipient (FIXED FOR VERCEL BACKEND)
  Future<void> _sendNotificationToRecipient({
    required String chatId,
    required String senderId,
    required String senderName,
    required String message,
  }) async {
    try {
      print('📤 Preparing to send notification...');

      // Get chat document
      final chatDoc = await _firestore
          .collection(AppConstants.chatsCollection)
          .doc(chatId)
          .get();

      if (!chatDoc.exists) {
        print('❌ Chat document not found');
        return;
      }

      final chatData = chatDoc.data() as Map<String, dynamic>;
      final participants = chatData['participants'] as List<dynamic>;

      // Find recipient ID
      final recipientId = participants.firstWhere(
            (id) => id != senderId,
        orElse: () => null,
      );

      if (recipientId == null) {
        print('❌ Recipient not found');
        return;
      }

      print('✅ Recipient ID: $recipientId');

      // Send notification using Vercel backend
      // Backend expects: receiverId, title, body
      await _notificationService.sendNotification(
        receiverId: recipientId,  // Changed from recipientToken to receiverId
        title: senderName,         // Sender's name as title
        body: message,             // Message as body
      );

      print('✅ Notification request sent to backend');
    } catch (e) {
      print('❌ Error sending notification: $e');
    }
  }

  // Get messages stream
  Stream<QuerySnapshot> getMessages(String chatId) {
    return _firestore
        .collection(AppConstants.chatsCollection)
        .doc(chatId)
        .collection(AppConstants.messagesCollection)
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // Get user chats
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

      final batch = _firestore.batch();
      for (var doc in messages.docs) {
        batch.update(doc.reference, {'read': true});
      }
      await batch.commit();
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  // Delete chat
  Future<void> deleteChat(String chatId) async {
    try {
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

      await _firestore
          .collection(AppConstants.chatsCollection)
          .doc(chatId)
          .delete();
    } catch (e) {
      print('Error deleting chat: $e');
      rethrow;
    }
  }

  // Get unread message count
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

  // Save FCM token to user document
  Future<void> saveFCMToken(String userId, String token) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update({'fcmToken': token});
      print('✅ FCM Token saved to Firestore');
    } catch (e) {
      print('❌ Error saving FCM token: $e');
    }
  }
}