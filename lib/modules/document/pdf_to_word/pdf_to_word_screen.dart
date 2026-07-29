import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/theme/app_colors.dart';
import 'controller/pdf_to_word_controller.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/widgets.dart';
import '../shared/widgets/tool_action_footer.dart';
import 'widgets/pdf_to_word_options_card.dart';
import '../shared/widgets/document_preview_card.dart';

class PdfToWordScreen extends StatelessWidget {
  const PdfToWordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GetIt.I<PdfToWordController>(),
      child: const _PdfToWordContent(),
    );
  }
}

class _PdfToWordContent extends StatelessWidget {
  const _PdfToWordContent();

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<PdfToWordController>();

    return DastraToolPage(
      title: 'PDF to Word',
      icon: Icons.description_rounded,
      hasContent: ctrl.hasJob,
      actions: [
        if (ctrl.hasJob && !ctrl.isProcessing)
          IconButton(
            icon: Icon(Icons.delete_sweep_rounded, color: context.colors.error),
            onPressed: ctrl.removeFile,
            tooltip: 'Clear',
          ),
        const SizedBox(width: 8),
      ],
      emptyState: ctrl.isPlatformSupported 
          ? AppEmptyState(
              onPickFiles: ctrl.pickFile,
              title: 'Select PDF',
              subtitle: 'Choose a PDF file to convert it into an editable Word document (DOCX).',
              icon: Icons.description_rounded,
            )
          : const AppEmptyState(
              onPickFiles: null,
              title: 'Unsupported Feature',
              subtitle: 'This feature is currently only available on Desktop.',
              icon: Icons.block_rounded,
            ),
      primaryContent: const _PdfList(),
      configurationPanel: const SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: PdfToWordOptionsCard(),
      ),
      primaryAction: ToolActionFooter(
        onPressed: ctrl.isProcessing || ctrl.needsEngineDownload || ctrl.job == null || ctrl.outputConfig == null ? null : ctrl.startConversion,
        isProcessing: ctrl.isProcessing,
        icon: Icons.description_rounded,
        label: 'Convert to Word',
        processingLabel: 'Converting...',
      ),
      primaryFlex: 2,
      configurationFlex: 1,
          );
  }
}

class _PdfList extends StatelessWidget {
  const _PdfList();

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<PdfToWordController>();
    final job = ctrl.job;
    if (job == null) return const SizedBox.shrink();

    final isNarrow = MediaQuery.of(context).size.width <= 900;

    return Padding(
      padding: EdgeInsets.all(isNarrow ? 0 : 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selected Document',
            style: TextStyle(
              color: context.colors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          DocumentPreviewCard(
            job: job,
            isReorderable: false,
            onRemove: ctrl.isProcessing ? () {} : ctrl.removeFile,
          ),
        ],
      ),
    );
  }
}
