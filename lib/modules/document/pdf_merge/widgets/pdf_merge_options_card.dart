import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../image/image_compressor/utils/compression_utils.dart'; // Reusing formatBytes
import '../controller/pdf_merge_controller.dart';
import '../../shared/widgets/output_settings_card.dart';
import '../../shared/widgets/conversion_result_card.dart';

class PdfMergeOptionsCard extends StatelessWidget {
  const PdfMergeOptionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<PdfMergeController>();

    if (ctrl.resultData != null) {
      return ConversionResultCard(
        data: ctrl.resultData!,
        onConvertAnother: ctrl.clearJobs,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (ctrl.outputConfig != null) ...[
          OutputSettingsCard(
            config: ctrl.outputConfig!,
            onChanged: ctrl.updateOutputConfig,
            onPickFolder: ctrl.pickOutputFolder,
            fileExtension: '.pdf',
          ).animate().fadeIn().slideY(begin: 0.1, end: 0),
          const SizedBox(height: AppSpacing.xl),
        ],

        DastraCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_awesome_rounded, color: context.colors.accentBlue, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Merge Summary',
                    style: context.textStyles.h4,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              
              DastraCard(
                padding: EdgeInsets.all(AppSpacing.md),
                backgroundColor: context.colors.background,
                child: Column(
                    children: [
                      _buildSummaryRow(context, 'Total Documents', '${ctrl.jobs.length}'),
                      SizedBox(height: AppSpacing.sm),
                      Divider(color: context.colors.border, height: 1),
                      SizedBox(height: AppSpacing.sm),
                      _buildSummaryRow(context, 'Total Pages', '${ctrl.totalPages}'),
                      SizedBox(height: AppSpacing.sm),
                      Divider(color: context.colors.border, height: 1),
                      SizedBox(height: AppSpacing.sm),
                      _buildSummaryRow(context, 'Estimated Size', CompressionUtils.formatBytes(ctrl.totalOriginalSize)),
                    ],
                  ),
              ),
              
              const SizedBox(height: AppSpacing.xxl),
              
              if (ctrl.isMerging || ctrl.statusMessage.isNotEmpty) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            ctrl.statusMessage,
                            style: context.textStyles.bodyMedium.copyWith(
                              color: context.colors.accentBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          '${(ctrl.overallProgress * 100).toInt()}%',
                          style: context.textStyles.bodyMedium.copyWith(
                            color: context.colors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      child: LinearProgressIndicator(
                        value: ctrl.overallProgress > 0 ? ctrl.overallProgress : null,
                        backgroundColor: context.colors.background,
                        color: context.colors.accentBlue,
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ).animate().fadeIn(),
              ],
              
            ],
          ),
        ).animate().fadeIn().slideY(begin: 0.1, end: 0),
      ],
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: context.textStyles.bodyMedium.copyWith(color: context.colors.textSecondary),
        ),
        Text(
          value,
          style: context.textStyles.bodyMedium.copyWith(
            color: context.colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
