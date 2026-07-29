// Core color tokens for Dastra's permanent Design System
import 'package:flutter/material.dart';

abstract class DastraColorTokens {
  Color get background;
  Color get surface;
  Color get card;
  Color get cardHover;
  Color get border;
  Color get borderSubtle;
  Color get borderHover;
  Color get focusRing;
  Color get textPrimary;
  Color get textSecondary;
  Color get textMuted;
  Color get textDisabled;
  Color get accentCyan;
  Color get accentBlue;
  Color get accentPurple;
  Color get accentOrange;
  Color get accentOrangeLight;
  Color get success;
  Color get warning;
  Color get error;
  Color get info;
  List<Color> get accentGradient;
  List<Color> get documentGradient;
  List<Color> get imageGradient;
  List<Color> get securityGradient;
  List<Color> get splashGradient;
  Color get overlay;
  Color get glassBg;
  Color get glassBgDeeper;
  Color get glassStroke;
}

class DarkColors implements DastraColorTokens {
  const DarkColors();

  @override
  Color get background => const Color(0xFF0E0F11);
  @override
  Color get surface => const Color(0xFF141518);
  @override
  Color get card => const Color(0xFF1C1D22);
  @override
  Color get cardHover => const Color(0xFF24262D);
  @override
  Color get border => const Color(0xFF2C2D35);
  @override
  Color get borderSubtle => const Color(0xFF1F2026);
  @override
  Color get borderHover => const Color(0xFF3E404C);
  @override
  Color get focusRing => const Color(0x665E6AD2);
  @override
  Color get textPrimary => const Color(0xFFF3F4F6);
  @override
  Color get textSecondary => const Color(0xFF9CA3AF);
  @override
  Color get textMuted => const Color(0xFF6B7280);
  @override
  Color get textDisabled => const Color(0xFF3F3F46);
  @override
  Color get accentCyan => const Color(0xFF60A5FA);
  @override
  Color get accentBlue => const Color(0xFF5E6AD2);
  @override
  Color get accentPurple => const Color(0xFF818CF8);
  @override
  Color get accentOrange => const Color(0xFFD97706);
  @override
  Color get accentOrangeLight => const Color(0xFFF59E0B);
  @override
  Color get success => const Color(0xFF2E9D58);
  @override
  Color get warning => const Color(0xFFD28A25);
  @override
  Color get error => const Color(0xFFE5484D);
  @override
  Color get info => const Color(0xFF5E6AD2);

  @override
  List<Color> get accentGradient => const [
    Color(0xFF60A5FA),
    Color(0xFF5E6AD2),
    Color(0xFF818CF8),
  ];
  @override
  List<Color> get documentGradient => const [
    Color(0xFF5E6AD2),
    Color(0xFF818CF8),
  ];
  @override
  List<Color> get imageGradient => const [
    Color(0xFF60A5FA),
    Color(0xFF5E6AD2),
  ];
  @override
  List<Color> get securityGradient => const [
    Color(0xFFD97706),
    Color(0xFFE5484D),
  ];
  @override
  List<Color> get splashGradient => const [
    Color(0xFF60A5FA),
    Color(0xFF5E6AD2),
    Color(0xFF818CF8),
  ];

  @override
  Color get overlay => const Color(0x66000000);
  @override
  Color get glassBg => const Color(0x0AFFFFFF);
  @override
  Color get glassBgDeeper => const Color(0x05FFFFFF);
  @override
  Color get glassStroke => const Color(0x14FFFFFF);
}

class LightColors implements DastraColorTokens {
  const LightColors();

