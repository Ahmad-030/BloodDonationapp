import 'package:blooddonation/providers/user_provider.dart';
import 'package:blooddonation/screens/splash/Splash.dart';
import 'package:blooddonation/theme/AppTheme_data.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

// Background message handler must be a top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('📩 Background message received: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Set up background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Request notification permissions
  final messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  // Configure foreground notification presentation
  await messaging.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  // Listen for auth state changes and save FCM token
  FirebaseAuth.instance.authStateChanges().listen((User? user) async {
    if (user != null) {
      await _saveFCMTokenForUser(user.uid);
    }
  });

  runApp(
    ChangeNotifierProvider(
      create: (_) => UserProvider(),
      child: BloodDonationApp(),
    ),
  );
}

// Save FCM token for a specific user
Future<void> _saveFCMTokenForUser(String userId) async {
  try {
    final messaging = FirebaseMessaging.instance;
    final token = await messaging.getToken();

    if (token != null) {
      print('🔑 Saving FCM Token for user: $userId');
      print('📱 Token: $token');

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .set({
        'fcmToken': token,
        'lastTokenUpdate': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print('✅ FCM Token saved successfully');
    }
  } catch (e) {
    print('❌ Error saving FCM token: $e');
  }
}

class BloodDonationApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blood Donation App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: SplashScreen(),
    );
  }
}