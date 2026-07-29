// Card for selecting how many passwords to generate at once.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../controller/password_generator_controller.dart';

/// Lets the user pick a count from 1–20 using a slider.
class CountSelectorCard extends StatelessWidget {
  const CountSelectorCard({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<PasswordGeneratorController>();
    final count = ctrl.settings.count;

    return DastraCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header
          Row(
            children: [
              Icon(
                Icons.format_list_numbered_rounded,
                size: 16,
                color: context.colors.textMuted,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text('Generate', style: context.textStyles.labelLarge),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: context.colors.accentBlue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(
                    color: context.colors.accentBlue.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  '$count password${count == 1 ? '' : 's'}',
                  style: context.textStyles.labelMedium.copyWith(
                    color: context.colors.accentBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // ── Count chips (1–20)
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: List.generate(20, (i) {
              final n = i + 1;
              final selected = n == count;
              return GestureDetector(
                onTap: () => ctrl.setCount(n),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 36,
                  height: 32,
                  decoration: BoxDecoration(
                    color: selected
                        ? context.colors.accentBlue.withValues(alpha: 0.2)
                        : context.colors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(
                      color: selected
                          ? context.colors.accentBlue
                          : context.colors.border,
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$n',
                    style: context.textStyles.labelMedium.copyWith(
                      color: selected
                          ? context.colors.accentBlue
                          : context.colors.textSecondary,
                      fontWeight:
                          selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
