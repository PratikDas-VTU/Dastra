import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../utils/app_constants.dart';
import '../utils/responsive.dart';

class AdaptiveAppHeader extends StatelessWidget {
  const AdaptiveAppHeader({
    super.key,
    this.title,
    this.subtitle,
    this.icon,
    this.gradientColors,
    this.actions,
    this.showGlobalBranding = false,
  });

  final String? title;
  final String? subtitle;
  final IconData? icon;
  final List<Color>? gradientColors;
  final List<Widget>? actions;
  
  /// If true, forces the display of the Dastra logo and branding.
  final bool showGlobalBranding;

  @override
  Widget build(BuildContext context) {
    if (isMobile(context)) {
      return _buildCompactHeader(context);
    } else if (isTablet(context)) {
      return _buildMediumHeader(context);
    } else {
      return _buildLargeHeader(context);
    }
  }

  Widget _buildCompactHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showGlobalBranding) ...[
            _buildGlobalBranding(context, isCompact: true),
            const SizedBox(height: AppSpacing.md),
          ],
          if (title != null)
            Row(
              children: [
                if (icon != null) ...[
                  _buildIconBox(size: 28, iconSize: 16),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title!,
                        style: context.textStyles.h4,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: context.textStyles.bodySmall.copyWith(fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          if (actions != null && actions!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: actions!,
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildMediumHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showGlobalBranding) ...[
            _buildGlobalBranding(context, isCompact: false),
            const SizedBox(height: AppSpacing.lg),
          ],
          if (title != null)
            Row(
              children: [
                if (icon != null) ...[
                  _buildIconBox(size: 36, iconSize: 20),
                  const SizedBox(width: AppSpacing.md),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title!,
                        style: context.textStyles.h3,
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: context.textStyles.bodyMedium,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          if (actions != null && actions!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: actions!,
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildLargeHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showGlobalBranding) ...[
            Expanded(
              flex: 1,
              child: _buildGlobalBranding(context, isCompact: false),
            ),
            const SizedBox(width: AppSpacing.xxl),
          ],
          if (title != null)
            Expanded(
              flex: 2,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (icon != null) ...[
                    _buildIconBox(size: 48, iconSize: 24),
                    const SizedBox(width: AppSpacing.md),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title!,
                          style: context.textStyles.h2,
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            subtitle!,
                            style: context.textStyles.bodyLarge,
                          ),
                        ]
                      ],
                    ),
                  ),
                ],
              ),
            ),
          if (actions != null && actions!.isNotEmpty) ...[
            const SizedBox(width: AppSpacing.xxl),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: actions!,
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildGlobalBranding(BuildContext context, {required bool isCompact}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: isCompact ? 32 : 48,
          height: isCompact ? 32 : 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentBlue.withValues(alpha: 0.3),
                blurRadius: isCompact ? 10 : 15,
                offset: Offset(0, isCompact ? 2 : 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.asset(
            AppConstants.logoPath,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: AppColors.accentGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Icon(
                Icons.bolt_rounded,
                color: Colors.white,
                size: isCompact ? 20 : 28,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppConstants.appName,
                style: isCompact ? context.textStyles.h3 : context.textStyles.h2,
              ),
              Text(
                AppConstants.appSubtitle,
                style: isCompact
                    ? context.textStyles.bodySmall.copyWith(fontSize: 12)
                    : context.textStyles.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIconBox({required double size, required double iconSize}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors ?? [AppColors.surface, AppColors.border],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Icon(
        icon,
        size: iconSize,
        color: Colors.white,
      ),
    );
  }
}
