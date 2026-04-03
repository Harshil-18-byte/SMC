import 'package:flutter/material.dart';
import 'package:smc/data/models/user_model.dart';

class UserProvider extends ChangeNotifier {
  User? _currentUser;

  User? get currentUser => _currentUser;

  UserProvider() {
    // User starts as null (logged out).
    // They must log in via SecureLoginScreen to get a user.
    _currentUser = null;
  }

  void setUser(User user) {
    if (_currentUser?.id == user.id) return;
    _currentUser = user;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
