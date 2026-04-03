import 'package:flutter/material.dart';

class SyncProvider extends ChangeNotifier {
  bool _isSyncing = false;
  double _progress = 0.0;
  DateTime? _lastSyncTime;
  int _pendingCount = 0;

  bool get isSyncing => _isSyncing;
  double get progress => _progress;
  DateTime? get lastSyncTime => _lastSyncTime;
  int get pendingCount => _pendingCount;

  Future<void> sync() async {
    if (_isSyncing) return;

    _isSyncing = true;
    _progress = 0.0;
    notifyListeners();

    // Simulate sync process
    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 300));
      _progress = i / 10;
      notifyListeners();
    }

    _lastSyncTime = DateTime.now();
    _isSyncing = false;
    _pendingCount = 0;
    notifyListeners();
  }
}


