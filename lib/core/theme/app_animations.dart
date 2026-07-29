import 'package:flutter/material.dart';

class AppAnimations {
  AppAnimations._();

  // ── Durations ─────────────────────────────────────────────────────────────
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration medium = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration extraSlow = Duration(milliseconds: 700);

  // ── Curves ────────────────────────────────────────────────────────────────
  static const Curve standard = Curves.easeInOutCubic;
  static const Curve decelerate = Curves.easeOutQuart;
  static const Curve accelerate = Curves.easeInQuart;
  
  // Custom spring curve for subtle bounces without being too "bouncy"
  static const Curve subtleSpring = Curves.easeOutBack;
}
