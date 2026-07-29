import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../utils/responsive.dart';
import 'widgets.dart';

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.onPickFiles,
    required this.title,
    required this.subtitle,
    this.icon = Icons.picture_as_pdf_rounded,
    this.allowedExtensions,
    this.primaryGradient,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onPickFiles;
  final List<String>? allowedExtensions;
  final Gradient? primaryGradient;

  @override
  Widget build(BuildContext context) {
    final size = Adaptive.of(context);
    final isCompact = size == ScreenSize.compact || size == ScreenSize.largePhone;

    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: DastraCard(
          isInteractive: onPickFiles != null,
          onTap: onPickFiles,
          padding: EdgeInsets.all(isCompact ? AppSpacing.xl : 48.0),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(isCompact ? AppSpacing.lg : AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: context.colors.border,
                    ),
                  ),
                  child: Icon(
                    icon,
                    size: isCompact ? 36 : 48,
                    color: context.colors.textMuted,
                  ),
                ),
                SizedBox(height: isCompact ? AppSpacing.lg : AppSpacing.xl),
                Text(
                  title,
                  style: isCompact ? context.textStyles.h4 : context.textStyles.h3,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  subtitle,
                  style: isCompact ? context.textStyles.bodySmall : context.textStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                if (allowedExtensions != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    alignment: WrapAlignment.center,
                    children: allowedExtensions!.map((ext) {
                      return _ExtensionBadge(ext: ext);
                    }).toList(),
                  ),
                ],
                if (onPickFiles != null) ...[
                  const SizedBox(height: AppSpacing.xxl),
                  DastraButton(
                    label: 'Browse Files',
                    icon: Icons.folder_open_rounded,
                    onTap: onPickFiles,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ExtensionBadge extends StatelessWidget {
  const _ExtensionBadge({required this.ext});
  final String ext;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: context.colors.border),
      ),
      child: Text(
        ext.toUpperCase(),
        style: context.textStyles.caption.copyWith(
          color: context.colors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
