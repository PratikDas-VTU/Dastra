import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../image/image_compressor/utils/compression_utils.dart'; // Reusing formatBytes
import '../controller/word_to_pdf_controller.dart';
import '../../shared/widgets/output_settings_card.dart';
import '../../shared/widgets/conversion_result_card.dart';

class WordToPdfOptionsCard extends StatelessWidget {
  const WordToPdfOptionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<WordToPdfController>();

    if (ctrl.resultData != null) {
      return ConversionResultCard(
        data: ctrl.resultData!,
        onConvertAnother: ctrl.removeFile,
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
                  Icon(Icons.picture_as_pdf_rounded, color: context.colors.accentBlue, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Convert Options',
                    style: context.textStyles.h4,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
                
                // --- Summary Section ---
                if (ctrl.job != null) ...[
                  DastraCard(
                    padding: EdgeInsets.all(AppSpacing.md),
                    backgroundColor: context.colors.background,
                    child: Column(
                      children: [
                        _buildSummaryRow(context, 'Original Size', CompressionUtils.formatBytes(ctrl.job!.fileSize)),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
                // --- End Summary Section ---
                
                if (ctrl.needsEngineDownload)
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: context.colors.warning.withValues(alpha: 0.05),
                      border: Border.all(color: context.colors.warning.withValues(alpha: 0.3)),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.download_rounded, color: context.colors.warning, size: 32),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Engine Required',
                          style: TextStyle(fontWeight: FontWeight.bold, color: context.colors.warning),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'The Word to PDF engine is not installed. Download it now to proceed.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: context.colors.textSecondary, fontSize: 13),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        DastraButton(
                          onTap: ctrl.isProcessing ? null : ctrl.downloadRequiredEngine,
                          label: 'Download Engine',
                          type: DastraButtonType.primary,
                        ),
                      ],
                    ),
                  ).animate().fadeIn(),
                
                const SizedBox(height: AppSpacing.xl),
                
                if (ctrl.isProcessing || ctrl.statusMessage.isNotEmpty) ...[
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
                            '${(ctrl.progress * 100).toInt()}%',
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
                          value: ctrl.progress > 0 ? ctrl.progress : null,
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
