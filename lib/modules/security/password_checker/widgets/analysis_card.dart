// Security checklist showing visual indicators for each requirement.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../controller/password_checker_controller.dart';

class AnalysisCard extends StatelessWidget {
  const AnalysisCard({super.key});

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
                Icons.check_circle_outline_rounded,
                size: 16,
                color: context.colors.textMuted,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text('Security Checklist', style: context.textStyles.labelLarge),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Checklist Grid
          _ChecklistItem(
            label: 'Uppercase Letters (A–Z)',
            isChecked: analysis.hasUppercase,
          ),
          const Divider(height: 12, indent: 32),
          _ChecklistItem(
            label: 'Lowercase Letters (a–z)',
            isChecked: analysis.hasLowercase,
          ),
          const Divider(height: 12, indent: 32),
          _ChecklistItem(
            label: 'Numeric Digits (0–9)',
            isChecked: analysis.hasNumbers,
          ),
          const Divider(height: 12, indent: 32),
          _ChecklistItem(
            label: 'Symbol Characters (!, @, #, etc.)',
            isChecked: analysis.hasSymbols,
          ),
          const Divider(height: 12, indent: 32),
          _ChecklistItem(
            label: 'Strong Length (12+ characters)',
            isChecked: analysis.hasGoodLength,
          ),
          const Divider(height: 12, indent: 32),
          _ChecklistItem(
            label: 'Not in Common Password Dictionary',
            isChecked: analysis.hasNoDictionaryWords,
          ),
          const Divider(height: 12, indent: 32),
          _ChecklistItem(
            label: 'No Sequential Keyboard Patterns',
            isChecked: analysis.hasNoKeyboardPattern,
          ),
          const Divider(height: 12, indent: 32),
          _ChecklistItem(
            label: 'No Sequential Characters (abc, 123)',
            isChecked: analysis.hasNoSequentialCharacters,
          ),
        ],
      ),
    );
  }
}

class _ChecklistItem extends StatelessWidget {
  const _ChecklistItem({required this.label, required this.isChecked});

  final String label;
  final bool isChecked;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isChecked
                ? context.colors.success.withValues(alpha: 0.15)
                : context.colors.error.withValues(alpha: 0.1),
            border: Border.all(
              color: isChecked ? context.colors.success : context.colors.error.withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          child: Icon(
            isChecked ? Icons.check_rounded : Icons.close_rounded,
            size: 12,
            color: isChecked ? context.colors.success : context.colors.error,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            label,
            style: context.textStyles.bodyMedium.copyWith(
              color: isChecked ? context.colors.textPrimary : context.colors.textSecondary,
              fontWeight: isChecked ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
