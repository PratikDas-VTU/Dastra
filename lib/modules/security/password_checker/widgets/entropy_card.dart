// Detailed stats containing entropy (bits), crack time, pool size, brute-force attempts.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../controller/password_checker_controller.dart';

class EntropyCard extends StatelessWidget {
  const EntropyCard({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<PasswordCheckerController>();
    final analysis = ctrl.analysis;

    return DastraCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                size: 16,
                color: context.colors.textMuted,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text('Strength Metrics', style: context.textStyles.labelLarge),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Grid of stats
          _MetricRow(
            icon: Icons.functions_rounded,
            label: 'Entropy Strength',
            value: '${analysis.entropy.toStringAsFixed(1)} bits',
            color: context.colors.accentBlue,
            tooltip: 'Entropy measures the randomness of a password. Higher entropy generally means greater resistance to guessing and brute-force attacks.',
          ),
          const Divider(height: 16),
          _MetricRow(
            icon: Icons.abc_rounded,
            label: 'Character Pool Size',
            value: '${analysis.charsetSize} characters',
            color: context.colors.accentCyan,
          ),
          const Divider(height: 16),
          _MetricRow(
            icon: Icons.timer_outlined,
            label: 'Est. Crack Time',
            value: analysis.crackTime,
            color: analysis.strength.color,
          ),
          const Divider(height: 16),
          _MetricRow(
            icon: Icons.fingerprint_rounded,
            label: 'Brute-force Attempts',
            value: analysis.bruteForceAttempts,
            color: context.colors.accentOrange,
          ),
        ],
      ),
    );
  }
}
class _MetricRow extends StatelessWidget {
  const _MetricRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.tooltip,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: AppSpacing.sm),
        Text(
          label,
          style: context.textStyles.bodyMedium.copyWith(color: context.colors.textSecondary),
        ),
        if (tooltip != null) ...[
          const SizedBox(width: AppSpacing.xs),
          Tooltip(
            message: tooltip,
            preferBelow: false,
            triggerMode: TooltipTriggerMode.tap,
            child: Icon(
              Icons.info_outline_rounded,
              size: 14,
              color: context.colors.textMuted,
            ),
          ),
        ],
        const Spacer(),
        Text(
          value,
          style: context.textStyles.labelLarge.copyWith(
            color: context.colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
