import 'package:flutter/material.dart';
import '../theme/theme.dart';
import 'gradient_icon_box.dart';
import '../utils/responsive.dart';

class AdaptiveSectionHeader extends StatelessWidget {
  const AdaptiveSectionHeader({
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
    final isMob = isMobile(context);
    final iconSizeBox = isMob ? 28.0 : 36.0;
    final iconSize = isMob ? 16.0 : 18.0;

    return Row(
      children: [
        GradientIconBox(
          icon: icon,
          gradientColors: gradientColors,
          size: iconSizeBox,
          iconSize: iconSize,
          borderRadius: AppRadius.sm,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title, 
                style: isMob ? context.textStyles.h4 : context.textStyles.h3,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle != null)
                Text(
                  subtitle!, 
                  style: isMob ? context.textStyles.bodySmall.copyWith(fontSize: 12) : context.textStyles.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            style: TextButton.styleFrom(
              foregroundColor: context.colors.accentBlue,
              padding: isMob 
                ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4) 
                : const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
            child: Text(
              'See all', 
              style: isMob 
                  ? context.textStyles.labelMedium.copyWith(color: context.colors.accentBlue, fontSize: 12)
                  : context.textStyles.labelMedium.copyWith(color: context.colors.accentBlue)
            ),
          ),
      ],
    );
  }
}
