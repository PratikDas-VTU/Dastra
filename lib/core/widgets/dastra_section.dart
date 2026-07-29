import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../utils/responsive.dart';
import 'dastra_button.dart';

class DastraSection extends StatelessWidget {
  const DastraSection({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: context.layout.isMobile ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: context.layout.isMobile ? context.textStyles.h4 : context.typography.h3),
                  if (subtitle != null) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      subtitle!,
                      style: context.typography.bodyMedium.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (actionLabel != null && onAction != null)
              DastraButton(
                label: actionLabel!,
                onTap: onAction,
                type: DastraButtonType.ghost,
              ),
          ],
        ),
        SizedBox(height: context.spacing.md),
        child,
      ],
    );
  }
}
