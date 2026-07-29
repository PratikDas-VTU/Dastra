import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../utils/responsive.dart';
import 'adaptive_empty_state.dart';

class AdaptiveFeedback {
  AdaptiveFeedback._();

  /// Shows a centralized, platform-aware snackbar.
  static void showSnackbar(BuildContext context, String message, {bool isError = false}) {
    final snackBar = SnackBar(
      behavior: isMobile(context) ? SnackBarBehavior.fixed : SnackBarBehavior.floating,
      width: isMobile(context) ? null : 400,
      backgroundColor: isError ? context.colors.error : context.colors.surface,
      content: Row(
        children: [
          Icon(
            isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
            color: isError ? Colors.white : context.colors.success,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: context.textStyles.bodyMedium.copyWith(
                color: isError ? Colors.white : context.colors.textPrimary,
              ),
            ),
          ),
        ],
      ),
      shape: isMobile(context)
          ? null
          : RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
    );
    
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  /// Displays a standardized modal dialog.
  static Future<T?> showAdaptiveDialog<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    List<Widget>? actions,
  }) {
    return showDialog<T>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.colors.surface,
        shape: AdaptiveTheme.dialogShape(context),
        title: Text(title, style: context.textStyles.h3),
        content: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: AppMetrics.dialogMaxWidth(context)),
          child: content,
        ),
        actions: actions,
      ),
    );
  }

  /// Returns a centralized Loading Indicator widget.
  static Widget loadingIndicator({double size = 48}) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: const CircularProgressIndicator(
          color: AppColors.accentBlue,
          strokeWidth: 3,
        ),
      ),
    );
  }

  /// Returns an Unsupported Feature empty state.
  static Widget unsupportedFeature({String? message}) {
    return AdaptiveEmptyState(
      title: 'Not Supported Yet',
      subtitle: message ?? 'This feature is currently available on Desktop only.',
      icon: Icons.devices_other_rounded,
    );
  }
}
