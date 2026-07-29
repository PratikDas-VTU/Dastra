import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/theme.dart';
import '../utils/responsive.dart';

class DastraSettingTile extends StatefulWidget {
  const DastraSettingTile({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.trailing,
    this.onTap,
    this.iconColor,
    this.isDestructive = false,
  });

  final String title;
  final String description;
  final IconData icon;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;
  final bool isDestructive;

  @override
  State<DastraSettingTile> createState() => _DastraSettingTileState();
}

class _DastraSettingTileState extends State<DastraSettingTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final interactive = widget.onTap != null;
    final primaryColor = widget.isDestructive
        ? context.colors.error
        : (widget.iconColor ?? context.colors.accentBlue);

    Widget content = Container(
      padding: EdgeInsets.all(context.spacing.lg),
      decoration: BoxDecoration(
        color: _isHovered && interactive ? context.colors.cardHover : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: _isHovered && interactive ? context.colors.borderHover : Colors.transparent,
        ),
      ),
      child: Row(
        crossAxisAlignment: context.layout.isMobile ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              widget.icon,
              size: 22,
              color: primaryColor,
            ),
          ),
          SizedBox(width: context.spacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: context.typography.titleLarge.copyWith(
                    color: widget.isDestructive ? context.colors.error : context.colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.description,
                  style: context.typography.bodyMedium.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
                if (context.layout.isMobile && widget.trailing != null) ...[
                  SizedBox(height: context.spacing.md),
                  widget.trailing!,
                ]
              ],
            ),
          ),
          if (!context.layout.isMobile && widget.trailing != null) ...[
            SizedBox(width: context.spacing.lg),
            widget.trailing!,
          ] else if (interactive) ...[
            SizedBox(width: context.spacing.lg),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: _isHovered ? context.colors.textPrimary : context.colors.textMuted,
            ),
          ],
        ],
      ),
    );

    if (interactive) {
      content = MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: content,
        ),
      );
    }

    if (interactive) {
      return content.animate(target: _isHovered ? 1 : 0).scale(
        end: const Offset(1.01, 1.01),
        duration: AppAnimations.fast,
        curve: AppAnimations.standard,
      );
    }

    return content;
  }
}
