// Glassmorphism search bar for the dashboard
import 'package:flutter/material.dart';
import '../theme/theme.dart';

class DastraSearchBar extends StatefulWidget {
  const DastraSearchBar({
    super.key,
    required this.onChanged,
    this.hint = 'Search tools...',
  });

  final ValueChanged<String> onChanged;
  final String hint;

  @override
  State<DastraSearchBar> createState() => _DastraSearchBarState();
}

class _DastraSearchBarState extends State<DastraSearchBar> {
  final _controller = TextEditingController();
  bool _focused = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: _focused ? context.colors.accentBlue.withValues(alpha: 0.6) : context.colors.border,
          width: _focused ? 1.5 : 1.0,
        ),
        boxShadow: _focused
            ? [
                BoxShadow(
                  color: context.colors.accentBlue.withValues(alpha: 0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ]
            : AppShadows.cardShadow(context),
      ),
      child: Focus(
        onFocusChange: (v) => setState(() => _focused = v),
        child: TextField(
          controller: _controller,
          onChanged: widget.onChanged,
          style: context.textStyles.bodyLarge,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: context.textStyles.searchHint,
            prefixIcon: Icon(
              Icons.search_rounded,
              color: _focused ? context.colors.accentBlue : context.colors.textMuted,
              size: 20,
            ),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: context.colors.textMuted,
                    ),
                    onPressed: () {
                      _controller.clear();
                      widget.onChanged('');
                    },
                  )
                : null,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            filled: false,
          ),
        ),
      ),
    );
  }
}
