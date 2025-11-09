// ============================================================================
// FILE: lib/services/notification_service.dart
// Works with your Vercel backend API
// ============================================================================

import 'dart:ui';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  String? fcmToken;

  // Your Vercel backend URL
  static const String backendUrl = 'https://notificationapp-xf54.vercel.app/send';

  // Initialize notifications
  Future<void> initialize({
    required Function(String chatId, String otherUserId, String otherUserName, String otherUserBloodType) onNotificationTap,
    required Function(String chatId, String message) onReply,
  }) async {
    print('🔔 Starting notification initialization...');

    // Request permissions
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    print('Permission status: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {

      // Get FCM token
      fcmToken = await _firebaseMessaging.getToken();
      print('FCM Token: $fcmToken');

      // Initialize local notifications
      await _initializeLocalNotifications(onNotificationTap, onReply);

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('📩 Foreground message: ${message.notification?.title}');
        _showLocalNotification(message);
      });

      // Handle notification taps when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('📱 Notification tapped (background)');
        _handleNotificationTap(message, onNotificationTap);
      });

      // Check if app was opened from terminated state
      RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        print('📱 App opened from notification (terminated)');
        _handleNotificationTap(initialMessage, onNotificationTap);
      }

      print('✅ Notification service initialized');
    } else {
      print('❌ Notification permissions denied');
    }
  }

  // Initialize local notifications
  Future<void> _initializeLocalNotifications(
      Function(String chatId, String otherUserId, String otherUserName, String otherUserBloodType) onNotificationTap,
      Function(String chatId, String message) onReply,
      ) async {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@drawable/ic_notification');

    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print('📱 Local notification tapped');
        if (response.payload != null) {
          final data = json.decode(response.payload!);
          onNotificationTap(
            data['chatId'] ?? '',
            data['senderId'] ?? '',
            data['senderName'] ?? 'User',
            data['bloodType'] ?? 'N/A',
          );
        }
      },
    );
  }

  // Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'chat_channel',
      'Chat Notifications',
      channelDescription: 'Notifications for new chat messages',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@drawable/ic_notification',
      color: Color(0xFFE53935),
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'New Message',
      message.notification?.body ?? '',
      details,
      payload: json.encode(message.data),
    );
  }

  // Handle notification tap
  void _handleNotificationTap(
      RemoteMessage message,
      Function(String chatId, String otherUserId, String otherUserName, String otherUserBloodType) onNotificationTap,
      ) {
    final data = message.data;
    onNotificationTap(
      data['chatId'] ?? '',
      data['senderId'] ?? '',
      data['senderName'] ?? 'User',
      data['bloodType'] ?? 'N/A',
    );
  }

  // Send notification via your Vercel backend
  Future<void> sendNotification({
    required String receiverId,
    required String title,
    required String body,
  }) async {
    try {
      print('📤 Sending notification to receiverId: $receiverId');
      print('   Title: $title');
      print('   Body: $body');

      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'receiverId': receiverId,
          'title': title,
          'body': body,
        }),
      );

      if (response.statusCode == 200) {
        print('✅ Notification sent successfully');
        print('Response: ${response.body}');
      } else {
        print('❌ Failed to send notification: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('❌ Error sending notification: $e');
    }
  }
}