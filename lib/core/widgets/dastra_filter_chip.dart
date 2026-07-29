import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/theme.dart';

class DastraFilterChip extends StatefulWidget {
  const DastraFilterChip({
    super.key,
    required this.label,
    this.icon,
    required this.isSelected,
    required this.onSelected,
  });

  final String label;
  final IconData? icon;
  final bool isSelected;
  final ValueChanged<bool> onSelected;

  @override
  State<DastraFilterChip> createState() => _DastraFilterChipState();
}

class _DastraFilterChipState extends State<DastraFilterChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isSelected 
        ? context.colors.accentBlue.withValues(alpha: 0.15)
        : (_isHovered ? context.colors.cardHover : context.colors.card);
        
    final borderColor = widget.isSelected 
        ? context.colors.accentBlue
        : (_isHovered ? context.colors.borderHover : context.colors.border);
        
    final contentColor = widget.isSelected 
        ? context.colors.accentBlue
        : context.colors.textSecondary;

    Widget content = AnimatedContainer(
      duration: AppAnimations.fast,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.icon != null) ...[
            Icon(widget.icon, size: 16, color: contentColor),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            widget.label,
            style: context.textStyles.labelMedium.copyWith(color: contentColor),
          ),
        ],
      ),
    );

    content = MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => widget.onSelected(!widget.isSelected),
        behavior: HitTestBehavior.opaque,
        child: content,
      ),
    );

    return content.animate(target: widget.isSelected ? 1 : 0).scale(
      end: const Offset(1.05, 1.05),
      duration: AppAnimations.fast,
      curve: AppAnimations.standard,
    );
  }
}
