import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/theme.dart';
import 'dastra_button.dart';

class DastraEmptyState extends StatelessWidget {
  const DastraEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_rounded,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              decoration: BoxDecoration(
                color: context.colors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: context.colors.border),
                boxShadow: AppShadows.cardShadow(context),
              ),
              child: Icon(
                icon,
                size: 48,
                color: context.colors.textMuted,
              ),
            ).animate().scaleXY(begin: 0.8, end: 1.0, duration: AppAnimations.normal).fadeIn(),
            const SizedBox(height: AppSpacing.xl),
            Text(
              title,
              style: context.typography.h2,
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),
            const SizedBox(height: AppSpacing.sm),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Text(
                message,
                style: context.typography.bodyMedium.copyWith(
                  color: context.colors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.1, end: 0),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.xxl),
              DastraButton(
                label: actionLabel!,
                onTap: onAction,
                icon: Icons.add_rounded,
              ).animate().fadeIn(delay: 200.ms).scaleXY(begin: 0.95, end: 1.0),
            ],
          ],
        ),
      ),
    );
  }
}
