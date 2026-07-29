import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/theme.dart';
import '../../../image/image_compressor/utils/compression_utils.dart'; // Reusing formatBytes
import '../controller/pptx_to_pdf_controller.dart';
import '../../shared/widgets/output_settings_card.dart';
import '../../shared/widgets/conversion_result_card.dart';

class PptxToPdfOptionsCard extends StatelessWidget {
  const PptxToPdfOptionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<PptxToPdfController>();

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
          const SizedBox(height: 24),
        ],

        Material(
          color: context.colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: context.colors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(Icons.picture_as_pdf_rounded, color: context.colors.accentBlue, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Convert Options',
                      style: context.textStyles.h4,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // --- Summary Section ---
                if (ctrl.job != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.colors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.colors.border),
                    ),
                    child: Column(
                      children: [
                        _buildSummaryRow(context, 'Original Size', CompressionUtils.formatBytes(ctrl.job!.fileSize)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                // --- End Summary Section ---
                
                if (ctrl.needsEngineDownload)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.colors.warning.withValues(alpha: 0.05),
                      border: Border.all(color: context.colors.warning.withValues(alpha: 0.3)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.download_rounded, color: context.colors.warning, size: 32),
                        const SizedBox(height: 8),
                        Text(
                          'Engine Required',
                          style: TextStyle(fontWeight: FontWeight.bold, color: context.colors.warning),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'The PPTX to PDF engine is not installed. Download it now to proceed.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: context.colors.textSecondary, fontSize: 13),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: ctrl.isProcessing ? null : ctrl.downloadRequiredEngine,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.colors.warning,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Download Engine', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(),
                
                const SizedBox(height: 24),
                
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
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: ctrl.progress > 0 ? ctrl.progress : null,
                          backgroundColor: context.colors.background,
                          color: context.colors.accentBlue,
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ).animate().fadeIn(),
                ],
                
              ],
            ),
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
