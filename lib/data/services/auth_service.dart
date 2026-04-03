import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smc/data/services/firebase_service.dart';

/// Authentication Service - Handles all Firebase Authentication operations
/// Provides methods for login, signup, logout, and auth state management
class AuthService {
  final FirebaseService _firebaseService = FirebaseService();

  // Get Firebase Auth instance
  FirebaseAuth get _auth => _firebaseService.auth;

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Check if user is signed in
  bool get isSignedIn => currentUser != null;

  /// Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign up with email and password
  /// Returns User on success, throws FirebaseAuthException on failure
  Future<User?> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      debugPrint('✅ User signed up: ${credential.user?.email}');
      return credential.user;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Sign up failed: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  /// Sign in with Google (Mock/Conceptual)
  Future<User?> signInWithGoogle() async {
    try {
      // Note: In real production, use google_sign_in package
      // For now, we simulate a successful Google sign-in
      await Future.delayed(const Duration(seconds: 1));
      debugPrint('✅ Google Sign-In Simulation Successful');
      return _auth.currentUser; // Returns current or null
    } catch (e) {
      debugPrint('❌ Google Sign-In failed: $e');
      rethrow;
    }
  }

  /// Sign in with Apple (Mock/Conceptual)
  Future<User?> signInWithApple() async {
    try {
      // Note: In real production, use sign_in_with_apple package
      await Future.delayed(const Duration(seconds: 1));
      debugPrint('✅ Apple Sign-In Simulation Successful');
      return _auth.currentUser;
    } catch (e) {
      debugPrint('❌ Apple Sign-In failed: $e');
      rethrow;
    }
  }

  /// Sign in with Phone (Mock/Conceptual)
  Future<void> signInWithPhone(String phoneNumber,
      {required Function(String) onCodeSent}) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      debugPrint('✅ Phone Auth: Code sent to $phoneNumber');
      onCodeSent('verificationId_123'); // Simulated ID
    } catch (e) {
      debugPrint('❌ Phone Auth failed: $e');
      rethrow;
    }
  }

  /// Sign in with email and password
  /// Returns User on success, throws FirebaseAuthException on failure
  Future<User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint('✅ User signed in: ${credential.user?.email}');
      return credential.user;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Sign in failed: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  /// Sign in anonymously (Guest Mode)
  Future<User?> signInAnonymously() async {
    try {
      final UserCredential credential = await _auth.signInAnonymously();
      debugPrint('✅ Guest signed in: ${credential.user?.uid}');
      return credential.user;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Guest sign in failed: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      debugPrint('✅ User signed out');
    } catch (e) {
      debugPrint('❌ Sign out failed: $e');
      rethrow;
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      debugPrint('✅ Password reset email sent to: $email');
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Password reset failed: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  /// Delete current user account
  Future<void> deleteAccount() async {
    try {
      await currentUser?.delete();
      debugPrint('✅ User account deleted');
    } catch (e) {
      debugPrint('❌ Account deletion failed: $e');
      rethrow;
    }
  }

  /// Map identifier to email based on role
  String _mapIdentifierToEmail(String identifier, String role) {
    // Simple mapping logic for demo purposes
    // In production, this might look up a user or use a specific format
    final cleanId = identifier.trim().replaceAll(' ', '');
    return '$cleanId@smc.test'; // Appending internal domain for demo
  }

  /// Login with role-based credentials
  Future<User?> loginWithCredentials({
    required String identifier,
    required String password,
    required String role,
  }) async {
    final email = _mapIdentifierToEmail(identifier, role);
    return signInWithEmail(email: email, password: password);
  }

  /// Mock OTP Sending
  Future<void> sendOTP(String identifier) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    debugPrint('🔢 OTP Sent to $identifier (Simulated)');
  }

  /// Mock OTP Verification
  Future<bool> verifyOTP(String identifier, String otp) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    // Accept standard test OTP or specific pattern
    return otp == '123456';
  }

  /// Get user-friendly error message from FirebaseAuthException
  String getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this ID.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this ID.';
      case 'invalid-email':
        return 'Invalid ID format.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'user-disabled':
        return 'This account has been disabled.';
      default:
        return 'Authentication error: ${e.message}';
    }
  }
}


