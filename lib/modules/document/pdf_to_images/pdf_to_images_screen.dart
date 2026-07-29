import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/widgets.dart';
import '../shared/widgets/document_preview_card.dart';
import '../shared/widgets/tool_action_footer.dart';
import 'controller/pdf_to_images_controller.dart';
import 'widgets/pdf_to_images_options_card.dart';

class PdfToImagesScreen extends StatelessWidget {
  const PdfToImagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => sl<PdfToImagesController>(),
      child: const _PdfToImagesScreenContent(),
    );
  }
}

class _PdfToImagesScreenContent extends StatelessWidget {
  const _PdfToImagesScreenContent();

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<PdfToImagesController>();
    final hasJob = ctrl.activeJob != null;

    return DastraToolPage(
      title: 'PDF to Images',
      icon: Icons.image_search_rounded,
      hasContent: hasJob,
      emptyState: AppEmptyState(
        onPickFiles: ctrl.pickFile,
        title: 'Select PDF to Rasterize',
        subtitle: 'Extract high-quality images from a PDF file.',
        icon: Icons.image_search_rounded,
      ),
      primaryContent: const _PdfSource(),
      configurationPanel: const SingleChildScrollView(
        padding: EdgeInsets.all(24.0),
        child: PdfToImagesOptionsCard(),
      ),
      primaryAction: ToolActionFooter(
        onPressed: ctrl.canConvert && ctrl.outputConfig != null ? ctrl.convertToImages : null,
        isProcessing: ctrl.isProcessing,
        icon: Icons.image_search_rounded,
        label: 'Extract Images',
        processingLabel: 'Extracting...',
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
    final ctrl = context.watch<PdfToImagesController>();
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
                'Selected Document',
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
