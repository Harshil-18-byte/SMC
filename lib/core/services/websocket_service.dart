import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/io.dart';
import 'package:smc/core/providers/notification_provider.dart';

class WebSocketService {
  static IOWebSocketChannel? _channel;
  static bool _isConnected = false;
  static Timer? _reconnectTimer;
  static Timer? _pingTimer;

  // Stream controllers for different data types
  static final _notificationController =
      StreamController<AppNotification>.broadcast();
  static final _statsController =
      StreamController<Map<String, dynamic>>.broadcast();

  static Stream<AppNotification> get notificationStream =>
      _notificationController.stream;
  static Stream<Map<String, dynamic>> get statsStream =>
      _statsController.stream;

  static Future<void> connect() async {
    if (_isConnected) return;

    try {
      // Simulation: using a placeholder URL
      _channel = IOWebSocketChannel.connect(
        Uri.parse('wss://echo.websocket.events'),
      );

      _isConnected = true;

      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnect,
      );

      _pingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
        _sendPing();
      });

      debugPrint('WebSocket connected');
    } catch (e) {
      debugPrint('WebSocket connection error: $e');
      _scheduleReconnect();
    }
  }

  static void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message);
      final type = data['type'];
      final payload = data['payload'];

      switch (type) {
        case 'notification':
          _notificationController.add(AppNotification.fromJson(payload));
          break;
        case 'stats_update':
          _statsController.add(payload);
          break;
        case 'pong':
          break;
        default:
          debugPrint('Unknown WebSocket message type: $type');
      }
    } catch (e) {
      debugPrint('Error handling WebSocket message: $e');
    }
  }

  static void _handleError(dynamic error) {
    debugPrint('WebSocket error: $error');
    _isConnected = false;
    _scheduleReconnect();
  }

  static void _handleDisconnect() {
    debugPrint('WebSocket disconnected');
    _isConnected = false;
    _pingTimer?.cancel();
    _scheduleReconnect();
  }

  static void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      connect();
    });
  }

  static void _sendPing() {
    if (_isConnected) {
      _channel?.sink.add(jsonEncode({'type': 'ping'}));
    }
  }

  static void disconnect() {
    _reconnectTimer?.cancel();
    _pingTimer?.cancel();
    _channel?.sink.close();
    _isConnected = false;
  }

  static void dispose() {
    disconnect();
    _notificationController.close();
    _statsController.close();
  }
}


