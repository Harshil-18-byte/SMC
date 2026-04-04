import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class AppNotification {
  final String id;
  final String title;
  final String body;
  final String type;
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic>? data;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    required this.isRead,
    this.data,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      type: json['type'],
      createdAt: DateTime.parse(json['created_at']),
      isRead: json['is_read'] ?? false,
      data: json['data'],
    );
  }

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      title: title,
      body: body,
      type: type,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
      data: data,
    );
  }
}

class NotificationProvider extends ChangeNotifier {
  List<AppNotification> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;

  bool get notificationsEnabled => _enabled;
  bool _enabled = true; // Default to enabled

  NotificationProvider() {
    _initialize();
  }

  void setEnabled(bool value) {
    _enabled = value;
    notifyListeners();
  }

  Future<void> _initialize() async {
    await _initLocalNotifications();
    await loadNotifications();
  }

  Future<void> _initLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );
    await _localNotifications.initialize(settings: initSettings);
  }

  Future<void> loadNotifications() async {
    _isLoading = true;
    notifyListeners();

    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock notifications for now
    _notifications = [
      AppNotification(
        id: '1',
        title: 'New Visit Assigned',
        body: 'You have a new household visit in Sector 4.',
        type: 'new_visit',
        createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
        isRead: false,
      ),
      AppNotification(
        id: '2',
        title: 'Inspection Alert',
        body:
            'Heavy rainfall expected. Please advise citizens to use boiled water.',
        type: 'alert',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: true,
      ),
    ];

    _updateUnreadCount();
    _isLoading = false;
    notifyListeners();
  }

  void _updateUnreadCount() {
    _unreadCount = _notifications.where((n) => !n.isRead).length;
  }

  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _unreadCount--;
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    _unreadCount = 0;
    notifyListeners();
  }

  Future<void> deleteNotification(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      if (!_notifications[index].isRead) _unreadCount--;
      _notifications.removeAt(index);
      notifyListeners();
    }
  }

  Future<void> showLocalNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'smc_channel',
      'SMC Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );
    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );
    await _localNotifications.show(
      id: DateTime.now().millisecond,
      title: title,
      body: body,
      notificationDetails: details,
    );
  }
}

