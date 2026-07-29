import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/models.dart';
import '../theme/theme.dart';
import 'gradient_icon_box.dart';
import '../utils/responsive.dart';

class AdaptiveToolCard extends StatefulWidget {
  const AdaptiveToolCard({
    super.key,
    required this.tool,
    required this.onTap,
    this.isFavorite = false,
    this.onToggleFavorite,
    this.isSupported = true,
    this.unsupportedReason,
  });

  final ToolItem tool;
  final VoidCallback onTap;
  final bool isFavorite;
  final VoidCallback? onToggleFavorite;
  final bool isSupported;
  final String? unsupportedReason;

  @override
  State<AdaptiveToolCard> createState() => _AdaptiveToolCardState();
}

class _AdaptiveToolCardState extends State<AdaptiveToolCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isMob = context.layout.isMobile;
    final cardPadding = isMob ? EdgeInsets.all(context.spacing.md) : EdgeInsets.all(context.spacing.lg);
    final iconBoxSize = isMob ? 36.0 : 40.0;
    final iconSize = isMob ? 18.0 : 20.0;

    // Mobile uses plain InkWell without MouseRegion hover logic
    Widget cardContent = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      transformAlignment: Alignment.center,
      transform: _hovered && !isMob
          ? (Matrix4.identity()..scale(1.015))
          : Matrix4.identity(),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: (_hovered && !isMob)
              ? context.colors.accentBlue.withValues(alpha: 0.4)
              : context.colors.border,
          width: 1,
        ),
        boxShadow: (_hovered && !isMob)
            ? AppShadows.cardHoverShadow(context)
            : AppShadows.cardShadow(context),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.isSupported ? widget.onTap : () {
            // Show toast or snackbar
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(widget.unsupportedReason ?? 'Tool not supported on this platform.')),
            );
          },
          onHover: (!isMob && widget.isSupported) ? (hovering) => setState(() => _hovered = hovering) : null,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          splashColor: context.colors.accentBlue.withValues(alpha: 0.08),
          highlightColor: Colors.transparent,
          child: Padding(
            padding: cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // Allow dynamic height on mobile list if needed
              children: [
                // Icon box and Soon badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GradientIconBox(
                      icon: widget.tool.icon,
                      gradientColors: widget.tool.gradientColors,
                      size: iconBoxSize,
                      iconSize: iconSize,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!widget.isSupported)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: context.colors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Text(
                              'Unsupported',
                              style: context.textStyles.bodySmall.copyWith(
                                color: context.colors.error,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        if (!widget.isSupported && widget.onToggleFavorite != null)
                          const SizedBox(width: 8),
                        if (widget.onToggleFavorite != null)
                          Material(
                            color: Colors.transparent,
                            child: IconButton(
                              onPressed: widget.onToggleFavorite,
                              icon: Icon(
                                widget.isFavorite ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                                color: widget.isFavorite ? context.colors.accentOrange : context.colors.textSecondary,
                                size: 20,
                              ),
                              splashRadius: 20,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: isMob ? 8 : 12),

                // Title
                Text(
                  widget.tool.title,
                  style: isMob ? context.textStyles.labelLarge : context.textStyles.h4,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Description
                Flexible(
                  child: Text(
                    widget.tool.description,
                    style: isMob ? context.textStyles.bodySmall.copyWith(fontSize: 12) : context.textStyles.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Apply animation
    cardContent = cardContent.animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0);

    // Apply disabled opacity if not supported
    if (!widget.isSupported) {
      cardContent = Opacity(
        opacity: 0.6,
        child: cardContent,
      );
    }

    return cardContent;
  }
}
