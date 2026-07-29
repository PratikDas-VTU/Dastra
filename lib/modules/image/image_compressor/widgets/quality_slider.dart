// Quality customization sliders for custom preset.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme.dart';
import '../controller/image_compressor_controller.dart';
import '../services/image_compressor_service.dart';

class QualitySlider extends StatelessWidget {
  const QualitySlider({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<ImageCompressorController>();

    final showJpgSlider = ctrl.preset == CompressionPreset.custom;
    final showPngSlider = ctrl.preset == CompressionPreset.custom;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showJpgSlider) ...[
          Row(
            children: [
              Text('JPEG Quality', style: context.textStyles.bodySmall.copyWith(
                color: context.colors.textSecondary,
              )),
              const Spacer(),
              Text(
                '${ctrl.jpgQuality}%',
                style: context.textStyles.labelSmall.copyWith(color: context.colors.accentBlue),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 2,
              thumbColor: context.colors.accentBlue,
              activeTrackColor: context.colors.accentBlue,
              inactiveTrackColor: context.colors.border,
              overlayColor: context.colors.accentBlue.withValues(alpha: 0.12),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            ),
            child: Slider(
              value: ctrl.jpgQuality.toDouble(),
              min: 5,
              max: 100,
              divisions: 95,
              onChanged: ctrl.isCompressing ? null : (v) => ctrl.setJpgQuality(v.round()),
            ),
          ),
          const SizedBox(height: 6),
        ],
        if (showPngSlider) ...[
          Row(
            children: [
              Text('PNG Compression Level', style: context.textStyles.bodySmall.copyWith(
                color: context.colors.textSecondary,
              )),
              const Spacer(),
              Text(
                _pngLevelText(ctrl.pngLevel),
                style: context.textStyles.labelSmall.copyWith(color: context.colors.accentBlue),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 2,
              thumbColor: context.colors.accentBlue,
              activeTrackColor: context.colors.accentBlue,
              inactiveTrackColor: context.colors.border,
              overlayColor: context.colors.accentBlue.withValues(alpha: 0.12),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            ),
            child: Slider(
              value: ctrl.pngLevel.toDouble(),
              min: 0,
              max: 9,
              divisions: 9,
              onChanged: ctrl.isCompressing ? null : (v) => ctrl.setPngLevel(v.round()),
            ),
          ),
        ],
      ],
    );
  }

  String _pngLevelText(int level) {
    if (level == 0) return '0 (None)';
    if (level <= 3) return '$level (Low)';
    if (level <= 6) return '$level (Medium)';
    if (level <= 8) return '$level (High)';
    return '$level (Max)';
  }
}
