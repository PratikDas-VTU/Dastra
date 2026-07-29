import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';

enum WorkspaceEmptyStateType { recent, history, favorites, search }

class WorkspaceEmptyState extends StatelessWidget {
  const WorkspaceEmptyState({
    super.key,
    this.type = WorkspaceEmptyStateType.history,
  });

  final WorkspaceEmptyStateType type;

  @override
  Widget build(BuildContext context) {
    IconData icon;
    String title;
    String description;
    String? primaryActionText;
    VoidCallback? onPrimaryAction;

    switch (type) {
      case WorkspaceEmptyStateType.recent:
        icon = Icons.history_toggle_off_rounded;
        title = 'No Recent Activity';
        description = 'Your recent conversions will appear here.';
        primaryActionText = 'Convert a File';
        onPrimaryAction = () => context.go('/');
        break;
      case WorkspaceEmptyStateType.history:
        icon = Icons.dashboard_customize_rounded;
        title = 'Workspace is Empty';
        description = 'Generated outputs and conversion history will appear here.';
        primaryActionText = 'Explore Tools';
        onPrimaryAction = () => context.go('/');
        break;
      case WorkspaceEmptyStateType.favorites:
        icon = Icons.favorite_border_rounded;
        title = 'No Favorites Yet';
        description = 'Star your most important outputs to pin them here.';
        break;
      case WorkspaceEmptyStateType.search:
        icon = Icons.search_off_rounded;
        title = 'No Results Found';
        description = 'Try adjusting your search query or filters.';
        break;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: context.colors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: context.colors.borderSubtle),
              ),
              child: Icon(
                icon,
                size: 40,
                color: context.colors.textMuted,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              title,
              style: context.typography.h3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              description,
              style: context.typography.bodyLarge,
              textAlign: TextAlign.center,
            ),
            if (primaryActionText != null && onPrimaryAction != null) ...[
              const SizedBox(height: AppSpacing.xl),
              DastraButton(
                label: primaryActionText,
                onTap: onPrimaryAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
