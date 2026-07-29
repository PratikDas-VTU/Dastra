import 'package:flutter/material.dart';
import '../utils/responsive.dart';

/// Centralized metrics system to replace hardcoded values globally.
/// This adapts automatically to the screen size (mobile vs desktop).
class AppMetrics {
  AppMetrics._();

  // ── Touch Targets ────────────────────────────────────────────────────────
  static double minTouchTarget(BuildContext context) => isMobile(context) ? 48.0 : 32.0;
  static double standardButtonHeight(BuildContext context) => isMobile(context) ? 52.0 : 44.0;
  static double smallButtonHeight(BuildContext context) => isMobile(context) ? 40.0 : 32.0;

  // ── Icon Sizes ───────────────────────────────────────────────────────────
  static double iconSmall(BuildContext context) => isMobile(context) ? 18.0 : 16.0;
  static double iconNormal(BuildContext context) => isMobile(context) ? 24.0 : 20.0;
  static double iconLarge(BuildContext context) => isMobile(context) ? 32.0 : 28.0;
  
  // ── Margins & Padding (Layout) ───────────────────────────────────────────
  static double pagePadding(BuildContext context) {
    if (isDesktop(context)) return 48.0;
    if (isTablet(context)) return 32.0;
    return 16.0;
  }
  
  // ── Overlays & Modals ────────────────────────────────────────────────────
  static double dialogMaxWidth(BuildContext context) => 500.0;
  static double bottomSheetMaxHeightRatio(BuildContext context) => 0.9;

  // ── Layout Constraints ───────────────────────────────────────────────────
  static const double maxDashboardWidth = 1320.0;
  static const double maxWorkspaceWidth = 1400.0;
  static const double maxSettingsWidth = 960.0;
  static const double maxAboutWidth = 900.0;
}
