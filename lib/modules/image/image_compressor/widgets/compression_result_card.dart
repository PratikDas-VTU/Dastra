// Itemized compression previews showing compression ratios and savings.
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../model/compression_job.dart';
import '../controller/image_compressor_controller.dart';
import '../utils/compression_utils.dart';

class CompressionResultCard extends StatelessWidget {
  const CompressionResultCard({super.key, required this.job});
  final CompressionJob job;

  @override
  Widget build(BuildContext context) {
    final ctrl = context.read<ImageCompressorController>();

    final hasSavings = job.status == CompressionStatus.success && job.compressedSize != null;
    final ratio = hasSavings ? CompressionUtils.formatRatio(job.compressionRatio) : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: DastraCard(
        padding: const EdgeInsets.all(AppSpacing.sm),
        borderColor: job.status == CompressionStatus.failed
            ? context.colors.error.withValues(alpha: 0.5)
            : null,
        child: Row(
          children: [
            // Thumbnail
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

            // Filename & Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job.fileName,
                    style: context.textStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(job.resolution, style: context.textStyles.caption),
                      const SizedBox(width: 8),
                      Text(
                        CompressionUtils.formatBytes(job.fileSize),
                        style: context.textStyles.caption.copyWith(
                          decoration: hasSavings ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      if (hasSavings) ...[
                        Icon(Icons.arrow_right_alt_rounded, size: 14, color: context.colors.textMuted),
                        Text(
                          CompressionUtils.formatBytes(job.compressedSize!),
                          style: context.textStyles.caption.copyWith(
                            color: context.colors.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            if (job.status == CompressionStatus.pending)
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 18),
                color: context.colors.textMuted,
                onPressed: () => ctrl.removeJob(job.id),
              )
            else ...[
              const SizedBox(width: AppSpacing.sm),
              if (hasSavings)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: context.colors.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    '-$ratio',
                    style: context.textStyles.labelSmall.copyWith(
                      color: context.colors.success,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              const SizedBox(width: AppSpacing.xs),
              _StatusWidget(job: job),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusWidget extends StatelessWidget {
  const _StatusWidget({required this.job});
  final CompressionJob job;

  @override
  Widget build(BuildContext context) {
    switch (job.status) {
      case CompressionStatus.processing:
        return SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(context.colors.accentBlue),
          ),
        );
      case CompressionStatus.success:
        return Tooltip(
          message: 'Saved: ${job.outputPath ?? ""}',
          child: Icon(Icons.check_circle_rounded, color: context.colors.success, size: 20),
        );
      case CompressionStatus.failed:
        return Tooltip(
          message: job.error ?? 'Unknown error',
          child: Icon(Icons.error_rounded, color: context.colors.error, size: 20),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
