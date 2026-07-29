import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/widgets.dart';

class WorkspaceQuickAction {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const WorkspaceQuickAction({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });
}

class WorkspaceQuickActions extends StatelessWidget {
  final List<WorkspaceQuickAction> actions;

  const WorkspaceQuickActions({
    super.key,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: context.typography.sectionTitle,
        ),
        SizedBox(height: context.spacing.md),
        DastraQuickActionBar(
          actions: actions.map((a) => DastraQuickActionItem(
            icon: a.icon,
            title: a.title,
            color: a.color,
            onTap: a.onTap,
          )).toList(),
        ),
      ],
    );
  }
}
