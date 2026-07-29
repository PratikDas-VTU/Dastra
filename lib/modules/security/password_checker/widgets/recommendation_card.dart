// Displays dynamic recommendations to improve password strength.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../controller/password_checker_controller.dart';

class RecommendationCard extends StatelessWidget {
  const RecommendationCard({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<PasswordCheckerController>();
    final analysis = ctrl.analysis;

    if (analysis.criticalWarnings.isEmpty &&
        analysis.recommendations.isEmpty &&
        analysis.goodPractices.isEmpty) {
      return const SizedBox.shrink();
    }

    return DastraCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.security_rounded,
                size: 16,
                color: context.colors.accentBlue,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Security Advisor',
                style: context.textStyles.labelLarge.copyWith(
                  color: context.colors.accentBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          if (analysis.criticalWarnings.isNotEmpty) ...[
            _CategorySection(
              title: 'Critical',
              items: analysis.criticalWarnings,
              icon: Icons.dangerous_rounded,
              color: context.colors.accentOrange,
            ),
            const SizedBox(height: AppSpacing.sm),
          ],

          if (analysis.recommendations.isNotEmpty) ...[
            _CategorySection(
              title: 'Recommended',
              items: analysis.recommendations,
              icon: Icons.warning_amber_rounded,
              color: context.colors.accentCyan, // Can also use yellow/orange
            ),
            const SizedBox(height: AppSpacing.sm),
          ],

          if (analysis.goodPractices.isNotEmpty) ...[
            _CategorySection(
              title: 'Good Practices',
              items: analysis.goodPractices,
              icon: Icons.check_circle_outline_rounded,
              color: context.colors.success,
            ),
          ],
        ],
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.title,
    required this.items,
    required this.icon,
    required this.color,
  });

  final String title;
  final List<String> items;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: AppSpacing.xs),
            Text(
              title,
              style: context.textStyles.labelMedium.copyWith(color: color),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        ...items.map((item) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Icon(
                    Icons.circle,
                    size: 4,
                    color: context.colors.textMuted,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item,
                    style: context.textStyles.bodySmall.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
