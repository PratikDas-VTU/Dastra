import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../core/utils/responsive.dart';
import '../controller/workspace_controller.dart';

class WorkspaceStatsCards extends StatelessWidget {
  const WorkspaceStatsCards({super.key, required this.controller});
  final WorkspaceController controller;

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    int i = 0;
    double d = bytes.toDouble();
    while (d > 1024 && i < suffixes.length - 1) {
      d /= 1024;
      i++;
    }
    return '${d.toStringAsFixed(1)} ${suffixes[i]}';
  }

  @override
  Widget build(BuildContext context) {
    int crossAxisCount = 4;
    double childAspectRatio = 2.5;

    if (context.layout.isMobile) {
      crossAxisCount = 1; // Fallback to 1 column on extremely narrow mobile, or 2 if space permits
      childAspectRatio = 2.0; 
    } else if (context.layout.isTablet) {
      crossAxisCount = 2;
      childAspectRatio = 2.2;
    }

    // A better approach for mobile is often Wrap or grid with dynamic count
    // Since GridView.count with 1 column is just a list, we'll use 1 or 2
    if (context.layout.isMobile) {
      // Let's use 2 columns on largePhone, 1 on compact
      crossAxisCount = context.layout.isCompact ? 1 : 2;
      childAspectRatio = context.layout.isCompact ? 3.0 : 1.8;
    }

    return GridView.count(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: context.spacing.md,
      mainAxisSpacing: context.spacing.md,
      childAspectRatio: childAspectRatio,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _StatCard(
          title: 'Total Conversions',
          value: controller.totalConversions.toString(),
          icon: Icons.check_circle_outline_rounded,
          color: context.colors.accentBlue,
        ),
        _StatCard(
          title: 'Storage Used',
          value: _formatBytes(controller.storageUsed),
          icon: Icons.storage_rounded,
          color: context.colors.accentPurple,
        ),
        _StatCard(
          title: 'Today',
          value: controller.todayConversions.toString(),
          icon: Icons.today_rounded,
          color: context.colors.success,
        ),
        _StatCard(
          title: 'Most Used Tool',
          value: controller.mostUsedTool,
          icon: Icons.auto_awesome_rounded,
          color: context.colors.accentOrange,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DastraCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: context.textStyles.labelMedium.copyWith(color: context.colors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  value,
                  style: context.textStyles.h4,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
