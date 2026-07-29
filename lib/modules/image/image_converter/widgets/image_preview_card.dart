// Itemized preview cards showing format, dimensions, size, and individual progress.
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../model/conversion_job.dart';
import '../controller/image_converter_controller.dart';

class ImagePreviewCard extends StatelessWidget {
  const ImagePreviewCard({super.key, required this.job});
  final ConversionJob job;

  String _formatBytes(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB"];
    var i = 0;
    double size = bytes.toDouble();
    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    return "${size.toStringAsFixed(1)} ${suffixes[i]}";
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.read<ImageConverterController>();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: DastraCard(
        padding: const EdgeInsets.all(AppSpacing.sm),
        borderColor: job.status == ConversionStatus.failed
            ? context.colors.error.withValues(alpha: 0.5)
            : null,
        child: Row(
          children: [
            // Thumbnail / Icon
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: Container(
                width: 52,
                height: 52,
                color: context.colors.surface,
                child: job.bytes != null
                    ? Image.memory(
                        job.bytes!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.image_outlined,
                          size: 24,
                          color: context.colors.textMuted,
                        ),
                      )
                    : Image.file(
                        File(job.filePath),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.image_outlined,
                          size: 24,
                          color: context.colors.textMuted,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),

            // Metadata info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job.fileName,
                    style: context.textStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        job.originalFormat.toUpperCase(),
                        style: context.textStyles.caption.copyWith(
                          color: context.colors.accentBlue,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(job.resolution, style: context.textStyles.caption),
                      const SizedBox(width: 8),
                      Text(_formatBytes(job.fileSize), style: context.textStyles.caption),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),

            // Target format selector / Status indicator
            if (job.status == ConversionStatus.pending) ...[
              _TargetSelector(job: job),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 18),
                color: context.colors.textMuted,
                tooltip: 'Remove',
                onPressed: () => ctrl.removeJob(job.id),
              ),
            ] else
              _StatusWidget(job: job),
          ],
        ),
      ),
    );
  }
}

// ── Target Selector segment ──────────────────────────────────────────────────

class _TargetSelector extends StatelessWidget {
  const _TargetSelector({required this.job});
  final ConversionJob job;

  @override
  Widget build(BuildContext context) {
    final ctrl = context.read<ImageConverterController>();
    final isPng = job.targetFormat == 'png';

    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SelectorButton(
            label: 'JPG',
            selected: !isPng,
            onTap: () => ctrl.setJobTargetFormat(job.id, 'jpg'),
          ),
          _SelectorButton(
            label: 'PNG',
            selected: isPng,
            onTap: () => ctrl.setJobTargetFormat(job.id, 'png'),
          ),
        ],
      ),
    );
  }
}

class _SelectorButton extends StatelessWidget {
  const _SelectorButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? context.colors.accentBlue.withValues(alpha: 0.15) : null,
          borderRadius: BorderRadius.circular(AppRadius.xs),
        ),
        child: Text(
          label,
          style: context.textStyles.labelSmall.copyWith(
            color: selected ? context.colors.accentBlue : context.colors.textSecondary,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ── Status Widget ────────────────────────────────────────────────────────────

class _StatusWidget extends StatelessWidget {
  const _StatusWidget({required this.job});
  final ConversionJob job;

  @override
  Widget build(BuildContext context) {
    switch (job.status) {
      case ConversionStatus.processing:
        return SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(context.colors.accentBlue),
          ),
        );
      case ConversionStatus.success:
        return Tooltip(
          message: 'Saved to: ${job.outputPath ?? ""}',
          child: Icon(
            Icons.check_circle_rounded,
            color: context.colors.success,
            size: 20,
          ),
        );
      case ConversionStatus.failed:
        return Tooltip(
          message: job.error ?? 'Unknown error',
          child: Icon(
            Icons.error_rounded,
            color: context.colors.error,
            size: 20,
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
