import 'package:flutter/material.dart';
import '../utils/responsive.dart';
import 'app_colors.dart';
import 'app_radius.dart';
import 'app_shadows.dart';

/// Centralizes platform-specific styling (Android vs Desktop) while
/// preserving Dastra's visual identity.
class AdaptiveTheme {
  AdaptiveTheme._();

  // ── Card Styles ────────────────────────────────────────────────────────
  static BoxDecoration cardDecoration(BuildContext context, {bool hovered = false}) {
    final isMob = isMobile(context);
    
    // On mobile, we prefer flatter surfaces. On desktop, we prefer slight shadows.
    return BoxDecoration(
      color: context.colors.card,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      border: Border.all(
        color: hovered && !isMob
            ? context.colors.accentBlue.withValues(alpha: 0.4)
            : context.colors.border,
        width: 1,
      ),
      boxShadow: hovered && !isMob
          ? AppShadows.cardHoverShadow(context)
          : isMob 
              ? [] // Flat on mobile
              : AppShadows.cardShadow(context),
    );
  }

  // ── Dialog Styles ────────────────────────────────────────────────────────
  static ShapeBorder dialogShape(BuildContext context) {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(
        isMobile(context) ? AppRadius.lg : AppRadius.xl,
      ),
    );
  }

  // ── Button Styles ────────────────────────────────────────────────────────
  static ButtonStyle primaryButtonStyle(BuildContext context) {
    return ElevatedButton.styleFrom(
      backgroundColor: context.colors.accentBlue,
      foregroundColor: context.colors.textPrimary,
      elevation: isMobile(context) ? 2 : 0,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile(context) ? 24 : 16,
        vertical: isMobile(context) ? 14 : 12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
    );
  }

  static ButtonStyle secondaryButtonStyle(BuildContext context) {
    return OutlinedButton.styleFrom(
      foregroundColor: context.colors.textPrimary,
      side: BorderSide(color: context.colors.border),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile(context) ? 24 : 16,
        vertical: isMobile(context) ? 14 : 12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
    );
  }
}
