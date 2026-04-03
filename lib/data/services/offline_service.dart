import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:smc/data/models/task.dart';
import 'package:smc/data/models/visit_record_model.dart';
import 'package:smc/data/models/field_worker.dart'; // Added Import

/// Offline Service - Handles local data storage and sync
class OfflineService {
  static const String _tasksBoxName = 'offline_tasks';
  static const String _visitsBoxName = 'offline_visits';
  static const String _syncQueueBoxName = 'sync_queue';
  static const String _workerBoxName = 'offline_worker_profile'; // Added

  /// Initialize Hive and open boxes
  Future<void> init() async {
    await Hive.initFlutter();

    await Hive.openBox(_tasksBoxName);
    await Hive.openBox(_visitsBoxName);
    await Hive.openBox(_syncQueueBoxName);
    await Hive.openBox(_workerBoxName); // Added
    debugPrint('📦 Offline Storage Initialized');
  }

  /// Save tasks for offline access
  Future<void> cacheTasks(List<Task> tasks) async {
    final box = Hive.box<Map>(_tasksBoxName); // Ensure typed
    await box.clear();
    for (var task in tasks) {
      // Use put to overwrite keys if needed, but here new clear handles it
      await box.add(task.toMap());
    }
    debugPrint('📦 Cached ${tasks.length} tasks for offline use');
  }

  /// Get cached tasks
  List<Task> getCachedTasks() {
    final box = Hive.box(_tasksBoxName);
    // Hive stores dynamic maps, need to cast safely
    return box.values.map((e) {
      final map = Map<String, dynamic>.from(e as Map);
      return Task.fromMap(map, map['id'] ?? '');
    }).toList();
  }

  /// Cache worker profile
  Future<void> cacheWorkerProfile(FieldWorker worker) async {
    final box = Hive.box(_workerBoxName);
    await box.put('current_worker', worker.toMap());
    debugPrint('📦 Cached worker profile: ${worker.name}');
  }

  /// Get cached worker profile
  FieldWorker? getCachedWorkerProfile() {
    final box = Hive.box(_workerBoxName);
    final data = box.get('current_worker');
    if (data != null) {
      final map = Map<String, dynamic>.from(data as Map);
      return FieldWorker.fromMap(map, map['id'] ?? '');
    }
    return null;
  }

  /// Save a visit record locally (Queue for sync)
  Future<void> queueVisitRecord(VisitRecord record) async {
    final box = Hive.box(_syncQueueBoxName);
    await box.add({
      'type': 'visit_record',
      'data': record.toMap(),
      'timestamp': DateTime.now().toIso8601String(),
    });
    debugPrint('📦 Visit Record queued for sync: ${record.id}');
  }

  /// Get pending sync items count
  int getPendingSyncCount() {
    return Hive.box(_syncQueueBoxName).length;
  }

  /// Process sync queue (Called when online)
  Future<List<Map<String, dynamic>>> getSyncQueue() async {
    final box = Hive.box(_syncQueueBoxName);
    // Safe casting
    return box.values.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  /// Clear synced items
  Future<void> clearSyncQueue() async {
    await Hive.box(_syncQueueBoxName).clear();
  }

  /// Remove specific item from queue
  Future<void> deleteQueueItem(int index) async {
    final box = Hive.box(_syncQueueBoxName);
    await box.deleteAt(index);
  }
}


