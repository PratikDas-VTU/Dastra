import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../utils/responsive.dart';

class DastraContentSection extends StatelessWidget {
  const DastraContentSection({
    super.key,
    this.title,
    this.subtitle,
    required this.child,
    this.trailing,
    this.padding,
  });

  final String? title;
  final String? subtitle;
  final Widget child;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.only(bottom: context.spacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null || subtitle != null || trailing != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: context.layout.isMobile ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (title != null)
                        Text(
                          title!,
                          style: context.layout.isMobile 
                            ? context.textStyles.h4.copyWith(color: context.colors.textPrimary)
                            : context.textStyles.h3.copyWith(color: context.colors.textPrimary),
                        ),
                      if (subtitle != null) ...[
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          subtitle!,
                          style: context.textStyles.bodyMedium.copyWith(
                            color: context.colors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null)
                  Padding(
                    padding: EdgeInsets.only(left: context.spacing.md),
                    child: trailing!,
                  ),
              ],
            ),
            SizedBox(height: context.spacing.md),
          ],
          child,
        ],
      ),
    );
  }
}
