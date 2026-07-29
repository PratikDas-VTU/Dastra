import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/theme.dart';
import '../utils/responsive.dart';

class DastraProfileCard extends StatefulWidget {
  const DastraProfileCard({
    super.key,
    required this.name,
    this.subtitle = 'Dastra Offline Workspace',
    this.onEdit,
    this.trailing,
  });

  final String? name;
  final String subtitle;
  final VoidCallback? onEdit;
  final Widget? trailing;

  @override
  State<DastraProfileCard> createState() => _DastraProfileCardState();
}

class _DastraProfileCardState extends State<DastraProfileCard> {
  bool _isHovered = false;

  String _getInitials(String? name) {
    if (name == null || name.trim().isEmpty) return 'U';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.trim()[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final displayName = (widget.name == null || widget.name!.trim().isEmpty)
        ? 'Workspace User'
        : widget.name!.trim();
    final initials = _getInitials(widget.name);

    Widget editButton = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.edit_outlined, size: 16, color: context.colors.textPrimary),
          const SizedBox(width: 6),
          Text(
            'Edit',
            style: context.typography.labelMedium.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
        ],
      ),
    );

    Widget content = Container(
      padding: EdgeInsets.all(context.spacing.xl),
      decoration: BoxDecoration(
        color: _isHovered && widget.onEdit != null
            ? context.colors.cardHover
            : context.colors.card,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: _isHovered && widget.onEdit != null
              ? context.colors.borderHover
              : context.colors.border,
        ),
        boxShadow: _isHovered && widget.onEdit != null
            ? AppShadows.cardHoverShadow(context)
            : AppShadows.cardShadow(context),
      ),
      child: Row(
        crossAxisAlignment: context.layout.isMobile ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: context.colors.accentGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: context.colors.accentBlue.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: context.typography.h2.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(width: context.spacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: context.spacing.sm,
                  runSpacing: 4,
                  children: [
                    Text(
                      displayName,
                      style: context.layout.isMobile ? context.typography.h3 : context.typography.h2,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: context.colors.accentBlue.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        border: Border.all(
                          color: context.colors.accentBlue.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        'LOCAL',
                        style: context.typography.labelSmall.copyWith(
                          color: context.colors.accentBlue,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  widget.subtitle,
                  style: context.typography.bodyMedium.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
                if (context.layout.isMobile && (widget.onEdit != null || widget.trailing != null)) ...[
                  SizedBox(height: context.spacing.md),
                  widget.trailing ?? editButton,
                ]
              ],
            ),
          ),
          if (!context.layout.isMobile && (widget.trailing != null || widget.onEdit != null)) ...[
            SizedBox(width: context.spacing.lg),
            widget.trailing ?? editButton,
          ],
        ],
      ),
    );

    if (widget.onEdit != null) {
      content = MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onEdit,
          behavior: HitTestBehavior.opaque,
          child: content,
        ),
      );
    }

    return content.animate().fadeIn(duration: AppAnimations.normal).slideY(begin: 0.05, end: 0);
  }
}
