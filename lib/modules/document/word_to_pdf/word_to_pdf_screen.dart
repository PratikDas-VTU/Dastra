import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import '../../../core/theme/app_colors.dart';
import '../../image/image_compressor/utils/compression_utils.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/widgets.dart';
import '../shared/widgets/tool_action_footer.dart';
import 'controller/word_to_pdf_controller.dart';
import 'widgets/word_to_pdf_options_card.dart';

class WordToPdfScreen extends StatelessWidget {
  const WordToPdfScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GetIt.I<WordToPdfController>(),
      child: const _WordToPdfScreenContent(),
    );
  }
}

class _WordToPdfScreenContent extends StatelessWidget {
  const _WordToPdfScreenContent();

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<WordToPdfController>();
    final hasJob = ctrl.hasJob;

    return DastraToolPage(
      title: 'Word to PDF',
      icon: Icons.description_rounded,
      hasContent: hasJob,
      emptyState: ctrl.isPlatformSupported
          ? AppEmptyState(
              title: 'Drop DOCX Here',
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
        child: WordToPdfOptionsCard(),
      ),
      primaryAction: ToolActionFooter(
        onPressed: ctrl.isProcessing || ctrl.needsEngineDownload || ctrl.job == null || ctrl.outputConfig == null ? null : ctrl.startConversion,
        isProcessing: ctrl.isProcessing,
        icon: Icons.picture_as_pdf_rounded,
        label: 'Convert to PDF',
        processingLabel: 'Converting...',
      ),
      primaryFlex: 2,
          );
  }

  Widget _buildPreviewArea(BuildContext context, WordToPdfController ctrl) {
    final job = ctrl.job!;
    return Stack(
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
              Icon(Icons.description_rounded, size: 80, color: context.colors.accentBlue),
              const SizedBox(height: 16),
              Text(
                job.fileName,
                style: TextStyle(
                  color: context.colors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                CompressionUtils.formatBytes(job.fileSize),
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontSize: 14,
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
              style: IconButton.styleFrom(
                backgroundColor: context.colors.background,
              ),
            ),
          ),
      ],
    );
  }
}
