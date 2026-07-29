import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import '../../../core/theme/theme.dart';
import '../../image/image_compressor/utils/compression_utils.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/widgets.dart';
import '../shared/widgets/tool_action_footer.dart';
import 'controller/pdf_compress_controller.dart';
import 'model/pdf_compress_preset.dart';
import 'widgets/pdf_compress_options_card.dart';

class PdfCompressScreen extends StatelessWidget {
  const PdfCompressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GetIt.I<PdfCompressController>(),
      child: const _PdfCompressScreenContent(),
    );
  }
}

class _PdfCompressScreenContent extends StatelessWidget {
  const _PdfCompressScreenContent();

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<PdfCompressController>();
    final hasJob = ctrl.hasJob;

    return DastraToolPage(
      title: 'Compress PDF',
      icon: Icons.compress_rounded,
      hasContent: hasJob,
      emptyState: ctrl.isPlatformSupported
          ? AppEmptyState(
              title: 'Drop PDF Here',
              subtitle: 'or click to browse',
              onPickFiles: ctrl.pickFile,
            )
          : const AppEmptyState(
              onPickFiles: null,
              title: 'Unsupported Feature',
              subtitle: 'This feature is currently only available on Desktop.',
              icon: Icons.block_rounded,
            ),
      primaryContent: Padding(
        padding: const EdgeInsets.all(24),
        child: hasJob ? _buildPreviewArea(context, ctrl) : SizedBox.shrink(),
      ),
      configurationPanel: const SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: PdfCompressOptionsCard(),
      ),
      primaryAction: ToolActionFooter(
        onPressed: ctrl.isProcessing || ctrl.job == null || ctrl.outputConfig == null ? null : ctrl.startCompression,
        isProcessing: ctrl.isProcessing,
        icon: Icons.compress_rounded,
        label: 'Compress PDF',
        processingLabel: 'Compressing...',
      ),
      primaryFlex: 2,
          );
  }

  Widget _buildPreviewArea(BuildContext context, PdfCompressController ctrl) {
    final job = ctrl.job!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.colors.border),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppGradients.document,
                        boxShadow: [
                          BoxShadow(
                            color: context.colors.accentBlue.withValues(alpha: 0.2),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: const Icon(Icons.picture_as_pdf_rounded, size: 64, color: Colors.white),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      job.fileName,
                      style: context.textStyles.h4,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: context.colors.background,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: context.colors.border),
                      ),
                      child: Text(
                        CompressionUtils.formatBytes(job.fileSize),
                        style: context.textStyles.bodyMedium.copyWith(color: context.colors.textSecondary, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              if (!ctrl.isProcessing && ctrl.successData == null)
                Positioned(
                  top: 16,
                  right: 16,
                  child: IconButton(
                    onPressed: ctrl.removeFile,
                    icon: const Icon(Icons.close_rounded),
                    color: context.colors.textSecondary,
                    tooltip: 'Remove',
                    hoverColor: context.colors.error.withValues(alpha: 0.1),
                    style: IconButton.styleFrom(
                      backgroundColor: context.colors.background,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildExpectedResultCard(context, ctrl),
      ],
    );
  }

  Widget _buildExpectedResultCard(BuildContext context, PdfCompressController ctrl) {
    final job = ctrl.job!;
    double ratio = 1.0;
    switch (ctrl.preset) {
      case PdfCompressPreset.low: ratio = 0.85; break;
      case PdfCompressPreset.medium: ratio = 0.50; break;
      case PdfCompressPreset.high: ratio = 0.25; break;
      case PdfCompressPreset.max: ratio = 0.15; break;
    }
    final int estimatedSize = (job.fileSize * ratio).toInt();
    
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: context.colors.accentBlue, size: 20),
              SizedBox(width: 8),
              Text('Expected Result', style: context.textStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: context.colors.accentBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Estimation', style: context.textStyles.bodySmall.copyWith(color: context.colors.accentBlue, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildEstimateItem(context, 'Original Size', CompressionUtils.formatBytes(job.fileSize), Icons.sd_storage_outlined),
              Icon(Icons.arrow_forward_rounded, color: context.colors.border, size: 24),
              _buildEstimateItem(context, 'Estimated Size', CompressionUtils.formatBytes(estimatedSize), Icons.compress_rounded, highlight: true),
              Icon(Icons.arrow_forward_rounded, color: context.colors.border, size: 24),
              _buildEstimateItem(context, 'Reduction', '${((1 - ratio) * 100).toInt()}%', Icons.trending_down_rounded, highlight: true),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildEstimateItem(BuildContext context, String label, String value, IconData icon, {bool highlight = false}) {
    return Column(
      children: [
        Icon(icon, color: highlight ? context.colors.accentBlue : context.colors.textSecondary, size: 28),
        SizedBox(height: 12),
        Text(value, style: context.textStyles.h4.copyWith(color: highlight ? context.colors.textPrimary : context.colors.textSecondary)),
        SizedBox(height: 4),
        Text(label, style: context.textStyles.bodySmall.copyWith(color: context.colors.textSecondary, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
