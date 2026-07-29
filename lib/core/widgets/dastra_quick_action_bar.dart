import 'package:flutter/material.dart';
import '../theme/theme.dart';
import 'dastra_card.dart';
import '../utils/responsive.dart';

class DastraQuickActionItem {
  const DastraQuickActionItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String title;
  final Color? color;
  final VoidCallback onTap;
}

class DastraQuickActionBar extends StatelessWidget {
  const DastraQuickActionBar({
    super.key,
    required this.actions,
  });

  final List<DastraQuickActionItem> actions;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: actions.map((a) => DastraQuickActionButton(item: a)).toList(),
    );
  }
}

class DastraQuickActionButton extends StatelessWidget {
  const DastraQuickActionButton({super.key, required this.item});

  final DastraQuickActionItem item;

  @override
  Widget build(BuildContext context) {
    final size = Adaptive.of(context);
    final isCompact = size == ScreenSize.compact || size == ScreenSize.largePhone;
    
    return DastraCard(
      onTap: item.onTap,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: isCompact ? AppSpacing.sm : AppSpacing.md,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(item.icon, size: 20, color: item.color ?? context.colors.textPrimary),
          const SizedBox(width: AppSpacing.sm),
          Text(
            item.title,
            style: context.textStyles.button.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
