import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/utils/file_launcher.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../image/image_compressor/utils/compression_utils.dart';
import '../model/success_screen_data.dart';

class SuccessScreenWidget extends StatelessWidget {
  final SuccessScreenData data;
  final VoidCallback onConvertAnother;

  const SuccessScreenWidget({
    super.key,
    required this.data,
    required this.onConvertAnother,
  });

  @override
  Widget build(BuildContext context) {
    final showCompression = data.percentageReduction > 0;

    return DastraCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            color: context.colors.success,
            size: 64,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Conversion Successful',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.colors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          
          _buildStatRow(context, 'Output File', data.outputFilename),
          const SizedBox(height: AppSpacing.sm),
          _buildStatRow(context, 'Original Size', CompressionUtils.formatBytes(data.originalSizeBytes)),
          const SizedBox(height: AppSpacing.sm),
          _buildStatRow(context, 'Final Size', CompressionUtils.formatBytes(data.finalSizeBytes)),
          
          if (showCompression) ...[
            const SizedBox(height: AppSpacing.sm),
            _buildStatRow(
              context,
              'Reduced By',
              '${data.percentageReduction.toStringAsFixed(1)}%',
              valueColor: context.colors.success,
            ),
          ],
          
          const SizedBox(height: AppSpacing.sm),
          _buildStatRow(context, 'Processing Time', '${(data.processingTimeMs / 1000).toStringAsFixed(1)}s'),
          
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: DastraButton(
                  onTap: () => _openFolder(data.outputPath),
                  icon: Icons.folder_open_rounded,
                  label: 'Open Folder',
                  type: DastraButtonType.secondary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: DastraButton(
                  onTap: () => _openFile(data.outputPath),
                  icon: Icons.file_open_rounded,
                  label: 'Open File',
                  type: DastraButtonType.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          DastraButton(
            onTap: onConvertAnother,
            icon: Icons.refresh_rounded,
            label: 'Convert Another File',
            type: DastraButtonType.ghost,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: context.colors.textSecondary,
            fontSize: 15,
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: valueColor ?? context.colors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Future<void> _openFile(String path) async {
    await FileLauncher.openFile(path);
  }

  Future<void> _openFolder(String path) async {
    final file = File(path);
    final dir = file.parent;
    await FileLauncher.openFolder(dir.absolute.path);
  }
}
