import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/theme.dart';
import '../utils/responsive.dart';

class DastraInfoTile extends StatefulWidget {
  const DastraInfoTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.canCopy = false,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool canCopy;
  final VoidCallback? onTap;

  @override
  State<DastraInfoTile> createState() => _DastraInfoTileState();
}

class _DastraInfoTileState extends State<DastraInfoTile> {
  bool _copied = false;
  bool _isHovered = false;

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.value));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final interactive = widget.canCopy || widget.onTap != null;

    Widget content = Container(
      padding: EdgeInsets.symmetric(horizontal: context.spacing.lg, vertical: context.spacing.md),
      decoration: BoxDecoration(
        color: _isHovered && interactive ? context.colors.cardHover : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        crossAxisAlignment: context.layout.isMobile ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: context.colors.borderSubtle),
            ),
            child: Icon(widget.icon, size: 18, color: context.colors.accentBlue),
          ),
          SizedBox(width: context.spacing.md),
          Expanded(
            child: context.layout.isCompact ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.label,
                  style: context.typography.labelMedium.copyWith(
                    color: context.colors.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.value,
                  style: context.typography.titleMedium.copyWith(
                    color: context.colors.textPrimary,
                  ),
                ),
              ],
            ) : Row( // Or keep column for label/value pair normally, wait it WAS a column before
              // The original was a Column. Wait, if it was a Column, it already stacks vertically!
              // I'll keep it as a Column, but allow the value to wrap
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.label,
                        style: context.typography.labelMedium.copyWith(
                          color: context.colors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.value,
                        style: context.typography.titleMedium.copyWith(
                          color: context.colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          ),
          if (widget.canCopy) ...[
            const SizedBox(width: AppSpacing.sm),
            Tooltip(
              message: _copied ? 'Copied!' : 'Copy to clipboard',
              child: IconButton(
                icon: Icon(
                  _copied ? Icons.check_rounded : Icons.copy_rounded,
                  size: 16,
                  color: _copied ? context.colors.success : context.colors.textMuted,
                ),
                onPressed: _copyToClipboard,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ),
          ] else if (widget.onTap != null) ...[
            const SizedBox(width: AppSpacing.sm),
            Icon(Icons.chevron_right_rounded, size: 18, color: context.colors.textMuted),
          ],
        ],
      ),
    );

    if (interactive) {
      return MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap ?? (widget.canCopy ? _copyToClipboard : null),
          behavior: HitTestBehavior.opaque,
          child: content,
        ),
      );
    }

    return content;
  }
}
