import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smc/core/services/device_info_service.dart';

class UniversalTheme {
  // Adaptive spacing based on screen size
  static double getSpacing(BuildContext context, SpacingSize size) {
    final screenSize = _getScreenSize(context);

    final spacingMap = {
      ScreenSize.compact: {
        SpacingSize.xs: 4.0,
        SpacingSize.sm: 8.0,
        SpacingSize.md: 16.0,
        SpacingSize.lg: 24.0,
        SpacingSize.xl: 32.0,
      },
      ScreenSize.medium: {
        SpacingSize.xs: 6.0,
        SpacingSize.sm: 12.0,
        SpacingSize.md: 20.0,
        SpacingSize.lg: 32.0,
        SpacingSize.xl: 48.0,
      },
      ScreenSize.expanded: {
        SpacingSize.xs: 8.0,
        SpacingSize.sm: 16.0,
        SpacingSize.md: 24.0,
        SpacingSize.lg: 40.0,
        SpacingSize.xl: 64.0,
      },
      ScreenSize.large: {
        SpacingSize.xs: 8.0,
        SpacingSize.sm: 16.0,
        SpacingSize.md: 32.0,
        SpacingSize.lg: 48.0,
        SpacingSize.xl: 80.0,
      },
    };

    return spacingMap[screenSize]![size]!;
  }

  // Adaptive font sizes
  static double getFontSize(BuildContext context, FontSize size) {
    final screenSize = _getScreenSize(context);

    // Attempt to get device capabilities if available in provider
    DeviceCapabilities? deviceCapabilities;
    try {
      deviceCapabilities =
          Provider.of<DeviceCapabilities>(context, listen: false);
    } catch (_) {
      // Fallback if provider not ready
    }

    // Base scale factor
    double scaleFactor = 1.0;

    if (screenSize == ScreenSize.large) scaleFactor = 1.2;
    if (screenSize == ScreenSize.expanded) scaleFactor = 1.1;

    if (deviceCapabilities != null && deviceCapabilities.pixelDensity < 2.0) {
      scaleFactor *= 1.1; // Low DPI compensation
    }

    final fontMap = {
      FontSize.caption: 12.0,
      FontSize.body: 14.0,
      FontSize.subtitle: 16.0,
      FontSize.title: 20.0,
      FontSize.headline: 24.0,
      FontSize.display: 32.0,
    };

    return fontMap[size]! * scaleFactor;
  }

  // Adaptive component sizes
  static double getComponentSize(BuildContext context, ComponentSize size) {
    final screenSize = _getScreenSize(context);

    final sizeMap = {
      ScreenSize.compact: {
        ComponentSize.small: 32.0,
        ComponentSize.medium: 44.0,
        ComponentSize.large: 56.0,
      },
      ScreenSize.medium: {
        ComponentSize.small: 36.0,
        ComponentSize.medium: 48.0,
        ComponentSize.large: 64.0,
      },
      ScreenSize.expanded: {
        ComponentSize.small: 40.0,
        ComponentSize.medium: 52.0,
        ComponentSize.large: 72.0,
      },
      ScreenSize.large: {
        ComponentSize.small: 44.0,
        ComponentSize.medium: 56.0,
        ComponentSize.large: 80.0,
      },
    };

    return sizeMap[screenSize]![size]!;
  }

  static ScreenSize _getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < 600) return ScreenSize.compact;
    if (width < 840) return ScreenSize.medium;
    if (width < 1200) return ScreenSize.expanded;
    return ScreenSize.large;
  }
}

enum SpacingSize { xs, sm, md, lg, xl }

enum FontSize { caption, body, subtitle, title, headline, display }

enum ComponentSize { small, medium, large }


