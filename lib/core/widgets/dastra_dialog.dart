import 'package:flutter/material.dart';
import '../theme/theme.dart';
import 'dastra_button.dart';

class DastraDialog extends StatelessWidget {
  const DastraDialog({
    super.key,
    required this.title,
    required this.content,
    this.primaryActionLabel,
    this.onPrimaryAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.icon,
  });

  final String title;
  final Widget content;
  final String? primaryActionLabel;
  final VoidCallback? onPrimaryAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;
  final IconData? icon;

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    String? primaryActionLabel,
    VoidCallback? onPrimaryAction,
    String? secondaryActionLabel,
    VoidCallback? onSecondaryAction,
    IconData? icon,
  }) {
    return showDialog<T>(
      context: context,
      barrierColor: context.colors.overlay,
      builder: (context) => DastraDialog(
        title: title,
        content: content,
        primaryActionLabel: primaryActionLabel,
        onPrimaryAction: onPrimaryAction,
        secondaryActionLabel: secondaryActionLabel,
        onSecondaryAction: onSecondaryAction,
        icon: icon,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: context.colors.border),
          boxShadow: AppShadows.panelShadow(context),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: context.colors.card,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(color: context.colors.border),
                    ),
                    child: Icon(icon, color: context.colors.accentBlue, size: 24),
                  ),
                  const SizedBox(width: AppSpacing.md),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: context.textStyles.h2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            content,
            if (primaryActionLabel != null || secondaryActionLabel != null) ...[
              const SizedBox(height: AppSpacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (secondaryActionLabel != null)
                    DastraButton(
                      label: secondaryActionLabel!,
                      type: DastraButtonType.secondary,
                      onTap: onSecondaryAction ?? () => Navigator.of(context).pop(),
                    ),
                  if (secondaryActionLabel != null && primaryActionLabel != null)
                    const SizedBox(width: AppSpacing.sm),
                  if (primaryActionLabel != null)
                    DastraButton(
                      label: primaryActionLabel!,
                      type: DastraButtonType.primary,
                      onTap: onPrimaryAction,
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
