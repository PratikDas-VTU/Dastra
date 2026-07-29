import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../controller/password_checker_controller.dart';

class PatternDetectionCard extends StatelessWidget {
  const PatternDetectionCard({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<PasswordCheckerController>();
    final analysis = ctrl.analysis;

    if (analysis.password.isEmpty) {
      return const SizedBox.shrink();
    }

    return DastraCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.pattern_rounded,
                size: 16,
                color: context.colors.textMuted,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Pattern Detection',
                style: context.textStyles.labelLarge,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Dictionary
          _PatternRow(
            isGood: analysis.hasNoDictionaryWords,
            goodText: 'No dictionary words',
            badText: 'Dictionary word detected',
          ),
          const SizedBox(height: AppSpacing.sm),
          
          // Keyboard
          _PatternRow(
            isGood: analysis.hasNoKeyboardPattern,
            goodText: 'No keyboard patterns',
            badText: 'Keyboard pattern detected',
          ),
          const SizedBox(height: AppSpacing.sm),
          
          // Sequential
          _PatternRow(
            isGood: analysis.hasNoSequentialCharacters,
            goodText: 'No sequential characters',
            badText: 'Sequential characters detected',
          ),
          const SizedBox(height: AppSpacing.sm),
          
          // Personal
          _PatternRow(
            isGood: !analysis.criticalWarnings.any((w) => w.contains('resembling dates')),
            goodText: 'No personal information',
            badText: 'Contains personal information',
          ),
          
          // Repeated
          _PatternRow(
            isGood: !analysis.recommendations.any((w) => w.contains('Avoid repeating')),
            goodText: 'No repeated characters',
            badText: 'Repeated characters detected',
          ),
        ],
      ),
    );
  }
}

class _PatternRow extends StatelessWidget {
  const _PatternRow({
    required this.isGood,
    required this.goodText,
    required this.badText,
  });

  final bool isGood;
  final String goodText;
  final String badText;

  @override
  Widget build(BuildContext context) {
    final icon = isGood ? Icons.check_circle_rounded : Icons.warning_rounded;
    final color = isGood ? context.colors.success : context.colors.accentOrange;
    final text = isGood ? goodText : badText;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: context.textStyles.bodyMedium.copyWith(
              color: isGood ? context.colors.textSecondary : context.colors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
