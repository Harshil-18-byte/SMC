import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Firestore Service - Handles all Cloud Firestore operations
/// Provides a clean API for CRUD operations, streaming, and querying.
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Singleton instance
  static final FirestoreService _instance = FirestoreService._internal();

  factory FirestoreService() {
    return _instance;
  }

  FirestoreService._internal();

  /// Create or update a document in a collection
  /// If [docId] is provided, it uses [set]. If not, it uses [add].
  Future<String> createDocument({
    required String collection,
    String? docId,
    required Map<String, dynamic> data,
  }) async {
    try {
      if (docId != null && docId.isNotEmpty) {
        await _db.collection(collection).doc(docId).set(data);
        debugPrint('✅ Document set: $collection/$docId');
        return docId;
      } else {
        final docRef = await _db.collection(collection).add(data);
        debugPrint('✅ Document added: $collection/${docRef.id}');
        return docRef.id;
      }
    } catch (e) {
      debugPrint('❌ Create document failed: $e');
      rethrow;
    }
  }

  /// Update a document in a collection
  Future<void> updateDocument({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _db.collection(collection).doc(docId).update(data);
      debugPrint('✅ Document updated: $collection/$docId');
    } catch (e) {
      debugPrint('❌ Update document failed: $e');
      rethrow;
    }
  }

  /// Delete a document from a collection
  Future<void> deleteDocument({
    required String collection,
    required String docId,
  }) async {
    try {
      await _db.collection(collection).doc(docId).delete();
      debugPrint('✅ Document deleted: $collection/$docId');
    } catch (e) {
      debugPrint('❌ Delete document failed: $e');
      rethrow;
    }
  }

  /// Alias for getDocument to match codebase usage
  Future<Map<String, dynamic>?> readDocument({
    required String collection,
    required String docId,
  }) =>
      getDocument(collection: collection, docId: docId);

  /// Get a single document from a collection
  Future<Map<String, dynamic>?> getDocument({
    required String collection,
    required String docId,
  }) async {
    try {
      final doc = await _db.collection(collection).doc(docId).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          return {
            ...data,
            'id': doc.id,
          };
        }
      }
      return null;
    } catch (e) {
      debugPrint('❌ Get document failed: $e');
      rethrow;
    }
  }

  /// Query a collection based on a field and value
  Future<List<Map<String, dynamic>>> queryCollection({
    required String collection,
    required String field,
    required dynamic value,
  }) async {
    try {
      final snapshot =
          await _db.collection(collection).where(field, isEqualTo: value).get();
      return snapshot.docs.map((doc) {
        return {
          ...doc.data(),
          'id': doc.id,
        };
      }).toList();
    } catch (e) {
      debugPrint('❌ Query collection failed: $e');
      rethrow;
    }
  }

  /// Get a collection with optional sorting, filtering, and limits
  Future<List<Map<String, dynamic>>> getCollection({
    required String collection,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _db.collection(collection);

      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) {
        return {
          ...doc.data(),
          'id': doc.id,
        };
      }).toList();
    } catch (e) {
      debugPrint('❌ Get collection failed: $e');
      rethrow;
    }
  }

  /// Stream a collection for real-time updates
  Stream<List<Map<String, dynamic>>> streamCollection({
    required String collection,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) {
    Query<Map<String, dynamic>> query = _db.collection(collection);

    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          ...doc.data(),
          'id': doc.id,
        };
      }).toList();
    });
  }

  /// Stream a single document for real-time updates
  Stream<Map<String, dynamic>?> streamDocument({
    required String collection,
    required String docId,
  }) {
    return _db.collection(collection).doc(docId).snapshots().map((doc) {
      final data = doc.data();
      if (doc.exists && data != null) {
        return {
          ...data,
          'id': doc.id,
        };
      }
      return null;
    });
  }

  /// Batch write operation
  Future<void> runBatch(Future<void> Function(WriteBatch batch) action) async {
    final batch = _db.batch();
    await action(batch);
    await batch.commit();
  }
}
