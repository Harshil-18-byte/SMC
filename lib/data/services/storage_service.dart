import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:smc/data/services/firebase_service.dart';

/// Storage Service - Handles all Firebase Storage operations
/// Provides methods for uploading, downloading, and deleting files
class StorageService {
  final FirebaseService _firebaseService = FirebaseService();

  // Get Storage instance
  FirebaseStorage get _storage => _firebaseService.storage;

  /// Upload a file to Firebase Storage
  /// [filePath] - Local file path
  /// [storagePath] - Storage path (e.g., 'users/profile_pics/user123.jpg')
  /// Returns download URL of uploaded file
  Future<String> uploadFile({
    required String filePath,
    required String storagePath,
    Function(double)? onProgress,
  }) async {
    try {
      final file = File(filePath);
      final ref = _storage.ref().child(storagePath);
      final uploadTask = ref.putFile(file);

      // Listen to upload progress
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      // Wait for upload to complete
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      debugPrint('✅ File uploaded: $storagePath');
      return downloadUrl;
    } catch (e) {
      debugPrint('❌ Upload failed: $e');
      rethrow;
    }
  }

  /// Download a file from Firebase Storage
  /// [storagePath] - Storage path
  /// [localPath] - Local path to save file
  Future<void> downloadFile({
    required String storagePath,
    required String localPath,
    Function(double)? onProgress,
  }) async {
    try {
      final ref = _storage.ref().child(storagePath);
      final file = File(localPath);
      final downloadTask = ref.writeToFile(file);

      // Listen to download progress
      if (onProgress != null) {
        downloadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      await downloadTask;
      debugPrint('✅ File downloaded: $storagePath');
    } catch (e) {
      debugPrint('❌ Download failed: $e');
      rethrow;
    }
  }

  /// Get download URL for a file
  Future<String> getDownloadUrl(String storagePath) async {
    try {
      final ref = _storage.ref().child(storagePath);
      final url = await ref.getDownloadURL();
      debugPrint('✅ Download URL retrieved: $storagePath');
      return url;
    } catch (e) {
      debugPrint('❌ Get download URL failed: $e');
      rethrow;
    }
  }

  /// Delete a file from Firebase Storage
  Future<void> deleteFile(String storagePath) async {
    try {
      final ref = _storage.ref().child(storagePath);
      await ref.delete();
      debugPrint('✅ File deleted: $storagePath');
    } catch (e) {
      debugPrint('❌ Delete failed: $e');
      rethrow;
    }
  }

  /// List all files in a directory
  Future<List<String>> listFiles(String directoryPath) async {
    try {
      final ref = _storage.ref().child(directoryPath);
      final result = await ref.listAll();
      final fileNames = result.items.map((item) => item.name).toList();
      debugPrint('✅ Files listed: $directoryPath (${fileNames.length} files)');
      return fileNames;
    } catch (e) {
      debugPrint('❌ List files failed: $e');
      rethrow;
    }
  }

  /// Get file metadata
  Future<FullMetadata> getMetadata(String storagePath) async {
    try {
      final ref = _storage.ref().child(storagePath);
      final metadata = await ref.getMetadata();
      debugPrint('✅ Metadata retrieved: $storagePath');
      return metadata;
    } catch (e) {
      debugPrint('❌ Get metadata failed: $e');
      rethrow;
    }
  }
}



