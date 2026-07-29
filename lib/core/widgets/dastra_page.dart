import 'package:flutter/material.dart';
import '../theme/theme.dart';
import 'dastra_responsive_container.dart';

class DastraPage extends StatelessWidget {
  const DastraPage({
    super.key,
    required this.child,
    required this.maxWidth,
    this.padding,
    this.scrollable = true,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final defaultPadding = EdgeInsets.symmetric(
      horizontal: AppMetrics.pagePadding(context),
      vertical: AppSpacing.xl,
    );

    Widget content = DastraResponsiveContainer(
      maxWidth: maxWidth,
      child: Padding(
        padding: padding ?? defaultPadding,
        child: child,
      ),
    );

    if (scrollable) {
      content = SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: content,
      );
    }

    return content;
  }
}
