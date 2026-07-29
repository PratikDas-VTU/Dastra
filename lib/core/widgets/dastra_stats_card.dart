import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../utils/responsive.dart';
import 'dastra_card.dart';

class DastraStatsCard extends StatelessWidget {
  const DastraStatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color = AppColors.accentBlue,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final size = Adaptive.of(context);
    final isCompact = size == ScreenSize.compact || size == ScreenSize.largePhone;

    return DastraCard(
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isCompact ? AppSpacing.sm : AppSpacing.md),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              icon,
              size: isCompact ? 22 : 28,
              color: color,
            ),
          ),
          SizedBox(width: isCompact ? AppSpacing.md : AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: isCompact ? context.textStyles.caption : context.textStyles.bodySmall,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  value,
                  style: isCompact ? context.textStyles.h3 : context.textStyles.h2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
