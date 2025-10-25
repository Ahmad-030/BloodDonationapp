// ============================================================================
// FILE: lib/utils/constants.dart
// App constants and static data
// ============================================================================

class AppConstants {
  // Blood Types
  static const List<String> bloodTypes = [
    'A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'
  ];

  static const List<String> bloodTypesWithAll = [
    'All', 'A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'
  ];

  // Urgency Levels
  static const List<String> urgencyLevels = [
    'normal', 'urgent', 'critical'
  ];

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String requestsCollection = 'blood_requests';
  static const String donationsCollection = 'donations';
  static const String chatsCollection = 'chats';
  static const String messagesCollection = 'messages';

  // User Types
  static const String donor = 'donor';
  static const String receiver = 'receiver';

  // Request Status
  static const String active = 'active';
  static const String fulfilled = 'fulfilled';
  static const String cancelled = 'cancelled';
}