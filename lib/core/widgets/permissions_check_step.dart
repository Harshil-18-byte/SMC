import 'package:flutter/material.dart';
import 'package:smc/core/services/permissions_service.dart';
import 'dart:async';

/// Permissions and Network Check Widget
/// Step 6 of the visit form - validates all requirements before submission
class PermissionsCheckStep extends StatefulWidget {
  final VoidCallback onAllGranted;

  const PermissionsCheckStep({
    super.key,
    required this.onAllGranted,
  });

  @override
  State<PermissionsCheckStep> createState() => _PermissionsCheckStepState();
}

class _PermissionsCheckStepState extends State<PermissionsCheckStep> {
  bool _isChecking = true;
  Map<String, bool> _permissions = {};
  bool _allPermissionsGranted = false;
  // Network tracking removed as requested

  @override
  void initState() {
    super.initState();
    _checkAllRequirements();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Network listener removed as requested

  Future<void> _checkAllRequirements({bool isInitial = true}) async {
    if (isInitial) setState(() => _isChecking = true);

    // Check permissions
    final permissions = await PermissionsService.getPermissionDetails();

    setState(() {
      _permissions = permissions;
      _allPermissionsGranted = permissions.values.every((granted) => granted);
      _isChecking = false;
    });

    // Auto-proceed if all granted
    if (_allPermissionsGranted) {
      widget.onAllGranted();
    }
  }

  Future<void> _requestPermission(String permissionName) async {
    bool granted = false;

    switch (permissionName) {
      case 'location':
        granted = await PermissionsService.requestLocationPermission();
        break;
      case 'camera':
        granted = await PermissionsService.requestCameraPermission();
        break;
      case 'bluetooth':
        granted = await PermissionsService.requestBluetoothPermission();
        break;
    }

    if (granted) {
      await _checkAllRequirements();
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$permissionName permission is required'),
          action: SnackBarAction(
            label: 'Settings',
            onPressed: () => PermissionsService.openSettings(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'PERMISSIONS & NETWORK CHECK',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Verify all requirements before submitting',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // Permissions
          _buildSectionTitle('Required Permissions'),
          const SizedBox(height: 12),
          if (_isChecking)
            const Center(child: CircularProgressIndicator())
          else ...[
            _buildPermissionTile(
              'Location',
              'Required for GPS tracking',
              Icons.location_on,
              _permissions['location'] ?? false,
              'location',
            ),
            const SizedBox(height: 8),
            _buildPermissionTile(
              'Camera',
              'Required for photo capture',
              Icons.camera_alt,
              _permissions['camera'] ?? false,
              'camera',
            ),
            const SizedBox(height: 8),
            _buildPermissionTile(
              'Bluetooth',
              'Required for device tracking',
              Icons.bluetooth,
              _permissions['bluetooth'] ?? false,
              'bluetooth',
            ),
          ],

          const SizedBox(height: 24),

          // Status Summary
          if (!_isChecking) _buildStatusSummary(isDark),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // Network card removed as requested

  Widget _buildPermissionTile(
    String title,
    String subtitle,
    IconData icon,
    bool isGranted,
    String permissionKey,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isGranted
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isGranted
              ? Colors.green.withValues(alpha: 0.3)
              : Colors.red.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isGranted ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          if (isGranted)
            const Icon(Icons.check_circle, color: Colors.green, size: 24)
          else
            TextButton(
              onPressed: () => _requestPermission(permissionKey),
              child: const Text('Grant'),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusSummary(bool isDark) {
    final allGood = _allPermissionsGranted;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: allGood
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: allGood
              ? Colors.green.withValues(alpha: 0.3)
              : Colors.orange.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            allGood ? Icons.check_circle : Icons.warning,
            color: allGood ? Colors.green : Colors.orange,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              allGood
                  ? 'All permissions granted! Ready to submit.'
                  : 'Please grant all required permissions',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: allGood ? Colors.green : Colors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


