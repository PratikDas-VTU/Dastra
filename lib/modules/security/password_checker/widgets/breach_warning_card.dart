// Displays active warnings/vulnerabilities (e.g. repeated chars, date patterns).
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../controller/password_checker_controller.dart';

class BreachWarningCard extends StatelessWidget {
  const BreachWarningCard({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<PasswordCheckerController>();
    final criticalWarnings = ctrl.analysis.criticalWarnings;

    if (criticalWarnings.isEmpty) {
      return const SizedBox.shrink();
    }

    return DastraCard(
      backgroundColor: context.colors.error.withValues(alpha: 0.06),
      borderColor: context.colors.error.withValues(alpha: 0.3),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 16,
                color: context.colors.error,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Security Warnings',
                style: context.textStyles.labelLarge.copyWith(
                  color: context.colors.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Warnings list
          ...criticalWarnings.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Icon(
                      Icons.arrow_right_rounded,
                      size: 14,
                      color: context.colors.error,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      item,
                      style: context.textStyles.bodySmall.copyWith(
                        color: context.colors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