  @override
  Color get background => const Color(0xFFF8FAFC);
  @override
  Color get surface => const Color(0xFFF1F5F9);
  @override
  Color get card => const Color(0xFFFFFFFF);
  @override
  Color get cardHover => const Color(0xFFF8FAFC);
  @override
  Color get border => const Color(0xFFE2E8F0);
  @override
  Color get borderSubtle => const Color(0xFFF1F5F9);
  @override
  Color get borderHover => const Color(0xFFCBD5E1);
  @override
  Color get focusRing => const Color(0x662563EB);
  @override
  Color get textPrimary => const Color(0xFF111827);
  @override
  Color get textSecondary => const Color(0xFF4B5563);
  @override
  Color get textMuted => const Color(0xFF6B7280);
  @override
  Color get textDisabled => const Color(0xFF9CA3AF);
  @override
  Color get accentCyan => const Color(0xFF0284C7);
  @override
  Color get accentBlue => const Color(0xFF2563EB);
  @override
  Color get accentPurple => const Color(0xFF6366F1);
  @override
  Color get accentOrange => const Color(0xFFD97706);
  @override
  Color get accentOrangeLight => const Color(0xFFF59E0B);
  @override
  Color get success => const Color(0xFF16A34A);
  @override
  Color get warning => const Color(0xFFD97706);
  @override
  Color get error => const Color(0xFFDC2626);
  @override
  Color get info => const Color(0xFF2563EB);

  @override
  List<Color> get accentGradient => const [
    Color(0xFF3B82F6),
    Color(0xFF2563EB),
    Color(0xFF6366F1),
  ];
  @override
  List<Color> get documentGradient => const [
    Color(0xFF2563EB),
    Color(0xFF4F46E5),
  ];
  @override
  List<Color> get imageGradient => const [
    Color(0xFF0284C7),
    Color(0xFF2563EB),
  ];
  @override
  List<Color> get securityGradient => const [
    Color(0xFFEA580C),
    Color(0xFFDC2626),
  ];
  @override
  List<Color> get splashGradient => const [
    Color(0xFF3B82F6),
    Color(0xFF2563EB),
    Color(0xFF6366F1),
  ];

  @override
  Color get overlay => const Color(0x33000000);
  @override
  Color get glassBg => const Color(0xD9FFFFFF);
  @override
  Color get glassBgDeeper => const Color(0xF2FFFFFF);
  @override
  Color get glassStroke => const Color(0xFFE2E8F0);
}

class AppColors {
  AppColors._();

  static const DarkColors _dark = DarkColors();
  static const LightColors _light = LightColors();

  /// Retrieve active theme color tokens based on BuildContext
  static DastraColorTokens of(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light ? _light : _dark;
  }

  // Backward compatibility static constants (defaulting to dark theme constants)
  static const Color background = Color(0xFF0E0F11);
  static const Color surface = Color(0xFF141518);
  static const Color card = Color(0xFF1C1D22);
  static const Color cardHover = Color(0xFF24262D);
  static const Color border = Color(0xFF2C2D35);
  static const Color borderSubtle = Color(0xFF1F2026);
  static const Color borderHover = Color(0xFF3E404C);
  static const Color focusRing = Color(0x665E6AD2);
  static const Color textPrimary = Color(0xFFF3F4F6);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color textDisabled = Color(0xFF3F3F46);
  static const Color accentCyan = Color(0xFF60A5FA);
  static const Color accentBlue = Color(0xFF5E6AD2);
  static const Color accentPurple = Color(0xFF818CF8);
  static const Color accentOrange = Color(0xFFD97706);
  static const Color accentOrangeLight = Color(0xFFF59E0B);
  static const Color success = Color(0xFF2E9D58);
  static const Color warning = Color(0xFFD28A25);
  static const Color error = Color(0xFFE5484D);
  static const Color info = Color(0xFF5E6AD2);

  static const List<Color> accentGradient = [
    Color(0xFF60A5FA),
    Color(0xFF5E6AD2),
    Color(0xFF818CF8),
  ];
  static const List<Color> documentGradient = [
    Color(0xFF5E6AD2),
    Color(0xFF818CF8),
  ];
  static const List<Color> imageGradient = [
    Color(0xFF60A5FA),
    Color(0xFF5E6AD2),
  ];
  static const List<Color> securityGradient = [
    Color(0xFFD97706),
    Color(0xFFE5484D),
  ];
  static const List<Color> splashGradient = [
    Color(0xFF60A5FA),
    Color(0xFF5E6AD2),
    Color(0xFF818CF8),
  ];

  static const Color overlay = Color(0x66000000);
  static const Color glassBg = Color(0x0AFFFFFF);
  static const Color glassBgDeeper = Color(0x05FFFFFF);
  static const Color glassStroke = Color(0x14FFFFFF);
}

extension ColorContextExtension on BuildContext {
  DastraColorTokens get colors => AppColors.of(this);
}
