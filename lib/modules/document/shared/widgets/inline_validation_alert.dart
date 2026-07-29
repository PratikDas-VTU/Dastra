import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class InlineValidationAlert extends StatelessWidget {
  final String message;
  final IconData icon;

  const InlineValidationAlert({
    super.key,
    required this.message,
    this.icon = Icons.info_outline_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: context.colors.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: context.colors.warning, size: 20),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              message,
              style: context.textStyles.bodyMedium.copyWith(color: context.colors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
