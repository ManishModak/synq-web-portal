import 'package:flutter/material.dart';

class ResponsiveUtils {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 768;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 768 &&
      MediaQuery.of(context).size.width < 1024;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024;

  static double getResponsiveHeight(BuildContext context, double ratio) =>
      MediaQuery.of(context).size.height * ratio;

  static double getResponsiveWidth(BuildContext context, double ratio) =>
      MediaQuery.of(context).size.width * ratio;

  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    final width = MediaQuery.of(context).size.width;
    if (width < 768) return baseSize * 0.9;
    if (width < 1024) return baseSize;
    return baseSize * 1.1;
  }

  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isMobile(context)) return const EdgeInsets.all(16);
    if (isTablet(context)) return const EdgeInsets.all(24);
    return const EdgeInsets.all(32);
  }

  static double getShimmerHeight(BuildContext context, String type) {
    final height = MediaQuery.of(context).size.height;
    switch (type) {
      case 'qos':
        return height * 0.25; // 25% of screen height
      case 'traffic':
        return height * 0.35; // 35% of screen height
      case 'connection':
        return height * 0.2; // 20% of screen height
      case 'points':
        return height * 0.15; // 15% of screen height
      default:
        return height * 0.2;
    }
  }
}
