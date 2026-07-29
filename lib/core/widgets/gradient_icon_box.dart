// A rounded container with a gradient background that holds an icon.
// Used for tool cards and category headers.
import 'package:flutter/material.dart';
import '../theme/theme.dart';

class GradientIconBox extends StatelessWidget {
  const GradientIconBox({
    super.key,
    required this.icon,
    required this.gradientColors,
    this.size = 48.0,
    this.iconSize = 24.0,
    this.borderRadius,
  });

  final IconData icon;
  final List<Color> gradientColors;
  final double size;
  final double iconSize;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppRadius.md;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: AppShadows.iconGlow(gradientColors.first),
      ),
      child: Icon(
        icon,
        size: iconSize,
        color: Colors.white,
      ),
    );
  }
}
