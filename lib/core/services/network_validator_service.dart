import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Network Validator Service
/// Ensures field workers use mobile data (not WiFi) for better tracking
class NetworkValidatorService {
  /// Stream of connectivity results
  static Stream<List<ConnectivityResult>> get connectivityStream =>
      Connectivity().onConnectivityChanged;

  /// Stream of WiFi status (true if connected to WiFi)
  static Stream<bool> get isWiFiStream => connectivityStream
      .map((results) => results.contains(ConnectivityResult.wifi));

  /// Check if currently connected to WiFi
  static Future<bool> isConnectedToWiFi() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult.contains(ConnectivityResult.wifi);
  }

  /// Check if connected to mobile data
  static Future<bool> isConnectedToMobileData() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult.contains(ConnectivityResult.mobile);
  }

  /// Check if any network is available
  static Future<bool> isNetworkAvailable() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult.contains(ConnectivityResult.wifi) ||
        connectivityResult.contains(ConnectivityResult.mobile);
  }

  /// Get current network type
  static Future<String> getCurrentNetworkType() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult.contains(ConnectivityResult.wifi)) {
      return 'WiFi';
    } else if (connectivityResult.contains(ConnectivityResult.mobile)) {
      return 'Mobile Data';
    } else if (connectivityResult.contains(ConnectivityResult.ethernet)) {
      return 'Ethernet';
    } else {
      return 'No Connection';
    }
  }

  /// Check if internet connection is available (WiFi or Mobile Data)
  static Future<bool> hasInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return !connectivityResult.contains(ConnectivityResult.none);
  }

  /// Show WiFi warning dialog
  static Future<bool?> showWiFiWarningDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.wifi, color: Colors.orange[700]),
            const SizedBox(width: 12),
            const Text('WiFi Detected'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'You are connected to WiFi.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'For field work, please use mobile data for:',
            ),
            const SizedBox(height: 8),
            _buildBulletPoint('Accurate GPS tracking'),
            _buildBulletPoint('Better location accuracy'),
            _buildBulletPoint('Consistent connectivity'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.orange.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 20, color: Colors.orange[700]),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Please disable WiFi and use mobile data',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Continue Anyway'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.settings),
            label: const Text('Open Settings'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  /// Validate network before critical operations
  static Future<bool> validateNetworkForFieldWork(BuildContext context) async {
    final isWiFi = await isConnectedToWiFi();

    if (isWiFi) {
      final shouldOpenSettings = await showWiFiWarningDialog(context);

      if (shouldOpenSettings == true) {
        // Open WiFi settings (platform-specific)
        // For now, just return false
        return false;
      }

      // User chose to continue anyway
      return true;
    }

    // Using mobile data or no WiFi detected
    return true;
  }

  /// Get network status widget
  static Widget buildNetworkStatusChip(String networkType) {
    Color color;
    IconData icon;

    switch (networkType) {
      case 'Mobile Data':
        color = Colors.green;
        icon = Icons.signal_cellular_alt;
        break;
      case 'WiFi':
        color = Colors.orange;
        icon = Icons.wifi;
        break;
      default:
        color = Colors.red;
        icon = Icons.signal_cellular_off;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            networkType,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}


