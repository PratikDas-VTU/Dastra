// Presets selector card for image compression: Lossless, High, Balanced, Maximum, Custom.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../controller/image_compressor_controller.dart';
import '../services/image_compressor_service.dart';
import 'quality_slider.dart';

class CompressionOptionsCard extends StatelessWidget {
  const CompressionOptionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<ImageCompressorController>();
    final preset = ctrl.preset;

    return DastraCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tune_rounded, size: 20, color: context.colors.accentBlue),
              const SizedBox(width: AppSpacing.sm),
              Text('Compression Settings', style: context.textStyles.h4),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // Preset options
          Text('Preset Mode', style: context.textStyles.bodySmall.copyWith(
            color: context.colors.textSecondary,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          )),
          const SizedBox(height: AppSpacing.md),
          _PresetGrid(selectedPreset: preset),
          const SizedBox(height: AppSpacing.xl),

          // Render Quality settings sliders
          const QualitySlider(),
          const SizedBox(height: AppSpacing.xl),
          Divider(height: 1, color: context.colors.border),
          const SizedBox(height: AppSpacing.xl),

          // Save directory path configuration
          Row(
            children: [
              Text('Save Folder', style: context.textStyles.bodySmall.copyWith(
                color: context.colors.textSecondary,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              )),
              const Spacer(),
              if (ctrl.customOutputFolder != null)
                TextButton(
                  onPressed: ctrl.isCompressing ? null : ctrl.resetOutputFolder,
                  style: TextButton.styleFrom(
                    foregroundColor: context.colors.error,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text('Reset', style: context.textStyles.labelSmall.copyWith(
                    color: context.colors.error,
                    fontWeight: FontWeight.w600,
                  )),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          InkWell(
            onTap: ctrl.isCompressing ? null : ctrl.selectOutputFolder,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
              decoration: BoxDecoration(
                color: context.colors.background,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(color: context.colors.border),
              ),
              child: Row(
                children: [
                  Icon(Icons.folder_open_rounded, size: 18, color: context.colors.textSecondary),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      ctrl.customOutputFolder ?? 'Downloads (Default)',
                      style: context.textStyles.bodyMedium.copyWith(
                        color: ctrl.customOutputFolder != null
                            ? context.colors.textPrimary
                            : context.colors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Icon(Icons.chevron_right_rounded, size: 18, color: context.colors.textSecondary),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }
}

class _PresetGrid extends StatelessWidget {
  const _PresetGrid({required this.selectedPreset});
  final CompressionPreset selectedPreset;

  @override
  Widget build(BuildContext context) {
    final ctrl = context.read<ImageCompressorController>();

    final presets = [
      const _PresetItem(preset: CompressionPreset.lossless, label: 'Lossless', desc: 'PNG only'),
      const _PresetItem(preset: CompressionPreset.highQuality, label: 'High Quality', desc: '90% Quality'),
      const _PresetItem(preset: CompressionPreset.balanced, label: 'Balanced', desc: '75% Quality'),
      const _PresetItem(preset: CompressionPreset.maxCompression, label: 'Max Comp', desc: '45% Quality'),
      const _PresetItem(preset: CompressionPreset.custom, label: 'Custom', desc: 'Configure'),
    ];

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: presets.map((item) {
        final isSelected = selectedPreset == item.preset;
        return GestureDetector(
          onTap: () => ctrl.setPreset(item.preset),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? context.colors.accentBlue.withValues(alpha: 0.1) : context.colors.background,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(
                color: isSelected ? context.colors.accentBlue : context.colors.border,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.label,
                  style: context.textStyles.labelSmall.copyWith(
                    color: isSelected ? context.colors.accentBlue : context.colors.textPrimary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.desc,
                  style: context.textStyles.bodySmall.copyWith(
                    color: isSelected ? context.colors.accentBlue.withValues(alpha: 0.8) : context.colors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _PresetItem {
  const _PresetItem({
    required this.preset,
    required this.label,
    required this.desc,
  });
  final CompressionPreset preset;
  final String label;
  final String desc;
}
