import 'dart:math';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DeviceCapabilities {
  final DeviceType deviceType;
  final ScreenSize screenSize;
  final PerformanceTier performanceTier;
  final bool hasNotch;
  final bool supportsHaptics;
  final bool supportsCamera;
  final bool supportsGPS;
  final double pixelDensity;
  final String platform;
  final int androidSdkVersion;
  final bool isLowEndDevice;

  DeviceCapabilities({
    required this.deviceType,
    required this.screenSize,
    required this.performanceTier,
    required this.hasNotch,
    required this.supportsHaptics,
    required this.supportsCamera,
    required this.supportsGPS,
    required this.pixelDensity,
    required this.platform,
    required this.androidSdkVersion,
    required this.isLowEndDevice,
  });
}

enum DeviceType { phone, tablet, foldable, desktop }

enum ScreenSize { compact, medium, expanded, large }

enum PerformanceTier { low, medium, high }

class DeviceInfoService {
  static DeviceCapabilities? _capabilities;
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  static Future<DeviceCapabilities> getCapabilities() async {
    if (_capabilities != null) return _capabilities!;

    // Detect platform
    String platform;
    int androidSdkVersion = 0;

    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidInfo = await _deviceInfo.androidInfo;
      platform = 'android';
      androidSdkVersion = androidInfo.version.sdkInt;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      // final iosInfo = await _deviceInfo.iosInfo;
      platform = 'ios';
    } else {
      platform = 'web';
    }

    // Get screen metrics
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    final size = view.physicalSize / view.devicePixelRatio;
    final pixelDensity = view.devicePixelRatio;

    // Determine device type
    final deviceType = _determineDeviceType(size, platform);

    // Determine screen size category
    final screenSize = _determineScreenSize(size);

    // Determine performance tier
    final performanceTier =
        await _determinePerformanceTier(androidSdkVersion, platform);

    // Detect notch
    final hasNotch = view.padding.top > 24;

    _capabilities = DeviceCapabilities(
      deviceType: deviceType,
      screenSize: screenSize,
      performanceTier: performanceTier,
      hasNotch: hasNotch,
      supportsHaptics: platform == 'ios' || androidSdkVersion >= 26,
      supportsCamera: !kIsWeb,
      supportsGPS: !kIsWeb,
      pixelDensity: pixelDensity,
      platform: platform,
      androidSdkVersion: androidSdkVersion,
      isLowEndDevice: performanceTier == PerformanceTier.low,
    );

    return _capabilities!;
  }

  static DeviceType _determineDeviceType(Size size, String platform) {
    final diagonal = sqrt(pow(size.width, 2) + pow(size.height, 2));

    if (platform == 'web') return DeviceType.desktop;

    if (diagonal > 1100) return DeviceType.tablet;
    if (diagonal > 900) return DeviceType.foldable;
    return DeviceType.phone;
  }

  static ScreenSize _determineScreenSize(Size size) {
    final width = size.width;

    if (width < 600) return ScreenSize.compact; // Phone
    if (width < 840) return ScreenSize.medium; // Tablet portrait
    if (width < 1200) return ScreenSize.expanded; // Tablet landscape
    return ScreenSize.large; // Desktop
  }

  static Future<PerformanceTier> _determinePerformanceTier(
    int androidSdkVersion,
    String platform,
  ) async {
    if (platform == 'ios') return PerformanceTier.high;

    // Android performance detection
    if (androidSdkVersion != 0) {
      if (androidSdkVersion < 24) return PerformanceTier.low; // Android 7.0-
      if (androidSdkVersion < 29) return PerformanceTier.medium; // Android 7-9
    }
    return PerformanceTier.high; // Android 10+ or others
  }

  static bool shouldUseSimplifiedUI() {
    return _capabilities?.isLowEndDevice ?? false;
  }

  static bool shouldEnableAnimations() {
    return _capabilities?.performanceTier != PerformanceTier.low;
  }

  static int getImageQuality() {
    switch (_capabilities?.performanceTier) {
      case PerformanceTier.low:
        return 50;
      case PerformanceTier.medium:
        return 75;
      case PerformanceTier.high:
      default:
        return 90;
    }
  }
}


