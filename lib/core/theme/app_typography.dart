import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import '../utils/responsive.dart';

class AppTypography {
  final DastraColorTokens _colors;
  final BuildContext _context;
  const AppTypography(this._colors, this._context);

  static AppTypography of(BuildContext context) {
    return AppTypography(AppColors.of(context), context);
  }

  TextStyle get pageTitle {
    final size = Adaptive.of(_context);
    if (size == ScreenSize.compact || size == ScreenSize.largePhone) return h2;
    if (size == ScreenSize.tablet) return h1;
    return displayMedium;
  }
  
  TextStyle get sectionTitle {
    final size = Adaptive.of(_context);
    if (size == ScreenSize.compact || size == ScreenSize.largePhone) return h3;
    if (size == ScreenSize.tablet) return h2;
    return h1;
  }

  TextStyle get displayLarge => GoogleFonts.inter(
    fontSize: 48,
    fontWeight: FontWeight.w800,
    color: _colors.textPrimary,
    letterSpacing: -1.5,
    height: 1.1,
  );

  TextStyle get displayMedium => GoogleFonts.inter(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    color: _colors.textPrimary,
    letterSpacing: -1.2,
    height: 1.15,
  );

  TextStyle get h1 => GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: _colors.textPrimary,
    letterSpacing: -0.8,
    height: 1.2,
  );

  TextStyle get h2 => GoogleFonts.inter(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: _colors.textPrimary,
    letterSpacing: -0.5,
    height: 1.25,
  );

  TextStyle get h3 => GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: _colors.textPrimary,
    letterSpacing: -0.3,
    height: 1.3,
  );

  TextStyle get titleLarge => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: _colors.textPrimary,
  );

  TextStyle get titleMedium => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: _colors.textPrimary,
  );

  TextStyle get titleSmall => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: _colors.textPrimary,
  );

  TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: _colors.textPrimary,
    height: 1.5,
  );

  TextStyle get bodyMedium => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: _colors.textSecondary,
    height: 1.5,
  );

  TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: _colors.textSecondary,
    height: 1.4,
  );

  TextStyle get labelLarge => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: _colors.textPrimary,
  );

  TextStyle get labelMedium => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: _colors.textSecondary,
  );

  TextStyle get labelSmall => GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: _colors.textMuted,
  );

  TextStyle get caption => GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: _colors.textMuted,
    height: 1.3,
  );

  TextStyle get code => GoogleFonts.jetBrainsMono(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: _colors.accentCyan,
  );
}

extension TypographyContextExtension on BuildContext {
  AppTypography get typography => AppTypography.of(this);
}
