import 'package:flutter/material.dart';
import '../theme/theme.dart';

class DastraSnackbar {
  static void show({
    required BuildContext context,
    required String message,
    IconData? icon,
    bool isError = false,
  }) {
    final snackBar = SnackBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.all(AppSpacing.lg),
      content: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: isError ? context.colors.error : context.colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isError ? context.colors.error.withValues(alpha: 0.5) : context.colors.border,
          ),
          boxShadow: AppShadows.panelShadow(context),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: context.colors.textPrimary,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.md),
            ],
            Expanded(
              child: Text(
                message,
                style: context.textStyles.bodyMedium.copyWith(
                  color: context.colors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
      duration: AppAnimations.extraSlow * 3, // ~2.1 seconds
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}
