import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../utils/responsive.dart';

class DastraHeroCard extends StatelessWidget {
  const DastraHeroCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    this.actionWidget,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final Widget? actionWidget;

  @override
  Widget build(BuildContext context) {
    final isCompact = context.layout.isMobile;

    final padding = isCompact ? context.spacing.lg : context.spacing.xl;
    final titleStyle = isCompact ? context.typography.sectionTitle : context.typography.pageTitle;
    final subtitleStyle = isCompact ? context.textStyles.bodyLarge : context.textStyles.h4;
    final iconSize = isCompact ? 22.0 : 28.0;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        gradient: LinearGradient(
          colors: [
            context.colors.cardHover,
            context.colors.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: context.colors.border),
        boxShadow: AppShadows.cardShadow(context),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(isCompact ? AppSpacing.sm : AppSpacing.md),
                    decoration: BoxDecoration(
                      color: gradient.first.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(
                      icon,
                      size: iconSize,
                      color: gradient.first,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: titleStyle.copyWith(
                            color: context.colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          subtitle,
                          style: subtitleStyle.copyWith(
                            color: context.colors.textSecondary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (actionWidget != null) ...[
                SizedBox(height: isCompact ? AppSpacing.md : AppSpacing.lg),
                actionWidget!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
