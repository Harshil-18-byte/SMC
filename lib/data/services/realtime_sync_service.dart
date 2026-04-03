import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Real-time sync service for field worker data collection
/// Handles data integrity, conflict resolution, and bandwidth optimization
class RealtimeSyncService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Connectivity _connectivity = Connectivity();

  // Sync status tracking
  SyncStatus _syncStatus = SyncStatus.idle;
  double _syncProgress = 0.0;
  String _syncMessage = '';
  int _pendingUploads = 0;
  int _failedUploads = 0;

  // Bandwidth tracking
  int _bytesUploaded = 0;
  int _bytesDownloaded = 0;
  DateTime? _lastSyncTime;

  // Connection monitoring
  StreamSubscription? _connectivitySubscription;
  bool _isOnline = true;

  // Getters
  SyncStatus get syncStatus => _syncStatus;
  double get syncProgress => _syncProgress;
  String get syncMessage => _syncMessage;
  int get pendingUploads => _pendingUploads;
  int get failedUploads => _failedUploads;
  bool get isOnline => _isOnline;
  DateTime? get lastSyncTime => _lastSyncTime;
  String get bandwidthUsage =>
      '↑${_formatBytes(_bytesUploaded)} ↓${_formatBytes(_bytesDownloaded)}';

  RealtimeSyncService() {
    _initConnectivityMonitoring();
  }

  /// Initialize connectivity monitoring
  void _initConnectivityMonitoring() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        final wasOnline = _isOnline;
        _isOnline = results.any((result) =>
            result == ConnectivityResult.mobile ||
            result == ConnectivityResult.wifi);

        if (!wasOnline && _isOnline) {
          _syncMessage = 'Connection restored';
          notifyListeners();
        } else if (wasOnline && !_isOnline) {
          _syncMessage = 'Connection lost';
          notifyListeners();
        }
      },
    );
  }

  /// Upload household visit data with photos
  /// Returns the document ID on success
  Future<String?> uploadVisitData({
    required String workerId,
    required String householdId,
    required Map<String, dynamic> formData,
    List<File>? photos,
  }) async {
    if (!_isOnline) {
      throw Exception('No internet connection. Please check your network.');
    }

    _updateSyncStatus(SyncStatus.uploading, 'Preparing data...');
    _pendingUploads++;
    notifyListeners();

    try {
      // Step 1: Compress and upload photos first
      List<String> photoUrls = [];
      if (photos != null && photos.isNotEmpty) {
        _syncMessage = 'Compressing ${photos.length} photos...';
        notifyListeners();

        photoUrls = await _uploadPhotosWithCompression(
          photos,
          householdId,
          workerId,
        );
      }

      // Step 2: Create visit document with metadata
      final visitData = {
        ...formData,
        'workerId': workerId,
        'householdId': householdId,
        'photoUrls': photoUrls,
        'photoCount': photoUrls.length,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'version': 1, // For conflict resolution
        'deviceInfo': await _getDeviceInfo(),
        'syncedAt': FieldValue.serverTimestamp(),
      };

      _syncMessage = 'Uploading visit data...';
      notifyListeners();

      // Step 3: Upload to Firestore
      final docRef = await _firestore.collection('visits').add(visitData);

      // Step 4: Update household last visit time
      await _firestore.collection('households').doc(householdId).update({
        'lastVisitDate': FieldValue.serverTimestamp(),
        'lastVisitBy': workerId,
        'visitCount': FieldValue.increment(1),
      });

      _pendingUploads--;
      _lastSyncTime = DateTime.now();
      _updateSyncStatus(SyncStatus.success, 'Visit uploaded successfully');

      return docRef.id;
    } catch (e) {
      _failedUploads++;
      _pendingUploads--;
      _updateSyncStatus(SyncStatus.error, 'Upload failed: ${e.toString()}');
      rethrow;
    }
  }

  /// Compress and upload photos with progress tracking
  Future<List<String>> _uploadPhotosWithCompression(
    List<File> photos,
    String householdId,
    String workerId,
  ) async {
    final List<String> uploadedUrls = [];
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    for (int i = 0; i < photos.length; i++) {
      try {
        _syncProgress = (i / photos.length);
        _syncMessage = 'Uploading photo ${i + 1}/${photos.length}...';
        notifyListeners();

        // Compress image
        final compressedFile = await _compressImage(photos[i]);
        final fileSize = await compressedFile.length();

        // Upload to Firebase Storage
        final fileName = '${workerId}_${householdId}_${timestamp}_$i.jpg';
        final storageRef = _storage.ref().child('visit_photos/$fileName');

        final uploadTask = storageRef.putFile(
          compressedFile,
          SettableMetadata(
            contentType: 'image/jpeg',
            customMetadata: {
              'workerId': workerId,
              'householdId': householdId,
              'originalSize': photos[i].lengthSync().toString(),
              'compressedSize': fileSize.toString(),
            },
          ),
        );

        // Track bandwidth
        uploadTask.snapshotEvents.listen((snapshot) {
          _bytesUploaded += snapshot.bytesTransferred;
        });

        final snapshot = await uploadTask;
        final downloadUrl = await snapshot.ref.getDownloadURL();
        uploadedUrls.add(downloadUrl);

        // Clean up compressed file
        await compressedFile.delete();
      } catch (e) {
        debugPrint('Error uploading photo $i: $e');
        // Continue with other photos
      }
    }

    _syncProgress = 1.0;
    return uploadedUrls;
  }

  /// Compress image to reduce bandwidth usage
  /// Target: <100KB per photo
  Future<File> _compressImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) return imageFile;

    // Resize if too large (max 1280px on longest side)
    img.Image resized = image;
    if (image.width > 1280 || image.height > 1280) {
      resized = img.copyResize(
        image,
        width: image.width > image.height ? 1280 : null,
        height: image.height > image.width ? 1280 : null,
      );
    }

    // Compress as JPEG with quality 85
    final compressed = img.encodeJpg(resized, quality: 85);

    // Save to temp file
    final tempDir = await getTemporaryDirectory();
    final tempFile = File(
        '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await tempFile.writeAsBytes(compressed);

    return tempFile;
  }

  /// Update existing visit data (with conflict resolution)
  Future<void> updateVisitData({
    required String visitId,
    required Map<String, dynamic> updates,
    required int currentVersion,
  }) async {
    if (!_isOnline) {
      throw Exception('No internet connection');
    }

    _updateSyncStatus(SyncStatus.uploading, 'Updating visit...');

    try {
      // Use transaction for conflict resolution
      await _firestore.runTransaction((transaction) async {
        final docRef = _firestore.collection('visits').doc(visitId);
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists) {
          throw Exception('Visit not found');
        }

        final serverVersion = snapshot.data()?['version'] ?? 1;

        // Conflict detection
        if (serverVersion != currentVersion) {
          throw ConflictException(
            'Data was modified by another user. Please refresh and try again.',
            serverVersion: serverVersion,
            clientVersion: currentVersion,
          );
        }

        // Update with new version
        transaction.update(docRef, {
          ...updates,
          'version': serverVersion + 1,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });

      _updateSyncStatus(SyncStatus.success, 'Visit updated successfully');
    } catch (e) {
      if (e is ConflictException) {
        _updateSyncStatus(SyncStatus.conflict, e.message);
      } else {
        _updateSyncStatus(SyncStatus.error, 'Update failed: ${e.toString()}');
      }
      rethrow;
    }
  }

  /// Listen to real-time updates for a specific household
  Stream<DocumentSnapshot> watchHousehold(String householdId) {
    return _firestore.collection('households').doc(householdId).snapshots();
  }

  /// Listen to real-time updates for worker's visits
  Stream<QuerySnapshot> watchWorkerVisits(String workerId) {
    return _firestore
        .collection('visits')
        .where('workerId', isEqualTo: workerId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots();
  }

  /// Get sync statistics
  Future<SyncStatistics> getSyncStatistics(String workerId) async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    final todayVisits = await _firestore
        .collection('visits')
        .where('workerId', isEqualTo: workerId)
        .where('createdAt', isGreaterThanOrEqualTo: todayStart)
        .count()
        .get();

    final totalVisits = await _firestore
        .collection('visits')
        .where('workerId', isEqualTo: workerId)
        .count()
        .get();

    return SyncStatistics(
      todayVisits: todayVisits.count ?? 0,
      totalVisits: totalVisits.count ?? 0,
      lastSyncTime: _lastSyncTime,
      bandwidthUsed: _bytesUploaded + _bytesDownloaded,
      pendingUploads: _pendingUploads,
      failedUploads: _failedUploads,
    );
  }

  /// Clear local cache (for storage management)
  Future<void> clearCache() async {
    try {
      final tempDir = await getTemporaryDirectory();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
        await tempDir.create();
      }
      _syncMessage = 'Cache cleared successfully';
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing cache: $e');
    }
  }

  /// Get device info for tracking
  Future<Map<String, dynamic>> _getDeviceInfo() async {
    return {
      'platform': Platform.operatingSystem,
      'version': Platform.operatingSystemVersion,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Update sync status
  void _updateSyncStatus(SyncStatus status, String message) {
    _syncStatus = status;
    _syncMessage = message;
    notifyListeners();
  }

  /// Format bytes for display
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}

/// Sync status enum
enum SyncStatus {
  idle,
  uploading,
  downloading,
  success,
  error,
  conflict,
}

/// Conflict exception
class ConflictException implements Exception {
  final String message;
  final int serverVersion;
  final int clientVersion;

  ConflictException(
    this.message, {
    required this.serverVersion,
    required this.clientVersion,
  });

  @override
  String toString() => message;
}

/// Sync statistics model
class SyncStatistics {
  final int todayVisits;
  final int totalVisits;
  final DateTime? lastSyncTime;
  final int bandwidthUsed;
  final int pendingUploads;
  final int failedUploads;

  SyncStatistics({
    required this.todayVisits,
    required this.totalVisits,
    this.lastSyncTime,
    required this.bandwidthUsed,
    required this.pendingUploads,
    required this.failedUploads,
  });

  String get formattedBandwidth {
    if (bandwidthUsed < 1024) return '${bandwidthUsed}B';
    if (bandwidthUsed < 1024 * 1024) {
      return '${(bandwidthUsed / 1024).toStringAsFixed(1)}KB';
    }
    return '${(bandwidthUsed / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}

/// Upload task model
class UploadTask {
  final String id;
  final String workerId;
  final Map<String, dynamic> data;
  final List<File>? photos;
  final DateTime createdAt;

  UploadTask({
    required this.id,
    required this.workerId,
    required this.data,
    this.photos,
    required this.createdAt,
  });
}


