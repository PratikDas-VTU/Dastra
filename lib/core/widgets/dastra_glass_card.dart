import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/theme.dart';

class DastraGlassCard extends StatelessWidget {
  const DastraGlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.borderColor,
    this.backgroundColor,
    this.blur = 12.0,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Color? borderColor;
  final Color? backgroundColor;
  final double blur;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(AppRadius.lg);
    final bg = backgroundColor ?? context.colors.glassBg;
    final stroke = borderColor ?? context.colors.glassStroke;

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: radius,
            border: Border.all(color: stroke),
          ),
          child: child,
        ),
      ),
    );
  }
}
