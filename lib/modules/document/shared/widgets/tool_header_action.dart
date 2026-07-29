import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class ToolHeaderAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  const ToolHeaderAction({
    super.key,
    required this.label,
    required this.icon,
    this.onPressed,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final button = OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      style: OutlinedButton.styleFrom(
        foregroundColor: context.colors.accentBlue,
        side: BorderSide(color: context.colors.accentBlue.withValues(alpha: 0.5)),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      ),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: tooltip != null ? Tooltip(message: tooltip!, child: button) : button,
    );
  }
}
