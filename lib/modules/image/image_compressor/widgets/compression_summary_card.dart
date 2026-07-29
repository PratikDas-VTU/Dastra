// Final completion statistics: original size vs compressed, average savings ratio, duration.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../controller/image_compressor_controller.dart';
import '../utils/compression_utils.dart';

class CompressionSummaryCard extends StatelessWidget {
  const CompressionSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<ImageCompressorController>();
    if (!ctrl.isAllCompleted) return const SizedBox.shrink();

    final count = ctrl.completedCount;
    final totalOrig = ctrl.totalOriginalSize;
    final totalComp = ctrl.totalCompressedSize;
    final saved = ctrl.totalSpaceSaved;
    final ratio = ctrl.averageCompressionRatio;
    final timeSec = ctrl.processingDuration.inMilliseconds / 1000.0;

    return DastraCard(
      backgroundColor: context.colors.success.withValues(alpha: 0.05),
      borderColor: context.colors.success.withValues(alpha: 0.2),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle_rounded, size: 20, color: context.colors.success),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Compression Completed',
                style: context.textStyles.h4.copyWith(color: context.colors.success),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          _SummaryRow(label: 'Images Processed', value: '$count files'),
          const SizedBox(height: AppSpacing.md),
          _SummaryRow(label: 'Original Size', value: CompressionUtils.formatBytes(totalOrig)),
          const SizedBox(height: AppSpacing.md),
          _SummaryRow(label: 'Compressed Size', value: CompressionUtils.formatBytes(totalComp)),
          const SizedBox(height: AppSpacing.lg),
          Divider(height: 1, color: context.colors.border),
          const SizedBox(height: AppSpacing.lg),
          _SummaryRow(
            label: 'Total Saved Space',
            value: CompressionUtils.formatBytes(saved),
            valueColor: context.colors.success,
            bold: true,
          ),
          const SizedBox(height: AppSpacing.md),
          _SummaryRow(
            label: 'Average Reduction',
            value: '-${CompressionUtils.formatRatio(ratio)}',
            valueColor: context.colors.success,
            bold: true,
          ),
          const SizedBox(height: AppSpacing.md),
          _SummaryRow(label: 'Processing Time', value: '${timeSec.toStringAsFixed(2)}s'),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.bold = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: context.textStyles.bodyMedium.copyWith(color: context.colors.textSecondary),
        ),
        Text(
          value,
          style: context.textStyles.bodyMedium.copyWith(
            color: valueColor ?? context.colors.textPrimary,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
