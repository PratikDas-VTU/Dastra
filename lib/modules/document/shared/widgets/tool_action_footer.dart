import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/widgets.dart';

class ToolActionFooter extends StatelessWidget {
  const ToolActionFooter({
    super.key,
    required this.onPressed,
    required this.isProcessing,
    required this.icon,
    required this.label,
    required this.processingLabel,
    this.gradient,
  });

  final VoidCallback? onPressed;
  final bool isProcessing;
  final IconData icon;
  final String label;
  final String processingLabel;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.spacing.lg),
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(top: BorderSide(color: context.colors.border)),
      ),
      child: DastraButton(
        onTap: onPressed,
        isLoading: isProcessing,
        icon: icon,
        label: isProcessing ? processingLabel : label,
        isFullWidth: true,
        type: DastraButtonType.primary,
      ),
    );
  }
}
