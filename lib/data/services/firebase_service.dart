import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Firebase Service - Centralized access to Firebase services
/// This service provides instances for Auth and Storage.
class FirebaseService {
  // Singleton instance
  static final FirebaseService _instance = FirebaseService._internal();

  factory FirebaseService() {
    return _instance;
  }

  FirebaseService._internal();

  /// Get Firebase Auth instance
  FirebaseAuth get auth => FirebaseAuth.instance;

  /// Get Firebase Storage instance
  FirebaseStorage get storage => FirebaseStorage.instance;
}
