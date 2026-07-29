import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/theme.dart';
import '../controller/password_checker_controller.dart';
import '../model/password_analysis.dart';
import '../../password_generator/controller/password_generator_controller.dart';
import '../../password_generator/model/password_settings.dart';

class StrengthMeter extends StatelessWidget {
  const StrengthMeter({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<PasswordCheckerController>();
    final analysis = ctrl.analysis;
    final level = analysis.strength;
    final score = analysis.score;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.colors.border),
        boxShadow: AppShadows.cardShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_rounded,
                size: 16,
                color: context.colors.textMuted,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text('Security Score', style: context.textStyles.labelLarge),
              const Spacer(),
              // Animated level text
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  level.label,
                  key: ValueKey(level),
                  style: context.textStyles.h4.copyWith(
                    color: level.color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Large Score display with dial design
          Center(
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer score ring track
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(
                        value: 1.0,
                        strokeWidth: 6,
                        backgroundColor: context.colors.surface,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          context.colors.border,
                        ),
                      ),
                    ),
                    // Active score ring progress
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: score / 100.0),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, _) {
                          return CircularProgressIndicator(
                            value: value,
                            strokeWidth: 8,
                            backgroundColor: Colors.transparent,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              level.color,
                            ),
                          );
                        },
                      ),
                    ),
                    // Score Text
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: score.toDouble()),
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, _) {
                            return Text(
                              value.toStringAsFixed(0),
                              style: context.textStyles.displayLarge.copyWith(
                                color: level.color,
                                height: 1.1,
                              ),
                            );
                          },
                        ),
                        Text(
                          '/100',
                          style: context.textStyles.caption.copyWith(
                            color: context.colors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Linear Strength Bar helper
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: score / 100.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 6,
                  backgroundColor: context.colors.surface,
                  valueColor: AlwaysStoppedAnimation<Color>(level.color),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          
          Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                level.description,
                key: ValueKey(level.description),
                style: context.textStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          
          if ((level == PasswordStrengthLevel.weak || level == PasswordStrengthLevel.veryWeak) && analysis.password.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Center(
              child: TextButton(
                onPressed: () {
                  // Navigate to generator and set mode to Improve with this password
                  final pwd = analysis.password;
                  context.read<PasswordGeneratorController>()
                    ..setMode(GenerationMode.improve)
                    ..setExistingPasswordToImprove(pwd);
                  context.go('/security/password-generator');
                },
                style: TextButton.styleFrom(
                  foregroundColor: context.colors.accentBlue,
                  textStyle: context.textStyles.button,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Improve this password'),
                    SizedBox(width: AppSpacing.xs),
                    Icon(Icons.arrow_forward_rounded, size: 16),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.04, end: 0);
  }
}
