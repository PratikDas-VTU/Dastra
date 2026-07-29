import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../image/image_compressor/utils/compression_utils.dart'; // Reusing formatBytes
import '../controller/images_to_pdf_controller.dart';
import '../model/images_to_pdf_config.dart';
import '../../shared/widgets/output_settings_card.dart';
import '../../shared/widgets/conversion_result_card.dart';

class ImagesToPdfOptionsCard extends StatelessWidget {
  const ImagesToPdfOptionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<ImagesToPdfController>();
    final config = ctrl.config;

    if (ctrl.resultData != null) {
      return ConversionResultCard(
        data: ctrl.resultData!,
        onConvertAnother: ctrl.clearAll,
      );
    }

    // Calculate total size for the summary
    int totalOriginalSize = 0;
    for (var job in ctrl.jobs) {
      totalOriginalSize += job.fileSize;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (ctrl.outputConfig != null) ...[
          OutputSettingsCard(
            config: ctrl.outputConfig!,
            onChanged: ctrl.updateOutputConfig,
            onPickFolder: ctrl.pickOutputFolder,
            fileExtension: '.pdf',
          ).animate().fadeIn().slideY(begin: 0.1, end: 0),
          const SizedBox(height: AppSpacing.xl),
        ],

        DastraCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            Row(
              children: [
                Icon(Icons.tune_rounded, color: context.colors.accentBlue, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'PDF Settings',
                  style: context.textStyles.h4,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            
            // --- Summary Section ---
            if (ctrl.jobs.isNotEmpty) ...[
              DastraCard(
                padding: EdgeInsets.all(AppSpacing.md),
                backgroundColor: context.colors.background,
                child: Column(
                  children: [
                    _buildSummaryRow(context, 'Total Images', '${ctrl.jobs.length}'),
                    SizedBox(height: AppSpacing.sm),
                    Divider(color: context.colors.border, height: 1),
                    SizedBox(height: AppSpacing.sm),
                    _buildSummaryRow(context, 'Original Size', CompressionUtils.formatBytes(totalOriginalSize)),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.xl),
            ],
            // --- End Summary Section ---

                _buildSectionTitle(context, 'Page Size'),
                _buildDropdown<PdfPageSize>(context: context, value: config.pageSize,
                  items: const [
                    DropdownMenuItem(value: PdfPageSize.original, child: Text('Original Image Size')),
                    DropdownMenuItem(value: PdfPageSize.a4, child: Text('A4')),
                    DropdownMenuItem(value: PdfPageSize.letter, child: Text('Letter')),
                    DropdownMenuItem(value: PdfPageSize.legal, child: Text('Legal')),
                  ],
                  onChanged: (val) => ctrl.updateConfig(config.copyWith(pageSize: val)),
                ),
                
                _buildSectionTitle(context, 'Orientation'),
                _buildDropdown<PdfPageOrientation>(context: context, value: config.orientation,
                  items: const [
                    DropdownMenuItem(value: PdfPageOrientation.auto, child: Text('Auto (Based on image)')),
                    DropdownMenuItem(value: PdfPageOrientation.portrait, child: Text('Portrait')),
                    DropdownMenuItem(value: PdfPageOrientation.landscape, child: Text('Landscape')),
                  ],
                  onChanged: (val) => ctrl.updateConfig(config.copyWith(orientation: val)),
                ),
                
                _buildSectionTitle(context, 'Image Fit'),
                _buildDropdown<ImageFitMode>(context: context, value: config.fitMode,
                  items: const [
                    DropdownMenuItem(value: ImageFitMode.fitEntireImage, child: Text('Fit Entire Image')),
                    DropdownMenuItem(value: ImageFitMode.fillPage, child: Text('Fill Page (may crop)')),
                    DropdownMenuItem(value: ImageFitMode.originalSize, child: Text('Original Size')),
                  ],
                  onChanged: (val) => ctrl.updateConfig(config.copyWith(fitMode: val)),
                ),
                
                _buildSectionTitle(context, 'Output Quality'),
                _buildDropdown<PdfQuality>(context: context, value: config.quality,
                  items: const [
                    DropdownMenuItem(value: PdfQuality.high, child: Text('High Quality (No compression)')),
                    DropdownMenuItem(value: PdfQuality.medium, child: Text('Medium Quality')),
                    DropdownMenuItem(value: PdfQuality.smallFile, child: Text('Small File Size')),
                  ],
                  onChanged: (val) => ctrl.updateConfig(config.copyWith(quality: val)),
                ),
                
            SizedBox(height: AppSpacing.md),
            _buildSectionTitle(context, 'Margins: ${config.margin.toInt()} px'),
            Slider(
              value: config.margin,
              min: 0,
              max: 100,
              divisions: 20,
              activeColor: context.colors.accentBlue,
              inactiveColor: context.colors.border,
              onChanged: (val) => ctrl.updateConfig(config.copyWith(margin: val)),
            ),
            
            const SizedBox(height: AppSpacing.xxl),
            
            if (ctrl.isProcessing || ctrl.statusMessage.isNotEmpty) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          ctrl.statusMessage,
                          style: context.textStyles.bodyMedium.copyWith(
                            color: context.colors.accentBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '${(ctrl.progress * 100).toInt()}%',
                        style: context.textStyles.bodyMedium.copyWith(
                          color: context.colors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    child: LinearProgressIndicator(
                      value: ctrl.progress > 0 ? ctrl.progress : null,
                      backgroundColor: context.colors.background,
                      color: context.colors.accentBlue,
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ).animate().fadeIn(),
            ],
            
          ],
        ),
      ).animate().fadeIn().slideY(begin: 0.1, end: 0),
      ],
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, String value) {
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
            color: context.colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: context.textStyles.bodySmall.copyWith(
          color: context.colors.textSecondary,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({required BuildContext context, 
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
        decoration: BoxDecoration(
          color: context.colors.background,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: context.colors.border),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: value,
            isExpanded: true,
            dropdownColor: context.colors.surface,
            style: context.textStyles.bodyMedium.copyWith(color: context.colors.textPrimary),
            items: items,
            onChanged: onChanged,
            icon: Icon(Icons.arrow_drop_down_rounded, color: context.colors.textSecondary),
          ),
        ),
      ),
    );
  }
}
