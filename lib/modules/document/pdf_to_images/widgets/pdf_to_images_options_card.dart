import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../image/image_compressor/utils/compression_utils.dart';
import '../controller/pdf_to_images_controller.dart';
import '../model/pdf_to_images_config.dart';
import '../../images_to_pdf/model/images_to_pdf_config.dart' show PdfQuality;
import '../../shared/widgets/output_settings_card.dart';
import '../../shared/widgets/conversion_result_card.dart';

class PdfToImagesOptionsCard extends StatelessWidget {
  const PdfToImagesOptionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<PdfToImagesController>();
    final config = ctrl.config;

    if (ctrl.resultData != null) {
      return ConversionResultCard(
        data: ctrl.resultData!,
        onConvertAnother: ctrl.removeFile,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (ctrl.outputConfig != null) ...[
          OutputSettingsCard(
            config: ctrl.outputConfig!,
            onChanged: ctrl.updateOutputConfig,
            onPickFolder: ctrl.pickOutputFolder,
            fileExtension: '', // Can be .zip or .png/.jpg depending on output
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
                  Icon(Icons.settings_suggest_rounded, color: context.colors.accentBlue, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Export Settings',
                    style: context.textStyles.h4,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

                // --- Summary Section ---
                if (ctrl.activeJob != null) ...[
                  DastraCard(
                    padding: EdgeInsets.all(AppSpacing.md),
                    backgroundColor: context.colors.background,
                    child: Column(
                      children: [
                        _buildSummaryRow(context, 'Original Size', CompressionUtils.formatBytes(ctrl.activeJob!.fileSize)),
                        SizedBox(height: AppSpacing.sm),
                        Divider(color: context.colors.border, height: 1),
                        SizedBox(height: AppSpacing.sm),
                        _buildSummaryRow(context, 'Total Pages', '${ctrl.activeJob!.pageCount ?? 0}'),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.xl),
                ],
                // --- End Summary Section ---
                
                _buildSectionTitle(context, 'Page Range'),
                DastraCard(
                  padding: EdgeInsets.zero,
                  backgroundColor: context.colors.background,
                  child: Column(
                    children: [
                      // ignore: deprecated_member_use
                      RadioListTile<bool>(
                        title: Text('All Pages', style: context.textStyles.bodyMedium.copyWith(color: context.colors.textPrimary)),
                        value: false,
                        groupValue: ctrl.isCustomRangeSelected,
                        activeColor: context.colors.accentBlue,
                        onChanged: (val) => ctrl.toggleRangeMode(val!),
                      ),
                      Divider(color: context.colors.border, height: 1),
                      // ignore: deprecated_member_use
                      RadioListTile<bool>(
                        title: Text('Custom Range', style: context.textStyles.bodyMedium.copyWith(color: context.colors.textPrimary)),
                        value: true,
                        groupValue: ctrl.isCustomRangeSelected,
                        activeColor: context.colors.accentBlue,
                        onChanged: (val) => ctrl.toggleRangeMode(val!),
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(AppRadius.md))),
                      ),
                      if (ctrl.isCustomRangeSelected)
                        Padding(
                          padding: const EdgeInsets.only(left: AppSpacing.md, right: AppSpacing.md, bottom: AppSpacing.md),
                          child: TextField(
                            style: context.textStyles.bodyMedium.copyWith(color: context.colors.textPrimary),
                            decoration: InputDecoration(
                              hintText: 'e.g., 1, 3-5, 8',
                              hintStyle: context.textStyles.bodyMedium.copyWith(color: context.colors.textSecondary),
                              isDense: true,
                              filled: true,
                              fillColor: context.colors.surface,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppRadius.sm),
                                borderSide: BorderSide(color: context.colors.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppRadius.sm),
                                borderSide: BorderSide(color: context.colors.border),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppRadius.sm),
                                borderSide: BorderSide(color: context.colors.accentBlue),
                              ),
                            ),
                            onChanged: ctrl.setCustomRange,
                          ).animate().fadeIn(duration: 200.ms),
                        ),
                    ],
                  ),
                ),
                
                SizedBox(height: AppSpacing.xl),
                _buildSectionTitle(context, 'Image Format'),
                _buildDropdown<OutputImageFormat>(context: context, value: config.format,
                  items: const [
                    DropdownMenuItem(value: OutputImageFormat.png, child: Text('PNG (Lossless)')),
                    DropdownMenuItem(value: OutputImageFormat.jpg, child: Text('JPG (Smaller size)')),
                  ],
                  onChanged: (val) => ctrl.updateConfig(config.copyWith(format: val)),
                ),
                
                if (config.format == OutputImageFormat.jpg) ...[
                  _buildSectionTitle(context, 'JPG Quality'),
                  _buildDropdown<PdfQuality>(context: context, value: config.quality,
                    items: const [
                      DropdownMenuItem(value: PdfQuality.high, child: Text('High Quality (100%)')),
                      DropdownMenuItem(value: PdfQuality.medium, child: Text('Medium Quality (70%)')),
                      DropdownMenuItem(value: PdfQuality.smallFile, child: Text('Small File (40%)')),
                    ],
                    onChanged: (val) => ctrl.updateConfig(config.copyWith(quality: val)),
                  ),
                ],
                
                _buildSectionTitle(context, 'Resolution (DPI)'),
                _buildDropdown<OutputDpi>(context: context, value: config.dpi,
                  items: const [
                    DropdownMenuItem(value: OutputDpi.dpi72, child: Text('72 DPI (Web quality)')),
                    DropdownMenuItem(value: OutputDpi.dpi150, child: Text('150 DPI (Standard)')),
                    DropdownMenuItem(value: OutputDpi.dpi300, child: Text('300 DPI (Print quality)')),
                    DropdownMenuItem(value: OutputDpi.dpi600, child: Text('600 DPI (High Res)')),
                  ],
                  onChanged: (val) => ctrl.updateConfig(config.copyWith(dpi: val)),
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
