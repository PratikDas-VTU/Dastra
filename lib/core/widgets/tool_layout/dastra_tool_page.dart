import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/theme.dart';
import '../../utils/responsive.dart';
import '../adaptive_scaffold.dart';
import '../adaptive_file_selector.dart';

class DastraToolPage extends StatefulWidget {
  const DastraToolPage({
    super.key,
    required this.title,
    required this.icon,
    this.primaryContentHeader,
    required this.primaryContent,
    required this.configurationPanel,
    this.primaryAction,
    this.hasContent = true,
    this.emptyState,
    this.actions,
    this.onBackPressed,
    this.onFilesDropped,
    this.primaryFlex = 6,
    this.configurationFlex = 4,
    this.headerGradient,
  });

  final String title;
  final IconData icon;
  final Widget? primaryContentHeader;
  final Widget primaryContent;
  final Widget configurationPanel;
  final Widget? primaryAction;
  
  /// If false, the [emptyState] widget is displayed in the center of the screen,
  /// and both the primary content and configuration panels are hidden.
  final bool hasContent;
  final Widget? emptyState;
  
  final List<Widget>? actions;
  final VoidCallback? onBackPressed;
  final void Function(List<String>)? onFilesDropped;
  
  final int primaryFlex;
  final int configurationFlex;
  final Gradient? headerGradient;

  @override
  State<DastraToolPage> createState() => _DastraToolPageState();
}

class _DastraToolPageState extends State<DastraToolPage> {
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    Widget body = widget.hasContent
        ? AdaptiveBuilder(
            compact: (context, size) => _buildCompactLayout(),
            largePhone: (context, size) => _buildCompactLayout(),
            tablet: (context, size) => _buildTabletLayout(),
            builder: (context, size) => _buildDesktopLayout(),
          )
        : Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: widget.emptyState ?? const SizedBox.shrink(),
              ),
            ),
          );

    if (widget.onFilesDropped != null) {
      body = AdaptiveFileSelector(
        onFilesSelected: widget.onFilesDropped!,
        onDragEntered: () => setState(() => _isDragging = true),
        onDragExited: () => setState(() => _isDragging = false),
        child: Stack(
          children: [
            body,
            if (_isDragging)
              Positioned.fill(
                child: Container(
                  color: context.colors.surface.withValues(alpha: 0.85),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
                      decoration: BoxDecoration(
                        color: context.colors.background,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(color: context.colors.accentBlue, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: context.colors.accentBlue.withValues(alpha: 0.2),
                            blurRadius: 24,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.cloud_upload_rounded, size: 64, color: context.colors.accentBlue)
                              .animate(onPlay: (c) => c.repeat(reverse: true))
                              .moveY(begin: -8, end: 8, duration: 1000.ms, curve: Curves.easeInOut),
                          const SizedBox(height: 16),
                          Text(
                            'Drop files here',
                            style: context.textStyles.h3.copyWith(color: context.colors.accentBlue),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: 200.ms),
          ],
        ),
      );
    }

    return AdaptiveScaffold(
      title: widget.title,
      icon: widget.icon,
      gradientColors: widget.headerGradient?.colors,
      actions: widget.actions,
      onBackPressed: widget.onBackPressed ?? () => Navigator.of(context).pop(),
      showGlobalBranding: true,
      body: body,
    );
  }

  Widget _buildCompactLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.primaryContentHeader != null) widget.primaryContentHeader!,
                widget.primaryContent,
                Container(
                  color: context.colors.surface,
                  child: widget.configurationPanel,
                ),
              ],
            ),
          ),
        ),
        if (widget.primaryAction != null) 
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(context.spacing.md),
              child: widget.primaryAction!,
            ),
          ),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: widget.primaryFlex,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.primaryContentHeader != null) widget.primaryContentHeader!,
              Expanded(child: widget.primaryContent),
            ],
          ),
        ),
        Container(
          width: 1,
          color: context.colors.border,
        ),
        Expanded(
          flex: widget.configurationFlex,
          child: Container(
            color: context.colors.surface,
            child: Column(
              children: [
                Expanded(child: widget.configurationPanel),
                if (widget.primaryAction != null) widget.primaryAction!,
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return _buildTabletLayout(); // Desktop and tablet share the same core split layout
  }
}
