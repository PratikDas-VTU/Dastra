import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/theme.dart';

enum DastraButtonType { primary, secondary, ghost, destructive }

class DastraButton extends StatefulWidget {
  const DastraButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.type = DastraButtonType.primary,
    this.isLoading = false,
    this.isFullWidth = false,
    this.backgroundColor,
    this.textColor,
  });

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final DastraButtonType type;
  final bool isLoading;
  final bool isFullWidth;
  final Color? backgroundColor;
  final Color? textColor;

  @override
  State<DastraButton> createState() => _DastraButtonState();
}

class _DastraButtonState extends State<DastraButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  Color _getBackgroundColor(BuildContext context) {
    if (widget.backgroundColor != null && widget.onTap != null) {
      return _isHovered ? widget.backgroundColor!.withValues(alpha: 0.9) : widget.backgroundColor!;
    }
    if (widget.onTap == null) return context.colors.surface;
    switch (widget.type) {
      case DastraButtonType.primary:
        return _isHovered ? context.colors.accentBlue.withValues(alpha: 0.9) : context.colors.accentBlue;
      case DastraButtonType.secondary:
        return _isHovered ? context.colors.cardHover : context.colors.card;
      case DastraButtonType.ghost:
        return _isHovered ? context.colors.glassBg : Colors.transparent;
      case DastraButtonType.destructive:
        return _isHovered ? context.colors.error.withValues(alpha: 0.9) : context.colors.error;
    }
  }

  Color _getTextColor(BuildContext context) {
    if (widget.textColor != null && widget.onTap != null) {
      return widget.textColor!;
    }
    if (widget.onTap == null) return context.colors.textDisabled;
    switch (widget.type) {
      case DastraButtonType.primary:
      case DastraButtonType.destructive:
        return Colors.white;
      case DastraButtonType.secondary:
      case DastraButtonType.ghost:
        return context.colors.textPrimary;
    }
  }

  Color _getBorderColor(BuildContext context) {
    if (widget.onTap == null) return context.colors.borderSubtle;
    switch (widget.type) {
      case DastraButtonType.primary:
      case DastraButtonType.destructive:
        return Colors.transparent;
      case DastraButtonType.secondary:
        return _isHovered ? context.colors.borderHover : context.colors.border;
      case DastraButtonType.ghost:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool disabled = widget.onTap == null || widget.isLoading;
    final bg = _getBackgroundColor(context);
    final fg = _getTextColor(context);
    final border = _getBorderColor(context);

    Widget content = Row(
      mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading) ...[
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
        ] else if (widget.icon != null) ...[
          Icon(widget.icon, size: 18, color: fg),
          const SizedBox(width: AppSpacing.sm),
        ],
        Text(
          widget.label,
          style: context.typography.labelLarge.copyWith(color: fg),
        ),
      ],
    );

    content = AnimatedContainer(
      duration: AppAnimations.fast,
      curve: AppAnimations.standard,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: border),
      ),
      child: content,
    );

    if (!disabled) {
      content = MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: content,
        ),
      );
    }

    return Semantics(
      button: true,
      enabled: !disabled,
      label: widget.label,
      child: content.animate(target: _isPressed ? 1 : (_isHovered ? 0.5 : 0)).scale(
        end: const Offset(0.97, 0.97),
        duration: AppAnimations.fast,
        curve: AppAnimations.standard,
      ),
    );
  }
}
