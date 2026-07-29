import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../model/conversion_result_data.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ConversionResultCard extends StatelessWidget {
  final ConversionResultData data;
  final VoidCallback onConvertAnother;
  
  const ConversionResultCard({
    super.key,
    required this.data,
    required this.onConvertAnother,
  });

  void _copyPath(BuildContext context) {
    Clipboard.setData(ClipboardData(text: data.outputPath));
    DastraSnackbar.show(
      context: context,
      message: 'File path copied to clipboard',
    );
  }

  Future<void> _openFolder() async {
    final folderUri = Uri.file(data.outputFolder).toString();
    if (await canLaunchUrlString(folderUri)) {
      await launchUrlString(folderUri);
    }
  }

  Future<void> _openFile() async {
    final fileUri = Uri.file(data.outputPath).toString();
    if (await canLaunchUrlString(fileUri)) {
      await launchUrlString(fileUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DastraCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: AppSpacing.xl),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Status Icon
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: data.isSuccess 
                    ? LinearGradient(
                        colors: context.colors.documentGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: data.isSuccess ? null : context.colors.error.withValues(alpha: 0.1),
                boxShadow: data.isSuccess 
                    ? [
                        BoxShadow(
                          color: context.colors.accentBlue.withValues(alpha: 0.3),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        )
                      ]
                    : null,
              ),
              child: Icon(
                data.isSuccess ? Icons.check_circle_outline_rounded : Icons.error_outline_rounded,
                color: data.isSuccess ? Colors.white : context.colors.error,
                size: 64,
              ),
            ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack).fadeIn(),
            
            const SizedBox(height: AppSpacing.xl),
            
            Text(
              data.isSuccess ? 'Conversion Successful' : 'Conversion Failed',
              style: context.textStyles.h2,
            ).animate().slideY(begin: 0.2, end: 0, duration: 400.ms, curve: Curves.easeOut).fadeIn(),
            
            if (data.errorMessage != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                data.errorMessage!,
                style: context.textStyles.bodyMedium.copyWith(color: context.colors.error),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 200.ms),
            ],
            
            const SizedBox(height: AppSpacing.xxl),
            
            if (data.isSuccess) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: context.colors.background,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: context.colors.border),
                ),
                child: Column(
                  children: [
                    Text(
                      data.outputFilename,
                      style: context.textStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      data.outputFolder,
                      style: context.textStyles.bodyMedium.copyWith(color: context.colors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),
              
              const SizedBox(height: AppSpacing.xl),
              _OutputStatisticsGrid(statistics: data.statistics).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: AppSpacing.xxl),
              
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                alignment: WrapAlignment.center,
                children: [
                  DastraButton(
                    onTap: () => _copyPath(context),
                    icon: Icons.copy_rounded,
                    label: 'Copy Path',
                    type: DastraButtonType.secondary,
                  ),
                  DastraButton(
                    onTap: _openFolder,
                    icon: Icons.folder_open_rounded,
                    label: 'Open Folder',
                    type: DastraButtonType.secondary,
                  ),
                  DastraButton(
                    onTap: _openFile,
                    icon: Icons.open_in_new_rounded,
                    label: 'Open File',
                    type: DastraButtonType.primary,
                  ),
                ],
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),
            ],
            
            const SizedBox(height: AppSpacing.xxl),
            Divider(color: context.colors.border),
            const SizedBox(height: AppSpacing.lg),
            
            DastraButton(
              onTap: onConvertAnother,
              icon: Icons.refresh_rounded,
              label: 'Convert Another File',
              type: DastraButtonType.ghost,
            ),
          ],
        ),
      ),
    );
  }
}

class _OutputStatisticsGrid extends StatelessWidget {
  final List<ConversionStatistic> statistics;

  const _OutputStatisticsGrid({required this.statistics});

  @override
  Widget build(BuildContext context) {
    if (statistics.isEmpty) return const SizedBox.shrink();

    return DastraCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Wrap(
        spacing: AppSpacing.xxl,
        runSpacing: AppSpacing.xl,
        alignment: WrapAlignment.center,
        children: statistics.map((stat) => _buildStatItem(context, stat.label, stat.value)).toList(),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            color: context.colors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: TextStyle(
            color: context.colors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
