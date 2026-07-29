import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/theme.dart';

class DastraCard extends StatefulWidget {
  const DastraCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.isSelected = false,
    this.isInteractive = false,
    this.borderColor,
    this.backgroundColor,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool isInteractive;
  final Color? borderColor;
  final Color? backgroundColor;

  @override
  State<DastraCard> createState() => _DastraCardState();
}

class _DastraCardState extends State<DastraCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final interactive = widget.onTap != null || widget.isInteractive;
    final defaultBg = widget.backgroundColor ?? context.colors.card;
    final defaultBorder = widget.borderColor ?? (widget.isSelected ? context.colors.accentBlue : context.colors.border);

    Widget content = Container(
      padding: widget.padding ?? const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: _isHovered && interactive ? context.colors.cardHover : defaultBg,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: _isHovered && interactive ? context.colors.borderHover : defaultBorder,
          width: widget.isSelected ? 2.0 : 1.0,
        ),
        boxShadow: _isHovered && interactive ? AppShadows.cardHoverShadow(context) : AppShadows.cardShadow(context),
      ),
      child: widget.child,
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
        end: const Offset(1.02, 1.02),
        duration: AppAnimations.fast,
        curve: AppAnimations.standard,
      );
    }

    return content;
  }
}
