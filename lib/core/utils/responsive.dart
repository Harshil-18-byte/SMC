import 'package:flutter/material.dart';

class Responsive {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double blockSizeHorizontal;
  static late double blockSizeVertical;
  static late double safeAreaHorizontal;
  static late double safeAreaVertical;
  static late double safeBlockHorizontal;
  static late double safeBlockVertical;
  static late bool isTablet;
  static late bool isPhone;

  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;

    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;

    safeAreaHorizontal =
        _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    safeAreaVertical =
        _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;

    safeBlockHorizontal = (screenWidth - safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - safeAreaVertical) / 100;

    isTablet = screenWidth > 600;
    isPhone = screenWidth <= 600;
  }

  // Responsive width
  static double wp(double percentage) {
    return screenWidth * (percentage / 100);
  }

  // Responsive height
  static double hp(double percentage) {
    return screenHeight * (percentage / 100);
  }

  // Responsive font size
  static double sp(double size) {
    // Based on iPhone SE width (375)
    return size * (screenWidth / 375);
  }
}

// Extension for easy access
extension ResponsiveExtension on BuildContext {
  double wp(double percentage) {
    Responsive.init(this);
    return Responsive.wp(percentage);
  }

  double hp(double percentage) {
    Responsive.init(this);
    return Responsive.hp(percentage);
  }

  double sp(double size) {
    Responsive.init(this);
    return Responsive.sp(size);
  }

  bool get isTablet => MediaQuery.of(this).size.width > 600;
  bool get isPhone => MediaQuery.of(this).size.width <= 600;
}


