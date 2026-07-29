import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../controller/pdf_compress_controller.dart';
import '../model/pdf_compress_preset.dart';
import '../../shared/widgets/output_settings_card.dart';
import '../../shared/widgets/conversion_result_card.dart';

class PdfCompressOptionsCard extends StatelessWidget {
  const PdfCompressOptionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<PdfCompressController>();

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
            fileExtension: '.pdf',
          ).animate().fadeIn().slideY(begin: 0.1, end: 0),
          const SizedBox(height: AppSpacing.xl),
        ],

        DastraCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Compression Level',
                style: context.textStyles.h4,
              ),
              const SizedBox(height: AppSpacing.md),
              
              ...PdfCompressPreset.values.map((preset) => 
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: AnimatedContainer(
                    duration: 200.ms,
                    curve: Curves.easeOut,
                    decoration: BoxDecoration(
                      color: ctrl.preset == preset ? context.colors.accentBlue.withValues(alpha: 0.05) : context.colors.background,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: ctrl.preset == preset ? context.colors.accentBlue : context.colors.border,
                        width: ctrl.preset == preset ? 2 : 1,
                      ),
                      boxShadow: ctrl.preset == preset ? [
                        BoxShadow(
                          color: context.colors.accentBlue.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ] : null,
                    ),
                    // ignore: deprecated_member_use
                    child: RadioListTile<PdfCompressPreset>(
                      title: Text(preset.label, style: context.textStyles.bodyMedium.copyWith(
                        fontWeight: ctrl.preset == preset ? FontWeight.bold : FontWeight.w600,
                        color: ctrl.preset == preset ? context.colors.accentBlue : context.colors.textPrimary,
                      )),
                      subtitle: Text(preset.description, style: context.textStyles.bodySmall.copyWith(color: context.colors.textSecondary)),
                      value: preset,
                      groupValue: ctrl.preset,
                      onChanged: ctrl.isProcessing ? null : (p) => ctrl.setPreset(p!),
                      activeColor: context.colors.accentBlue,
                      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                    ),
                  ),
                )
              ),
              
              if (ctrl.needsEngineDownload) ...[
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: context.colors.warning.withValues(alpha: 0.1),
                    border: Border.all(color: context.colors.warning.withValues(alpha: 0.5)),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.download_rounded, color: context.colors.warning, size: 32),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Engine Required',
                        style: context.textStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: context.colors.warning),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'The PDF compression engine is not installed. Download it now to proceed.',
                        textAlign: TextAlign.center,
                        style: context.textStyles.bodySmall.copyWith(color: context.colors.textSecondary),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      DastraButton(
                        onTap: ctrl.isProcessing ? null : ctrl.downloadRequiredEngine,
                        label: 'Download Engine',
                        type: DastraButtonType.primary,
                      ),
                    ],
                  ),
                ).animate().fadeIn().slideY(begin: 0.1, end: 0),
              ],
              
              
              if (ctrl.isProcessing || ctrl.statusMessage.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xl),
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
}
