import 'package:flutter/material.dart';
import '../theme/design_system.dart';

/// Responsive layout wrapper that adapts to screen size
/// 
/// Usage:
/// ```dart
/// ResponsiveLayout(
///   mobile: MobileWidget(),
///   tablet: TabletWidget(), // Optional, falls back to mobile
///   desktop: DesktopWidget(), // Optional, falls back to tablet or mobile
/// )
/// ```
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= Breakpoints.desktop && desktop != null) {
          return desktop!;
        } else if (constraints.maxWidth >= Breakpoints.tablet && tablet != null) {
          return tablet!;
        } else {
          return mobile;
        }
      },
    );
  }
}

/// Responsive grid that adapts columns based on screen width
/// 
/// Automatically adjusts the number of columns based on device type:
/// - Mobile: 1 column (default)
/// - Tablet: 2 columns (default)
/// - Desktop: 3 columns (default)
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final double? childAspectRatio;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = DesignSystem.space16,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.childAspectRatio,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int columns;
        if (constraints.maxWidth >= Breakpoints.desktop) {
          columns = desktopColumns;
        } else if (constraints.maxWidth >= Breakpoints.tablet) {
          columns = tabletColumns;
        } else {
          columns = mobileColumns;
        }

        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: spacing,
          crossAxisSpacing: spacing,
          childAspectRatio: childAspectRatio ?? 1.0,
          children: children,
        );
      },
    );
  }
}

/// A container that constrains its width on larger screens
/// 
/// Centers content and limits max width for better readability on desktop
class ContentContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;

  const ContentContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? DesignSystem.maxContentWidth,
        ),
        padding: padding ?? EdgeInsets.symmetric(
          horizontal: Breakpoints.getResponsivePadding(context),
        ),
        child: child,
      ),
    );
  }
}

/// Responsive value selector based on screen size
/// 
/// Returns different values based on current breakpoint
class ResponsiveValue<T> {
  final T mobile;
  final T? tablet;
  final T? desktop;

  const ResponsiveValue({
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  /// Get the appropriate value for the current screen size
  T get(BuildContext context) {
    if (Breakpoints.isDesktop(context) && desktop != null) {
      return desktop!;
    } else if (Breakpoints.isTablet(context) && tablet != null) {
      return tablet!;
    }
    return mobile;
  }
}
