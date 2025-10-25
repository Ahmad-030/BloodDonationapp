// ============================================================================
// FILE: lib/utils/helpers.dart
// Helper functions and utilities
// ============================================================================



import 'package:intl/intl.dart';

class Helpers {
  // Format date to readable string
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  // Format time to readable string
  static String formatTime(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }

  // Format date and time
  static String formatDateTime(DateTime date) {
    return DateFormat('MMM dd, yyyy hh:mm a').format(date);
  }

  // Validate email
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Validate phone
  static bool isValidPhone(String phone) {
    return RegExp(r'^\+?[\d\s-]{10,}$').hasMatch(phone);
  }

  // Get urgency color
  static String getUrgencyColor(String urgency) {
    switch (urgency) {
      case 'critical':
        return 'red';
      case 'urgent':
        return 'orange';
      default:
        return 'green';
    }
  }
}