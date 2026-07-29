// Visual strength indicator: segmented bar, entropy display, crack time.
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../controller/password_generator_controller.dart';
import '../utils/password_utils.dart';

/// Card that shows password strength, entropy bits, and estimated crack time.
class StrengthIndicatorCard extends StatelessWidget {
  const StrengthIndicatorCard({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<PasswordGeneratorController>();
    final strength = ctrl.strength;
    final entropy = ctrl.entropy;
    final crackTime = ctrl.crackTime;
    final charLen = ctrl.charsetLength;

    return DastraCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Row: label + strength name
          Row(
            children: [
              Icon(Icons.shield_rounded, size: 16, color: context.colors.textMuted),
              const SizedBox(width: AppSpacing.xs),
              Text('Strength', style: context.textStyles.labelLarge),
              const Spacer(),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  strength.label,
                  key: ValueKey(strength),
                  style: context.textStyles.labelLarge.copyWith(color: strength.color),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // ── Segmented strength bar (5 segments)
          _StrengthBar(strength: strength),

          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.md),

          // ── Stats grid
          Row(
            children: [
              _StatChip(
                icon: Icons.functions_rounded,
                label: 'Entropy',
                value: '${entropy.toStringAsFixed(1)} bits',
                color: context.colors.accentBlue,
              ),
              const SizedBox(width: AppSpacing.sm),
              _StatChip(
                icon: Icons.abc_rounded,
                label: 'Charset',
                value: '$charLen chars',
                color: context.colors.accentCyan,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),

          // ── Crack time row
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: context.colors.border),
            ),
            child: Row(
              children: [
                Icon(Icons.timer_outlined, size: 14, color: context.colors.textMuted),
                const SizedBox(width: AppSpacing.xs),
                Text('Est. crack time: ', style: context.textStyles.caption),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    child: Text(
                      crackTime,
                      key: ValueKey(crackTime),
                      style: context.textStyles.labelSmall.copyWith(
                        color: strength.color,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.04, end: 0);
  }
}

// ── Segmented bar ──────────────────────────────────────────────────────────

class _StrengthBar extends StatelessWidget {
  const _StrengthBar({required this.strength});
  final StrengthLevel strength;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (i) {
        final filled = i <= strength.index;
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
            height: 5,
            margin: EdgeInsets.only(right: i < 4 ? 4 : 0),
            decoration: BoxDecoration(
              color: filled ? strength.color : context.colors.border,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
          ),
        );
      }),
    );
  }
}

// ── Small stat chip ────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: context.colors.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: context.textStyles.caption),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    value,
                    key: ValueKey(value),
                    style: context.textStyles.labelMedium.copyWith(color: context.colors.textPrimary),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
