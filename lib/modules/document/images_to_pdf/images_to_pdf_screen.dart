import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/di/service_locator.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/widgets.dart';
import '../shared/widgets/tool_header_action.dart';
import '../shared/widgets/tool_action_footer.dart';
import 'controller/images_to_pdf_controller.dart';
import 'widgets/image_to_pdf_preview_card.dart';
import 'widgets/images_to_pdf_options_card.dart';

class ImagesToPdfScreen extends StatelessWidget {
  const ImagesToPdfScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => sl<ImagesToPdfController>(),
      child: const _ImagesToPdfScreenContent(),
    );
  }
}

class _ImagesToPdfScreenContent extends StatelessWidget {
  const _ImagesToPdfScreenContent();

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<ImagesToPdfController>();
    final hasJobs = ctrl.jobs.isNotEmpty;

    return DastraToolPage(
      title: 'Images to PDF',
      icon: Icons.photo_library_rounded,
      hasContent: hasJobs,
      actions: [
        if (hasJobs)
          IconButton(
            icon: Icon(Icons.clear_all_rounded, color: context.colors.error),
            onPressed: ctrl.isProcessing ? null : ctrl.clearAll,
            tooltip: 'Clear All',
          ),
        const SizedBox(width: 8),
      ],
      emptyState: AppEmptyState(
        onPickFiles: ctrl.pickFiles,
        title: 'Select Images',
        subtitle: 'Choose multiple JPG or PNG images to combine into a single PDF document.',
        icon: Icons.collections_rounded,
      ),
      primaryContentHeader: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Row(
              children: [
                ToolHeaderAction(
                  label: 'Add Images',
                  icon: Icons.add_photo_alternate_rounded,
                  onPressed: ctrl.isProcessing ? null : ctrl.pickFiles,
                  tooltip: 'Add More Images',
                ),
              ],
            ),
          ),
        ],
      ),
      primaryContent: const _ImageList(),
      configurationPanel: const SingleChildScrollView(
        padding: EdgeInsets.all(24.0),
        child: ImagesToPdfOptionsCard(),
      ),
      primaryAction: ToolActionFooter(
        onPressed: ctrl.canGenerate && ctrl.outputConfig != null ? ctrl.generatePdf : null,
        isProcessing: ctrl.isProcessing,
        icon: Icons.picture_as_pdf_rounded,
        label: 'Create PDF',
        processingLabel: 'Creating...',
      ),
      primaryFlex: 3,
      configurationFlex: 2,
          );
  }
}

class _ImageList extends StatelessWidget {
  const _ImageList();

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<ImagesToPdfController>();
    final isNarrow = MediaQuery.of(context).size.width <= 900;
    
    return Padding(
      padding: EdgeInsets.all(isNarrow ? 0 : 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Selected Images (${ctrl.jobs.length})',
                style: TextStyle(
                  color: context.colors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isNarrow && !ctrl.isProcessing)
                TextButton.icon(
                  onPressed: ctrl.clearAll,
                  icon: const Icon(Icons.clear_all_rounded, size: 18),
                  label: const Text('Clear'),
                  style: TextButton.styleFrom(
                    foregroundColor: context.colors.error,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (isNarrow)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: ctrl.jobs.length,
              itemBuilder: (context, index) {
                final job = ctrl.jobs[index];
                return ImageToPdfPreviewCard(
                  key: ValueKey(job.id),
                  job: job,
                  index: index,
                  onRemove: ctrl.isProcessing ? null : () => ctrl.removeImage(job.id),
                );
              },
            )
          else
            Expanded(
              child: ReorderableListView.builder(
                itemCount: ctrl.jobs.length,
                onReorderItem: ctrl.isProcessing ? (oldIndex, newIndex) {} : ctrl.reorderImages,
                buildDefaultDragHandles: false,
                physics: const BouncingScrollPhysics(),
                proxyDecorator: (child, index, animation) {
                  return Material(
                    color: Colors.transparent,
                    child: child,
                  );
                },
                itemBuilder: (context, index) {
                  final job = ctrl.jobs[index];
                  return ReorderableDragStartListener(
                    key: ValueKey(job.id),
                    index: index,
                    child: ImageToPdfPreviewCard(
                      job: job,
                      index: index,
                      onRemove: ctrl.isProcessing ? null : () => ctrl.removeImage(job.id),
                    ),
                  );
                },
              ),
            ),
          if (isNarrow && !ctrl.isProcessing) ...[
            const SizedBox(height: 16),
            Center(
              child: TextButton.icon(
                onPressed: ctrl.pickFiles,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add More Images'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
