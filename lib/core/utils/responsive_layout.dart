import 'package:flutter/material.dart';

class ResponsiveLayout {
  static const double mobileMaxWidth = 600;
  static const double tabletMaxWidth = 1024;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileMaxWidth;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileMaxWidth &&
      MediaQuery.of(context).size.width < tabletMaxWidth;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletMaxWidth;

  static int getGridColumnCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 1; // Mobile: 1 or 2 columns
    if (width < 900) return 2; // Large Mobile / Small Tablet
    if (width < 1200) return 3; // Tablet / Laptop
    return 4; // Desktop / Wide Screen
  }

  static double getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 16.0;
    if (width < 1024) return 32.0;
    return (width - 1100) / 2 > 32 ? (width - 1100) / 2 : 32.0;
  }
}
