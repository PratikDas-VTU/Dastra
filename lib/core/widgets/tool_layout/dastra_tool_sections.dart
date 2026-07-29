import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/theme.dart';
import '../dastra_card.dart';

class DastraConfigurationSection extends StatelessWidget {
  const DastraConfigurationSection({
    super.key,
    required this.title,
    this.icon,
    this.subtitle,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.xl),
    this.action,
  });

  final String title;
  final IconData? icon;
  final String? subtitle;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return DastraCard(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: context.colors.textSecondary),
                const SizedBox(width: AppSpacing.sm),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: context.textStyles.h4),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(subtitle!, style: context.textStyles.caption),
                    ]
                  ],
                ),
              ),
              if (action != null) action!,
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          child,
        ],
      ),
    );
  }
}

class DastraConfigurationPanel extends StatelessWidget {
  const DastraConfigurationPanel({
    super.key,
    required this.sections,
    this.padding = const EdgeInsets.all(AppSpacing.xl),
  });

  final List<Widget> sections;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (int i = 0; i < sections.length; i++) ...[
            sections[i],
            if (i < sections.length - 1) const SizedBox(height: AppSpacing.xl),
          ]
        ],
      ),
    );
  }
}
