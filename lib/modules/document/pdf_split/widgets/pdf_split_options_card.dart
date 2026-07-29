import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../controller/pdf_split_controller.dart';
import '../../shared/widgets/output_settings_card.dart';
import '../../shared/widgets/conversion_result_card.dart';

class PdfSplitOptionsCard extends StatelessWidget {
  const PdfSplitOptionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<PdfSplitController>();

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
            fileExtension: '', // Extension depends on output (zip or pdf)
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
                  Icon(Icons.call_split_rounded, color: context.colors.accentBlue, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Split Options',
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
                      _buildSummaryRow(context, 'Total Source Pages', '${ctrl.activeJob!.pageCount ?? 0}'),
                      SizedBox(height: AppSpacing.sm),
                      Divider(color: context.colors.border, height: 1),
                      SizedBox(height: AppSpacing.sm),
                      _buildSummaryRow(context, 'Estimated Output Files', '${ctrl.estimatedOutputFiles}', highlight: true),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
              // --- End Summary Section ---
                
              _buildRadioOption(
                context,
                title: 'Extract all pages',
                subtitle: 'Every page becomes a separate PDF',
                value: SplitMode.extractAll,
                groupValue: ctrl.splitMode,
                onChanged: (val) => ctrl.setSplitMode(val!),
              ),
                    
                    _buildRadioOption(
                      context,
                      title: 'Custom Ranges',
                      subtitle: 'e.g. 1-3, 5, 8-10',
                      value: SplitMode.customRange,
                      groupValue: ctrl.splitMode,
                      onChanged: (val) => ctrl.setSplitMode(val!),
                    ),
                    if (ctrl.splitMode == SplitMode.customRange)
                      Padding(
                        padding: const EdgeInsets.only(left: AppSpacing.md, right: AppSpacing.md, top: 0, bottom: AppSpacing.md),
                        child: TextField(
                          style: context.textStyles.bodyMedium.copyWith(color: context.colors.textPrimary),
                          decoration: InputDecoration(
                            hintText: '1-3, 5, 8-10',
                            labelText: 'Pages to extract',
                            labelStyle: context.textStyles.bodyMedium.copyWith(color: context.colors.textSecondary),
                            filled: true,
                            fillColor: context.colors.background,
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



                    _buildRadioOption(
                      context,
                      title: 'Fixed Intervals',
                      subtitle: 'Split every N pages',
                      value: SplitMode.fixedInterval,
                      groupValue: ctrl.splitMode,
                      onChanged: (val) => ctrl.setSplitMode(val!),
                    ),
                    if (ctrl.splitMode == SplitMode.fixedInterval)
                      Padding(
                        padding: const EdgeInsets.only(left: AppSpacing.md, right: AppSpacing.md, top: 0, bottom: AppSpacing.md),
                        child: TextField(
                          style: context.textStyles.bodyMedium.copyWith(color: context.colors.textPrimary),
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'e.g. 2',
                            labelText: 'Pages per split',
                            labelStyle: context.textStyles.bodyMedium.copyWith(color: context.colors.textSecondary),
                            filled: true,
                            fillColor: context.colors.background,
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
                          onChanged: ctrl.setInterval,
                        ).animate().fadeIn(duration: 200.ms),
                      ),

              const SizedBox(height: AppSpacing.md),
              
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
                    ],
                  ).animate().fadeIn(),
                ],
              ],
            ),
        ).animate().fadeIn().slideY(begin: 0.1, end: 0),
      ],
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, String value, {bool highlight = false}) {
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
            color: highlight ? context.colors.accentBlue : context.colors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildRadioOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required SplitMode value,
    required SplitMode groupValue,
    required ValueChanged<SplitMode?> onChanged,
  }) {
    final isSelected = value == groupValue;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AnimatedContainer(
        duration: 200.ms,
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: isSelected ? context.colors.accentBlue.withValues(alpha: 0.05) : context.colors.background,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? context.colors.accentBlue : context.colors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: context.colors.accentBlue.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ] : null,
        ),
        child: RadioListTile<SplitMode>(
          title: Text(title, style: context.textStyles.bodyMedium.copyWith(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? context.colors.accentBlue : context.colors.textPrimary,
          )),
          subtitle: Text(subtitle, style: context.textStyles.bodySmall.copyWith(color: context.colors.textSecondary)),
          value: value,
          groupValue: groupValue,
          onChanged: onChanged,
          activeColor: context.colors.accentBlue,
          contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        ),
      ),
    );
  }
}
