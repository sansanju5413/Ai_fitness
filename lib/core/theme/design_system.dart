import 'package:flutter/material.dart';

/// Design System Constants for Consistent UI
/// 
/// This file provides a centralized source of truth for all spacing,
/// sizing, and visual constants used throughout the app.
class DesignSystem {
  // ============================================
  // SPACING SCALE (8pt grid system)
  // ============================================
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space40 = 40.0;
  static const double space48 = 48.0;
  static const double space64 = 64.0;

  // ============================================
  // BORDER RADIUS
  // ============================================
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 24.0;
  static const double radiusXLarge = 32.0;
  static const double radiusFull = 999.0; // Pills

  // ============================================
  // ICON SIZES
  // ============================================
  static const double iconSmall = 16.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  static const double iconXLarge = 48.0;

  // ============================================
  // BUTTON HEIGHTS
  // ============================================
  static const double buttonSmall = 36.0;
  static const double buttonMedium = 48.0;
  static const double buttonLarge = 56.0;

  // ============================================
  // CARD ELEVATIONS
  // ============================================
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;

  // ============================================
  // LAYOUT
  // ============================================
  static const double maxContentWidth = 600.0;
  static const double sidebarWidth = 280.0;
  static const double bottomNavHeight = 80.0;
  static const double appBarHeight = 56.0;

  // ============================================
  // COMMON EDGE INSETS
  // ============================================
  static const EdgeInsets paddingSmall = EdgeInsets.all(space8);
  static const EdgeInsets paddingMedium = EdgeInsets.all(space16);
  static const EdgeInsets paddingLarge = EdgeInsets.all(space24);
  
  static const EdgeInsets paddingHorizontalSmall = EdgeInsets.symmetric(horizontal: space8);
  static const EdgeInsets paddingHorizontalMedium = EdgeInsets.symmetric(horizontal: space16);
  static const EdgeInsets paddingHorizontalLarge = EdgeInsets.symmetric(horizontal: space24);
  
  static const EdgeInsets paddingVerticalSmall = EdgeInsets.symmetric(vertical: space8);
  static const EdgeInsets paddingVerticalMedium = EdgeInsets.symmetric(vertical: space16);
  static const EdgeInsets paddingVerticalLarge = EdgeInsets.symmetric(vertical: space24);
  
  static const EdgeInsets paddingScreenHorizontal = EdgeInsets.symmetric(horizontal: space24);
  static const EdgeInsets paddingScreenAll = EdgeInsets.all(space24);

  // ============================================
  // COMMON BORDER RADIUS
  // ============================================
  static BorderRadius borderRadiusSmall = BorderRadius.circular(radiusSmall);
  static BorderRadius borderRadiusMedium = BorderRadius.circular(radiusMedium);
  static BorderRadius borderRadiusLarge = BorderRadius.circular(radiusLarge);
  static BorderRadius borderRadiusXLarge = BorderRadius.circular(radiusXLarge);

  // ============================================
  // SHADOWS
  // ============================================
  static List<BoxShadow> shadowLow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> shadowMedium = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> shadowHigh = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.15),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];

  // ============================================
  // ANIMATION DURATIONS
  // ============================================
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
}

/// Responsive Breakpoints for adaptive layouts
class Breakpoints {
  static const double mobile = 640;
  static const double tablet = 768;
  static const double desktop = 1024;
  static const double wide = 1280;

  /// Check if current screen width is mobile
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < tablet;

  /// Check if current screen width is tablet
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= tablet &&
      MediaQuery.of(context).size.width < desktop;

  /// Check if current screen width is desktop
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktop;

  /// Get responsive horizontal padding based on screen width
  static double getResponsivePadding(BuildContext context) {
    if (isMobile(context)) return DesignSystem.space16;
    if (isTablet(context)) return DesignSystem.space24;
    return DesignSystem.space32;
  }

  /// Get responsive content width (constrained on larger screens)
  static double getContentWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= desktop) {
      return DesignSystem.maxContentWidth;
    }
    return screenWidth - (getResponsivePadding(context) * 2);
  }
}
