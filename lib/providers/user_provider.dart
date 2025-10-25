// ============================================================================
// FILE: lib/providers/user_provider.dart
// User state management using Provider
// ============================================================================

import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  Map<String, dynamic>? _userData;

  Map<String, dynamic>? get userData => _userData;

  String? get userId => _userData?['uid'];
  String? get userName => _userData?['name'];
  String? get userEmail => _userData?['email'];
  String? get userPhone => _userData?['phone'];
  String? get userBloodType => _userData?['bloodType'];
  String? get userCity => _userData?['city'];
  String? get userType => _userData?['userType'];
  int? get userAge => _userData?['age'];

  bool get isDonor => _userData?['userType'] == 'donor';
  bool get isReceiver => _userData?['userType'] == 'receiver';
  bool get isLoggedIn => _userData != null;

  void setUser(Map<String, dynamic> data) {
    _userData = data;
    notifyListeners();
  }

  void updateUser(Map<String, dynamic> updates) {
    if (_userData != null) {
      _userData!.addAll(updates);
      notifyListeners();
    }
  }

  void clearUser() {
    _userData = null;
    notifyListeners();
  }
}