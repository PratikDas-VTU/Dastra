import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../utils/responsive.dart';
import 'adaptive_app_header.dart';

class AdaptiveScaffold extends StatelessWidget {
  const AdaptiveScaffold({
    super.key,
    this.title,
    this.subtitle,
    this.icon,
    this.gradientColors,
    required this.body,
    this.bottomActions,
    this.actions,
    this.showGlobalBranding = false,
    this.backgroundColor,
    this.onBackPressed,
  });

  final String? title;
  final String? subtitle;
  final IconData? icon;
  final List<Color>? gradientColors;
  final Widget body;
  final Widget? bottomActions;
  final List<Widget>? actions;
  final bool showGlobalBranding;
  final Color? backgroundColor;
  final VoidCallback? onBackPressed;

  @override
  Widget build(BuildContext context) {
    final isCompact = Adaptive.isCompact(context) || Adaptive.isLargePhone(context);

    return Scaffold(
      backgroundColor: backgroundColor ?? context.colors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            if (title != null || showGlobalBranding)
              Row(
                children: [
                  if (onBackPressed != null)
                    Padding(
                      padding: const EdgeInsets.only(left: AppSpacing.md, top: AppSpacing.md),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_rounded),
                        color: context.colors.textPrimary,
                        onPressed: onBackPressed,
                        tooltip: 'Back',
                      ),
                    ),
                  Expanded(
                    child: AdaptiveAppHeader(
                      title: title,
                      subtitle: subtitle,
                      icon: icon,
                      gradientColors: gradientColors,
                      actions: actions,
                      showGlobalBranding: showGlobalBranding,
                    ),
                  ),
                ],
              ),
            
            // ── Divider ──
            if ((title != null || showGlobalBranding) && isCompact)
              Container(
                height: 1,
                color: context.colors.border,
              ),

            // ── Body ──
            Expanded(
              child: body,
            ),

            // ── Bottom Actions ──
            if (bottomActions != null) ...[
              if (isCompact)
                Container(
                  height: 1,
                  color: context.colors.border,
                ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(AppMetrics.pagePadding(context)),
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  boxShadow: [
                    if (!isCompact)
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                  ],
                ),
                child: bottomActions!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
