import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';
import '../../core/utils/responsive.dart';

class AdaptiveEmptyState extends StatelessWidget {
  const AdaptiveEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final isMob = isMobile(context);
    final iconSize = isMob ? 48.0 : 64.0;
    final padding = isMob ? AppSpacing.xl : AppSpacing.xxl;

    return Padding(
      padding: EdgeInsets.all(padding),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: iconSize,
              color: context.colors.textMuted.withValues(alpha: 0.5),
            ),
            SizedBox(height: isMob ? AppSpacing.md : AppSpacing.lg),
            Text(
              title,
              style: isMob ? context.textStyles.h4 : context.textStyles.h3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              subtitle,
              style: isMob ? context.textStyles.bodySmall.copyWith(fontSize: 12) : context.textStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: isMob ? AppSpacing.lg : AppSpacing.xl),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.accentBlue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMob ? AppSpacing.lg : AppSpacing.xl,
                    vertical: isMob ? AppSpacing.sm : AppSpacing.md,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                child: Text(
                  actionLabel!,
                  style: isMob ? context.textStyles.labelMedium : context.textStyles.labelLarge,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
