// Gradient definitions used across Dastra
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppGradients {
  AppGradients._();

  /// Primary brand gradient ??" Cyan + Blue + Purple
  static const LinearGradient accent = LinearGradient(
    colors: AppColors.accentGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Document tools gradient ??" Blue + Purple
  static const LinearGradient document = LinearGradient(
    colors: AppColors.documentGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Image tools gradient ??" Cyan + Blue
  static const LinearGradient image = LinearGradient(
    colors: AppColors.imageGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Security tools gradient ??" Orange + Red
  static const LinearGradient security = LinearGradient(
    colors: AppColors.securityGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Splash / loading gradient
  static const LinearGradient splash = LinearGradient(
    colors: AppColors.splashGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Subtle card hover shimmer
  static const LinearGradient cardHover = LinearGradient(
    colors: [Color(0x05FFFFFF), Color(0x00FFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Glass surface (Extremely subtle)
  static const LinearGradient glass = LinearGradient(
    colors: [AppColors.glassBg, AppColors.glassBgDeeper],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Sidebar active indicator
  static const LinearGradient navActive = LinearGradient(
    colors: [Color(0x1A60A5FA), Color(0x1A5E6AD2)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
