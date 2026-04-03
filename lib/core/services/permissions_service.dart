import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:geolocator/geolocator.dart';

/// Permissions Service
/// Handles all app permissions (location, camera, bluetooth)
class PermissionsService {
  /// Check if all required permissions are granted
  static Future<ph.PermissionStatus> checkAllPermissions() async {
    final location = await ph.Permission.location.status;
    final camera = await ph.Permission.camera.status;
    final bluetooth = await ph.Permission.bluetooth.status;

    if (location.isGranted && camera.isGranted && bluetooth.isGranted) {
      return ph.PermissionStatus.granted;
    } else if (location.isDenied || camera.isDenied || bluetooth.isDenied) {
      return ph.PermissionStatus.denied;
    } else {
      return ph.PermissionStatus.permanentlyDenied;
    }
  }

  /// Request all required permissions
  static Future<Map<String, ph.PermissionStatus>>
      requestAllPermissions() async {
    final results = <String, ph.PermissionStatus>{};

    // Request location permission
    final locationStatus = await ph.Permission.location.request();
    results['location'] = locationStatus;

    // Request camera permission
    final cameraStatus = await ph.Permission.camera.request();
    results['camera'] = cameraStatus;

    // Request bluetooth permission
    final bluetoothStatus = await ph.Permission.bluetooth.request();
    results['bluetooth'] = bluetoothStatus;

    return results;
  }

  /// Check location permission specifically
  static Future<bool> checkLocationPermission() async {
    final status = await ph.Permission.location.status;
    return status.isGranted;
  }

  /// Request location permission
  static Future<bool> requestLocationPermission() async {
    final status = await ph.Permission.location.request();
    return status.isGranted;
  }

  /// Check camera permission
  static Future<bool> checkCameraPermission() async {
    final status = await ph.Permission.camera.status;
    return status.isGranted;
  }

  /// Request camera permission
  static Future<bool> requestCameraPermission() async {
    final status = await ph.Permission.camera.request();
    return status.isGranted;
  }

  /// Check bluetooth permission
  static Future<bool> checkBluetoothPermission() async {
    final status = await ph.Permission.bluetooth.status;
    return status.isGranted;
  }

  /// Request bluetooth permission
  static Future<bool> requestBluetoothPermission() async {
    final status = await ph.Permission.bluetooth.request();
    return status.isGranted;
  }

  /// Open app settings
  static Future<void> openSettings() async {
    await ph.openAppSettings();
  }

  /// Get permission status details
  static Future<Map<String, bool>> getPermissionDetails() async {
    return {
      'location': await checkLocationPermission(),
      'camera': await checkCameraPermission(),
      'bluetooth': await checkBluetoothPermission(),
    };
  }

  /// Check if location services are enabled
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Get detailed location permission status
  static Future<LocationPermission> getLocationPermissionStatus() async {
    return await Geolocator.checkPermission();
  }
}


