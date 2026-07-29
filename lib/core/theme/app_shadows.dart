// Shadow definitions for Dastra's elevated components
import 'package:flutter/material.dart';
class AppShadows {
  AppShadows._();

  /// Subtle, layered ambient elevation for cards
  static List<BoxShadow> cardShadow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: (isDark ? Colors.black : Colors.black12).withValues(alpha: isDark ? 0.2 : 0.02),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
      BoxShadow(
        color: (isDark ? Colors.black : Colors.black12).withValues(alpha: isDark ? 0.1 : 0.02),
        blurRadius: 16,
        offset: const Offset(0, 8),
      ),
    ];
  }

  /// Hover state - slightly stronger with a very faint tint of accent color
  static List<BoxShadow> cardHoverShadow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = Theme.of(context).colorScheme.primary;
    return [
      BoxShadow(
        color: accent.withValues(alpha: 0.08),
        blurRadius: 24,
        offset: const Offset(0, 8),
      ),
      BoxShadow(
        color: (isDark ? Colors.black : Colors.black12).withValues(alpha: isDark ? 0.3 : 0.05),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ];
  }

  /// Glow for icons in headers
  static List<BoxShadow> iconGlow(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.3),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  /// Deep shadow for dialogs and snackbars
  static List<BoxShadow> panelShadow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: (isDark ? Colors.black : Colors.black26).withValues(alpha: isDark ? 0.4 : 0.1),
        blurRadius: 32,
        offset: const Offset(0, 16),
      ),
    ];
  }
}
