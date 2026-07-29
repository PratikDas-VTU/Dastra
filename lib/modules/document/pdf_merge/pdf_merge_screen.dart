import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/di/service_locator.dart';
import 'controller/pdf_merge_controller.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/widgets.dart';
import '../shared/widgets/tool_header_action.dart';
import '../shared/widgets/tool_action_footer.dart';
import '../shared/widgets/inline_validation_alert.dart';
import 'widgets/pdf_merge_options_card.dart';
import '../shared/widgets/document_preview_card.dart';

class PdfMergeScreen extends StatelessWidget {
  const PdfMergeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => sl<PdfMergeController>(),
      child: const _PdfMergeContent(),
    );
  }
}

class _PdfMergeContent extends StatelessWidget {
  const _PdfMergeContent();

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<PdfMergeController>();

    return DastraToolPage(
      title: 'Merge PDF',
      icon: Icons.picture_as_pdf_rounded,
      hasContent: ctrl.hasJobs,
      actions: [
        if (ctrl.hasJobs)
          IconButton(
            icon: Icon(Icons.delete_sweep_rounded, color: context.colors.error),
            onPressed: ctrl.isMerging ? null : ctrl.clearJobs,
            tooltip: 'Clear All',
          ),
        const SizedBox(width: 8),
      ],
      emptyState: AppEmptyState(
        onPickFiles: ctrl.pickFiles,
        title: 'Select PDFs to Merge',
        subtitle: 'Choose multiple PDF files to combine them into a single document.',
      ),
      primaryContentHeader: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (ctrl.jobs.length == 1)
            const InlineValidationAlert(
              message: 'Select at least two PDF files to merge them.',
              icon: Icons.library_add_rounded,
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Row(
              children: [
                ToolHeaderAction(
                  label: 'Add Files',
                  icon: Icons.add_rounded,
                  onPressed: ctrl.isMerging ? null : ctrl.pickFiles,
                  tooltip: 'Add more PDFs',
                ),
              ],
            ),
          ),
        ],
      ),
      primaryContent: const _PdfList(),
      configurationPanel: const SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: PdfMergeOptionsCard(),
      ),
      primaryAction: ToolActionFooter(
        onPressed: ctrl.canMerge && ctrl.outputConfig != null ? ctrl.mergePdfs : null,
        isProcessing: ctrl.isMerging,
        icon: Icons.merge_rounded,
        label: 'Merge PDFs',
        processingLabel: 'Merging...',
      ),
      primaryFlex: 2,
      configurationFlex: 1,
       // use flex
    );
  }
}

class _PdfList extends StatelessWidget {
  final bool isNarrow;
  const _PdfList() : isNarrow = false;

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<PdfMergeController>();
    
    // We use ReorderableListView for drag-and-drop arrangement
    return Padding(
      padding: EdgeInsets.all(isNarrow ? 0 : 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selected Documents',
            style: TextStyle(
              color: context.colors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Drag to reorder how they will be merged.',
            style: TextStyle(
              color: context.colors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          if (isNarrow)
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: true,
              itemCount: ctrl.jobs.length,
              onReorderItem: ctrl.reorderJobs,
              proxyDecorator: _proxyDecorator,
              itemBuilder: (context, index) => _buildItem(ctrl, index),
            )
          else
            Expanded(
              child: ReorderableListView.builder(
                physics: const BouncingScrollPhysics(),
                buildDefaultDragHandles: true,
                itemCount: ctrl.jobs.length,
                onReorderItem: ctrl.reorderJobs,
                proxyDecorator: _proxyDecorator,
                itemBuilder: (context, index) => _buildItem(ctrl, index),
              ),
            ),
        ],
      ),
    );
  }

  Widget _proxyDecorator(Widget child, int index, Animation<double> animation) {
    return Material(
      elevation: 8,
      color: Colors.transparent,
      shadowColor: Colors.black26,
      child: child,
    );
  }

  Widget _buildItem(PdfMergeController ctrl, int index) {
    final job = ctrl.jobs[index];
    return Padding(
      key: ValueKey(job.id),
      padding: const EdgeInsets.only(bottom: 12),
      child: DocumentPreviewCard(
        job: job,
        isReorderable: true,
        onRemove: ctrl.isMerging ? () {} : () => ctrl.removeJob(job.id),
      ),
    );
  }
}
