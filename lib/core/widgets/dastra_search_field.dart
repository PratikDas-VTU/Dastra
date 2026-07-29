import 'package:flutter/material.dart';
import '../theme/theme.dart';

class DastraSearchField extends StatefulWidget {
  const DastraSearchField({
    super.key,
    required this.controller,
    this.hintText = 'Search...',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final bool autofocus;

  @override
  State<DastraSearchField> createState() => _DastraSearchFieldState();
}

class _DastraSearchFieldState extends State<DastraSearchField> {
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: AppAnimations.fast,
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: _isHovered ? context.colors.borderHover : context.colors.border,
          ),
          boxShadow: _isHovered ? AppShadows.cardShadow(context) : [],
        ),
        child: TextField(
          controller: widget.controller,
          autofocus: widget.autofocus,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          style: context.typography.bodyMedium.copyWith(
            color: context.colors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: context.typography.bodyMedium.copyWith(
              color: context.colors.textMuted,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              size: 20,
              color: _isHovered ? context.colors.accentBlue : context.colors.textMuted,
            ),
            suffixIcon: widget.controller.text.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear_rounded,
                      size: 18,
                      color: context.colors.textMuted,
                    ),
                    onPressed: () {
                      widget.controller.clear();
                      widget.onChanged?.call('');
                      widget.onClear?.call();
                    },
                    tooltip: 'Clear search',
                  )
                : null,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }
}
