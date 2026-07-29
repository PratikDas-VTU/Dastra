import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../utils/responsive.dart';

class AdaptiveSlider extends StatelessWidget {
  const AdaptiveSlider({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final isMob = isMobile(context);

    return SliderTheme(
      data: SliderThemeData(
        trackHeight: isMob ? 6 : 4,
        thumbColor: context.colors.accentBlue,
        activeTrackColor: context.colors.accentBlue,
        inactiveTrackColor: context.colors.border,
        overlayColor: context.colors.accentBlue.withValues(alpha: 0.12),
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: isMob ? 12 : 8),
        overlayShape: RoundSliderOverlayShape(overlayRadius: isMob ? 24 : 16),
      ),
      child: Slider(
        value: value,
        min: min,
        max: max,
        divisions: divisions,
        onChanged: onChanged,
      ),
    );
  }
}
