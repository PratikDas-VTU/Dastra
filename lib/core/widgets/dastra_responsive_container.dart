import 'package:flutter/material.dart';

class DastraResponsiveContainer extends StatelessWidget {
  const DastraResponsiveContainer({
    super.key,
    required this.child,
    required this.maxWidth,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
