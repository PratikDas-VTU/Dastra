import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/di/service_locator.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/widgets.dart';
import '../shared/widgets/document_preview_card.dart';
import '../shared/widgets/tool_action_footer.dart';
import 'controller/pdf_split_controller.dart';
import 'widgets/pdf_split_options_card.dart';

class PdfSplitScreen extends StatelessWidget {
  const PdfSplitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => sl<PdfSplitController>(),
      child: const _PdfSplitScreenContent(),
    );
  }
}

class _PdfSplitScreenContent extends StatelessWidget {
  const _PdfSplitScreenContent();

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<PdfSplitController>();
    final hasJob = ctrl.activeJob != null;

    return DastraToolPage(
      title: 'Split PDF',
      icon: Icons.call_split_rounded,
      hasContent: hasJob,
      emptyState: AppEmptyState(
        onPickFiles: ctrl.pickFile,
        title: 'Select a PDF to Split',
        subtitle: 'Extract pages, split into intervals, or create custom ranges.',
        icon: Icons.call_split_rounded,
      ),
      primaryContent: const _PdfSource(),
      configurationPanel: const SingleChildScrollView(
        padding: EdgeInsets.all(24.0),
        child: PdfSplitOptionsCard(),
      ),
      primaryAction: ToolActionFooter(
        onPressed: ctrl.canSplit && ctrl.outputConfig != null ? ctrl.splitPdf : null,
        isProcessing: ctrl.isProcessing,
        icon: Icons.call_split_rounded,
        label: 'Split PDF',
        processingLabel: 'Splitting...',
      ),
      primaryFlex: 3,
      configurationFlex: 2,
          );
  }
}

class _PdfSource extends StatelessWidget {
  const _PdfSource();

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<PdfSplitController>();
    final job = ctrl.activeJob;
    if (job == null) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Source Document',
                style: TextStyle(
                  color: context.colors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: ctrl.isProcessing ? null : ctrl.removeFile,
                icon: const Icon(Icons.close_rounded, size: 18),
                label: const Text('Remove'),
                style: TextButton.styleFrom(
                  foregroundColor: context.colors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DocumentPreviewCard(
            job: job,
            onRemove: ctrl.isProcessing ? null : ctrl.removeFile,
          ),
        ],
      ),
    );
  }
}
