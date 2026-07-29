// Main theme configuration for Dastra
// Builds Material 3 ThemeData using custom tokens
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_radius.dart';

class AppTheme {
  AppTheme._();

  static const DarkColors _dark = DarkColors();
  static const LightColors _light = LightColors();

  static ThemeData get dark {
    final colorScheme = ColorScheme.dark(
      brightness: Brightness.dark,
      surface: _dark.surface,
      surfaceContainerHighest: _dark.card,
      primary: _dark.accentBlue,
      onPrimary: Colors.white,
      secondary: _dark.accentCyan,
      onSecondary: Colors.white,
      tertiary: _dark.accentPurple,
      onTertiary: Colors.white,
      error: _dark.error,
      onError: Colors.white,
      onSurface: _dark.textPrimary,
      outline: _dark.border,
      outlineVariant: _dark.borderSubtle,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: _dark.textPrimary,
      onInverseSurface: _dark.background,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _dark.background,
      canvasColor: _dark.surface,
      cardColor: _dark.card,

      // ── Typography (Inter) ──────────────────────────────────────────────
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.inter(
          fontSize: 48, fontWeight: FontWeight.w800, color: _dark.textPrimary,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: 36, fontWeight: FontWeight.w700, color: _dark.textPrimary,
        ),
        headlineLarge: GoogleFonts.inter(
          fontSize: 28, fontWeight: FontWeight.w700, color: _dark.textPrimary,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 22, fontWeight: FontWeight.w600, color: _dark.textPrimary,
        ),
        headlineSmall: GoogleFonts.inter(
          fontSize: 18, fontWeight: FontWeight.w600, color: _dark.textPrimary,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 16, fontWeight: FontWeight.w600, color: _dark.textPrimary,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w600, color: _dark.textPrimary,
        ),
        titleSmall: GoogleFonts.inter(
          fontSize: 13, fontWeight: FontWeight.w600, color: _dark.textPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16, fontWeight: FontWeight.w400, color: _dark.textPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w400, color: _dark.textSecondary,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12, fontWeight: FontWeight.w400, color: _dark.textSecondary,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 13, fontWeight: FontWeight.w600, color: _dark.textPrimary,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 12, fontWeight: FontWeight.w500, color: _dark.textSecondary,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 11, fontWeight: FontWeight.w500, color: _dark.textMuted,
        ),
      ),

      // ── AppBar ──────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: _dark.surface,
        foregroundColor: _dark.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: _dark.textPrimary,
        ),
      ),

      // ── Card ────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: _dark.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: _dark.border, width: 1),
        ),
      ),

      // ── Input Decoration ────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _dark.surface,
        hintStyle: GoogleFonts.inter(
          fontSize: 15, color: _dark.textMuted,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide(color: _dark.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide(color: _dark.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide(color: _dark.accentBlue, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),

      // ── Buttons ─────────────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _dark.accentBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 13, fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── Navigation Bar ──────────────────────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _dark.surface,
        indicatorColor: _dark.accentBlue.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(
              fontSize: 11, fontWeight: FontWeight.w600, color: _dark.accentBlue,
            );
          }
          return GoogleFonts.inter(
            fontSize: 11, fontWeight: FontWeight.w500, color: _dark.textMuted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: _dark.accentBlue, size: 22);
          }
          return IconThemeData(color: _dark.textMuted, size: 22);
        }),
        elevation: 0,
        height: 68,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),

      // ── Divider ─────────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: _dark.border,
        thickness: 1,
        space: 1,
      ),

      // ── Bottom Sheet ────────────────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: _dark.surface,
        modalBackgroundColor: _dark.surface,
      ),

      // ── Chip ────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: _dark.card,
        labelStyle: GoogleFonts.inter(
          fontSize: 12, fontWeight: FontWeight.w500, color: _dark.textSecondary,
        ),
        side: BorderSide(color: _dark.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
      ),

      // ── Switch ──────────────────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return _dark.accentBlue;
          return _dark.textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return _dark.accentBlue.withValues(alpha: 0.25);
          return _dark.surface;
        }),
      ),

      // ── Dialog ──────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: _dark.surface,
        elevation: 16,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          side: BorderSide(color: _dark.border),
        ),
      ),

      // ── Splash / Ripple ─────────────────────────────────────────────────
      splashColor: _dark.accentBlue.withValues(alpha: 0.08),
      highlightColor: Colors.transparent,
    );
  }

  static ThemeData get light {
    final colorScheme = ColorScheme.light(
      brightness: Brightness.light,
      surface: _light.surface,
      surfaceContainerHighest: _light.card,
      primary: _light.accentBlue,
      onPrimary: Colors.white,
      secondary: _light.accentCyan,
      onSecondary: Colors.white,
      tertiary: _light.accentPurple,
      onTertiary: Colors.white,
      error: _light.error,
      onError: Colors.white,
      onSurface: _light.textPrimary,
      outline: _light.border,
      outlineVariant: _light.borderSubtle,
      shadow: Colors.black12,
      scrim: Colors.black26,
      inverseSurface: _light.textPrimary,
      onInverseSurface: _light.background,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _light.background,
      canvasColor: _light.surface,
      cardColor: _light.card,

      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).copyWith(
        displayLarge: GoogleFonts.inter(
          fontSize: 48, fontWeight: FontWeight.w800, color: _light.textPrimary,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: 36, fontWeight: FontWeight.w700, color: _light.textPrimary,
        ),
        headlineLarge: GoogleFonts.inter(
          fontSize: 28, fontWeight: FontWeight.w700, color: _light.textPrimary,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 22, fontWeight: FontWeight.w600, color: _light.textPrimary,
        ),
        headlineSmall: GoogleFonts.inter(
          fontSize: 18, fontWeight: FontWeight.w600, color: _light.textPrimary,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 16, fontWeight: FontWeight.w600, color: _light.textPrimary,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w600, color: _light.textPrimary,
        ),
        titleSmall: GoogleFonts.inter(
          fontSize: 13, fontWeight: FontWeight.w600, color: _light.textPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16, fontWeight: FontWeight.w400, color: _light.textPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w400, color: _light.textSecondary,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12, fontWeight: FontWeight.w400, color: _light.textSecondary,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 13, fontWeight: FontWeight.w600, color: _light.textPrimary,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 12, fontWeight: FontWeight.w500, color: _light.textSecondary,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 11, fontWeight: FontWeight.w500, color: _light.textMuted,
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: _light.surface,
        foregroundColor: _light.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: _light.textPrimary,
        ),
      ),

      cardTheme: CardThemeData(
        color: _light.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: _light.border, width: 1),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _light.surface,
        hintStyle: GoogleFonts.inter(
          fontSize: 15, color: _light.textMuted,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide(color: _light.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide(color: _light.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide(color: _light.accentBlue, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _light.accentBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 13, fontWeight: FontWeight.w600,
          ),
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _light.surface,
        indicatorColor: _light.accentBlue.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(
              fontSize: 11, fontWeight: FontWeight.w600, color: _light.accentBlue,
            );
          }
          return GoogleFonts.inter(
            fontSize: 11, fontWeight: FontWeight.w500, color: _light.textMuted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: _light.accentBlue, size: 22);
          }
          return IconThemeData(color: _light.textMuted, size: 22);
        }),
        elevation: 0,
        height: 68,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),

      dividerTheme: DividerThemeData(
        color: _light.border,
        thickness: 1,
        space: 1,
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: _light.surface,
        modalBackgroundColor: _light.surface,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: _light.cardHover,
        labelStyle: GoogleFonts.inter(
          fontSize: 12, fontWeight: FontWeight.w500, color: _light.textSecondary,
        ),
        side: BorderSide(color: _light.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return _light.accentBlue;
          return _light.textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return _light.accentBlue.withValues(alpha: 0.25);
          return _light.cardHover;
        }),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: _light.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          side: BorderSide(color: _light.border),
        ),
      ),

      splashColor: _light.accentBlue.withValues(alpha: 0.08),
      highlightColor: Colors.transparent,
    );
  }
}
