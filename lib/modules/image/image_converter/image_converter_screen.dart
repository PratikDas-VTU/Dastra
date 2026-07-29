import '../../../../core/widgets/widgets.dart';
// Main UI Screen for JPG ↔ PNG Converter Module.
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/file_launcher.dart';
import '../../../core/theme/theme.dart';
import '../../document/shared/widgets/tool_header_action.dart';
import '../../document/shared/widgets/tool_action_footer.dart';
import 'controller/image_converter_controller.dart';
import '../../../../core/widgets/app_empty_state.dart';

import 'widgets/image_preview_card.dart';
import 'widgets/conversion_options_card.dart';
import 'widgets/progress_card.dart';

class ImageConverterScreen extends StatelessWidget {
  const ImageConverterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ImageConverterController(),
      child: const _ImageConverterContent(),
    );
  }
}

class _ImageConverterContent extends StatelessWidget {
  const _ImageConverterContent();

  Future<void> _openOutputFolder(ImageConverterController ctrl) async {
    final dirPath = await ctrl.getEffectiveOutputDir();
    await FileLauncher.openFolder(dirPath);
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<ImageConverterController>();
    final isNarrow = MediaQuery.of(context).size.width <= 900;
    debugPrint('[TRACE-UI] _ImageConverterContent rebuild. hasJobs: ${ctrl.hasJobs}, jobs count: ${ctrl.jobs.length}');

    return DastraToolPage(
      title: 'JPG ↔ PNG Converter',
      icon: Icons.swap_horiz_rounded,
      headerGradient: AppGradients.image,
      hasContent: ctrl.hasJobs,
      onFilesDropped: ctrl.addImages,
      emptyState: AppEmptyState(
        title: 'Convert Images',
        subtitle: 'Drag and drop or select images to convert',
        icon: Icons.image_rounded,
        onPickFiles: ctrl.pickImages,
      ),
      actions: [
        if (ctrl.hasJobs && !ctrl.isConverting)
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded),
            color: context.colors.error,
            tooltip: 'Clear All',
            onPressed: ctrl.clearJobs,
          ),
        const SizedBox(width: AppSpacing.xs),
      ],
      onBackPressed: ctrl.isConverting
          ? null
          : () {
              if (context.canPop()) {
                context.pop();
              }
            },
      primaryContentHeader: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
        child: Row(
          children: [
            ToolHeaderAction(
              label: 'Add Images',
              icon: Icons.add_photo_alternate_rounded,
              onPressed: ctrl.isConverting ? null : ctrl.pickImages,
              tooltip: 'Add More Images',
            ),
          ],
        ),
      ),
      primaryContent: ListView.builder(
        shrinkWrap: isNarrow,
        physics: isNarrow ? const NeverScrollableScrollPhysics() : const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.xl),
        itemCount: ctrl.jobs.length,
        itemBuilder: (context, index) {
          return ImagePreviewCard(job: ctrl.jobs[index]);
        },
      ),
      configurationPanel: SingleChildScrollView(
        physics: isNarrow ? const NeverScrollableScrollPhysics() : const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            const ConversionOptionsCard(),
            const SizedBox(height: AppSpacing.md),
            const ProgressCard(),
            if (ctrl.isAllCompleted) ...[
              const SizedBox(height: AppSpacing.sm),
              _OpenFolderButton(onTap: () => _openOutputFolder(ctrl)),
            ],
          ],
        ),
      ),
      primaryAction: ToolActionFooter(
        onPressed: ctrl.isConverting ? null : ctrl.startConversion,
        isProcessing: ctrl.isConverting,
        icon: Icons.swap_horiz_rounded,
        label: 'Convert Images',
        processingLabel: 'Converting...',
        gradient: AppGradients.image,
      ),
    );
  }
}

// ── Open Folder Action Button ────────────────────────────────────────────────

class _OpenFolderButton extends StatelessWidget {
  const _OpenFolderButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) return const SizedBox.shrink();

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.folder_shared_rounded, size: 16),
        label: const Text('Open Output Folder'),
        style: OutlinedButton.styleFrom(
          foregroundColor: context.colors.accentBlue,
          side: BorderSide(color: context.colors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.05, end: 0);
  }
}
