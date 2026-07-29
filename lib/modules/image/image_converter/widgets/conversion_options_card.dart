// Global options settings: overall format target, quality factor, custom output path selector.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../controller/image_converter_controller.dart';

class ConversionOptionsCard extends StatelessWidget {
  const ConversionOptionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<ImageConverterController>();
    final target = ctrl.targetFormat;
    final isJpg = target == 'jpg';

    return DastraCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.settings_suggest_rounded, size: 20, color: context.colors.accentBlue),
              const SizedBox(width: AppSpacing.sm),
              Text('Convert Options', style: context.textStyles.h4),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // Target format row selection
          Text('Global Target Format', style: context.textStyles.bodySmall.copyWith(
            color: context.colors.textSecondary,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          )),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _FormatSelectButton(
                  label: 'Convert to PNG',
                  selected: target == 'png',
                  onTap: () => ctrl.setTargetFormat('png'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _FormatSelectButton(
                  label: 'Convert to JPG',
                  selected: target == 'jpg',
                  onTap: () => ctrl.setTargetFormat('jpg'),
                ),
              ),
            ],
          ),

          // Slider for quality (only visible if converting to JPG)
          if (isJpg) ...[
            const SizedBox(height: AppSpacing.xl),
            Divider(height: 1, color: context.colors.border),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Text('JPG Quality', style: context.textStyles.bodySmall.copyWith(
                  color: context.colors.textSecondary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                )),
                const Spacer(),
                Text(
                  '${ctrl.quality}%',
                  style: context.textStyles.h4.copyWith(color: context.colors.accentBlue),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 4,
                  thumbColor: context.colors.accentBlue,
                  activeTrackColor: context.colors.accentBlue,
                  inactiveTrackColor: context.colors.border,
                  overlayColor: context.colors.accentBlue.withValues(alpha: 0.12),
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                ),
                child: Slider(
                  value: ctrl.quality.toDouble(),
                  min: 10,
                  max: 100,
                  divisions: 90,
                  onChanged: ctrl.isConverting ? null : (v) => ctrl.setQuality(v.round()),
                ),
              ),
            ],

          const SizedBox(height: AppSpacing.xl),
          Divider(height: 1, color: context.colors.border),
          const SizedBox(height: AppSpacing.xl),

          // Output folder path choice
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
                  onPressed: ctrl.isConverting ? null : ctrl.resetOutputFolder,
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
            onTap: ctrl.isConverting ? null : ctrl.selectOutputFolder,
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

class _FormatSelectButton extends StatelessWidget {
  const _FormatSelectButton({
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? context.colors.accentBlue.withValues(alpha: 0.1) : context.colors.background,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
            color: selected ? context.colors.accentBlue : context.colors.border,
            width: 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: context.textStyles.labelSmall.copyWith(
            color: selected ? context.colors.accentBlue : context.colors.textPrimary,
            fontWeight: selected ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
