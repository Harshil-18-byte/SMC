import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smc/data/models/user_model.dart';
import 'package:smc/data/models/auth_models.dart';
import 'package:smc/data/services/auth_service.dart';
import 'package:smc/config/routes.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _currentUser;
  UserRole? _currentRole;
  bool _isLoading = true;
  String? _error;

  User? get currentUser => _currentUser;
  UserRole? get currentRole => _currentRole;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  String? get error => _error;

  AuthProvider() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final roleString = prefs.getString('user_role');
      final userDataString = prefs.getString('user_data');

      if (token != null && roleString != null && userDataString != null) {
        // In a real app, we'd validate the token with the server
        // For now, we restore from saved data
        _currentRole = _parseRole(roleString);
        _currentUser = User.fromJson(jsonDecode(userDataString));
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Auth initialization error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  UserRole _parseRole(String roleString) {
    return UserRole.values.firstWhere(
      (e) => e.name == roleString,
      orElse: () => UserRole.viewer,
    );
  }

  Future<bool> login({
    required String identifier,
    required String password,
    required UserRole role,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Use existing AuthService
      final firebaseUser = await _authService.loginWithCredentials(
        identifier: identifier,
        password: password,
        role: role.name,
      );

      if (firebaseUser != null) {
        // Create our app User model based on role
        if (role == UserRole.superAdmin) {
          _currentUser = User.mockNationalAdmin();
        } else if (role == UserRole.cityAdmin) {
          _currentUser = User.mockCityAdmin();
        } else if (role == UserRole.fieldInspector) {
          _currentUser = User.mockFieldInspector();
        } else {
          _currentUser = User.mockViewer();
        }

        _currentRole = role;

        // Save session
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
            'auth_token', firebaseUser.uid); // Using UID as token for demo
        await prefs.setString('user_role', role.name);
        await prefs.setString('user_data', jsonEncode(_currentUser!.toMap()));

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Login failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.signOut();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_role');
    await prefs.remove('user_data');

    _currentUser = null;
    _currentRole = null;

    notifyListeners();
  }
}

extension UserRoleExtension on UserRole {
  String get homeRoute {
    switch (this) {
      case UserRole.superAdmin:
        return AppRoutes.nationalDashboard;
      case UserRole.stateAdmin:
        return AppRoutes.stateDashboard;
      case UserRole.cityAdmin:
        return AppRoutes.cityDashboard;
      case UserRole.fieldInspector:
        return AppRoutes.inspectorHome;
      case UserRole.viewer:
        return AppRoutes.viewerHome;
    }
  }
}


