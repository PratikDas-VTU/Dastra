// Responsive and Adaptive layout utilities for Dastra
import 'package:flutter/material.dart';

enum ScreenSize {
  compact,      // < 480
  largePhone,   // 480 - 768
  tablet,       // 768 - 1024
  smallDesktop, // 1024 - 1440
  desktop,      // 1440 - 1920
  ultrawide,    // >= 1920
}

class Breakpoints {
  static const double compact = 480;
  static const double largePhone = 768;
  static const double tablet = 1024;
  static const double smallDesktop = 1440;
  static const double desktop = 1920;
}

/// Helper class to resolve current ScreenSize from BuildContext or BoxConstraints
class Adaptive {
  static ScreenSize resolve(double width) {
    if (width < Breakpoints.compact) return ScreenSize.compact;
    if (width < Breakpoints.largePhone) return ScreenSize.largePhone;
    if (width < Breakpoints.tablet) return ScreenSize.tablet;
    if (width < Breakpoints.smallDesktop) return ScreenSize.smallDesktop;
    if (width < Breakpoints.desktop) return ScreenSize.desktop;
    return ScreenSize.ultrawide;
  }

  static ScreenSize of(BuildContext context) {
    return resolve(MediaQuery.of(context).size.width);
  }

  static bool isCompact(BuildContext context) => of(context) == ScreenSize.compact;
  static bool isLargePhone(BuildContext context) => of(context) == ScreenSize.largePhone;
  static bool isTablet(BuildContext context) => of(context) == ScreenSize.tablet;
  
  /// Returns true if the screen is tablet or smaller
  static bool isMobileOrTablet(BuildContext context) {
    final size = of(context);
    return size == ScreenSize.compact || size == ScreenSize.largePhone || size == ScreenSize.tablet;
  }

  /// Returns a scaled value based on the screen width
  static double scale(BuildContext context, {required double compact, required double desktop}) {
    final width = MediaQuery.of(context).size.width;
    if (width >= Breakpoints.desktop) return desktop;
    if (width <= Breakpoints.compact) return compact;
    
    // Linear interpolation
    final t = (width - Breakpoints.compact) / (Breakpoints.desktop - Breakpoints.compact);
    return compact + (desktop - compact) * t;
  }
}

/// A highly flexible builder that responds to ScreenSize
class AdaptiveBuilder extends StatelessWidget {
  const AdaptiveBuilder({
    super.key,
    this.compact,
    this.largePhone,
    this.tablet,
    this.smallDesktop,
    this.desktop,
    this.ultrawide,
    required this.builder,
  });

  final Widget Function(BuildContext context, ScreenSize size)? compact;
  final Widget Function(BuildContext context, ScreenSize size)? largePhone;
  final Widget Function(BuildContext context, ScreenSize size)? tablet;
  final Widget Function(BuildContext context, ScreenSize size)? smallDesktop;
  final Widget Function(BuildContext context, ScreenSize size)? desktop;
  final Widget Function(BuildContext context, ScreenSize size)? ultrawide;
  
  /// Fallback builder if a specific breakpoint isn't provided
  final Widget Function(BuildContext context, ScreenSize size) builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Adaptive.resolve(constraints.maxWidth);
        
        switch (size) {
          case ScreenSize.compact:
            if (compact != null) return compact!(context, size);
            break;
          case ScreenSize.largePhone:
            if (largePhone != null) return largePhone!(context, size);
            if (compact != null) return compact!(context, size);
            break;
          case ScreenSize.tablet:
            if (tablet != null) return tablet!(context, size);
            if (largePhone != null) return largePhone!(context, size);
            if (compact != null) return compact!(context, size);
            break;
          case ScreenSize.smallDesktop:
            if (smallDesktop != null) return smallDesktop!(context, size);
            if (desktop != null) return desktop!(context, size); // Prefer desktop if smallDesktop is missing
            break;
          case ScreenSize.desktop:
            if (desktop != null) return desktop!(context, size);
            if (smallDesktop != null) return smallDesktop!(context, size);
            break;
          case ScreenSize.ultrawide:
            if (ultrawide != null) return ultrawide!(context, size);
            if (desktop != null) return desktop!(context, size);
            if (smallDesktop != null) return smallDesktop!(context, size);
            break;
        }
        
        // Final fallback
        return builder(context, size);
      },
    );
  }
}

// ── BuildContext Extensions ──

class _ResponsiveLayout {
  final BuildContext _context;
  _ResponsiveLayout(this._context);

  bool get isCompact => Adaptive.isCompact(_context);
  bool get isLargePhone => Adaptive.isLargePhone(_context);
  bool get isMobile => isCompact || isLargePhone;
  bool get isTablet => Adaptive.isTablet(_context);
  bool get isDesktop => !isMobile && !isTablet;
}

class _ResponsiveSpacing {
  final BuildContext _context;
  _ResponsiveSpacing(this._context);

  double get xs => 4.0;
  double get sm => 8.0;
  
  double get md {
    final size = Adaptive.of(_context);
    if (size == ScreenSize.compact || size == ScreenSize.largePhone) return 12.0;
    return 16.0;
  }
  
  double get lg {
    final size = Adaptive.of(_context);
    if (size == ScreenSize.compact || size == ScreenSize.largePhone) return 16.0;
    if (size == ScreenSize.tablet) return 20.0;
    return 24.0;
  }
  
  double get xl {
    final size = Adaptive.of(_context);
    if (size == ScreenSize.compact || size == ScreenSize.largePhone) return 24.0;
    if (size == ScreenSize.tablet) return 28.0;
    return 32.0;
  }
  
  double get xxl {
    final size = Adaptive.of(_context);
    if (size == ScreenSize.compact || size == ScreenSize.largePhone) return 32.0;
    if (size == ScreenSize.tablet) return 40.0;
    return 48.0;
  }
}

extension ResponsiveContextExtension on BuildContext {
  _ResponsiveLayout get layout => _ResponsiveLayout(this);
  _ResponsiveSpacing get spacing => _ResponsiveSpacing(this);
}

// ── Legacy Helpers (Deprecated) ──
@Deprecated('Use Adaptive.isMobileOrTablet instead')
bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < 768;

@Deprecated('Use Adaptive.of instead')
bool isTablet(BuildContext context) => 
    MediaQuery.of(context).size.width >= 768 && 
    MediaQuery.of(context).size.width < 1024;

@Deprecated('Use Adaptive.of instead')
bool isDesktop(BuildContext context) => MediaQuery.of(context).size.width >= 1024;

@Deprecated('Use Adaptive instead')
int toolGridColumns(BuildContext context) {
  final w = MediaQuery.of(context).size.width;
  if (w >= Breakpoints.desktop) return 6;
  if (w >= Breakpoints.smallDesktop) return 4;
  if (w >= Breakpoints.tablet) return 3;
  if (w >= Breakpoints.largePhone) return 2;
  return 1;
}

@Deprecated('Use AdaptiveBuilder instead')
class AdaptiveLayout extends StatelessWidget {
  const AdaptiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      compact: (_, __) => mobile,
      tablet: tablet != null ? (_, __) => tablet! : null,
      desktop: (_, __) => desktop,
      builder: (_, size) {
        if (size == ScreenSize.compact || size == ScreenSize.largePhone) return mobile;
        if (size == ScreenSize.tablet) return tablet ?? mobile;
        return desktop;
      },
    );
  }
}
