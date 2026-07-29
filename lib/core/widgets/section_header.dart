// Section header: category title + optional "See all" link
import 'package:flutter/material.dart';
import '../theme/theme.dart';
import 'gradient_icon_box.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    required this.icon,
    required this.gradientColors,
    this.subtitle,
    this.onSeeAll,
  });

  final String title;
  final IconData icon;
  final List<Color> gradientColors;
  final String? subtitle;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GradientIconBox(
          icon: icon,
          gradientColors: gradientColors,
          size: 36,
          iconSize: 18,
          borderRadius: AppRadius.sm,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: context.textStyles.h3),
              if (subtitle != null)
                Text(subtitle!, style: context.textStyles.bodySmall),
            ],
          ),
        ),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            style: TextButton.styleFrom(
              foregroundColor: context.colors.accentBlue,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
            child: Text('See all', style: context.textStyles.labelMedium.copyWith(
              color: context.colors.accentBlue,
            )),
          ),
      ],
    );
  }
}
