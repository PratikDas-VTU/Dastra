// Layout choices to resize inputs: original, 50%, 75% or custom dimensions.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../controller/image_compressor_controller.dart';
import '../services/image_compressor_service.dart';

class ResizeOptionsCard extends StatefulWidget {
  const ResizeOptionsCard({super.key});

  @override
  State<ResizeOptionsCard> createState() => _ResizeOptionsCardState();
}

class _ResizeOptionsCardState extends State<ResizeOptionsCard> {
  late TextEditingController _wCtrl;
  late TextEditingController _hCtrl;

  @override
  void initState() {
    super.initState();
    final ctrl = context.read<ImageCompressorController>();
    _wCtrl = TextEditingController(text: ctrl.customWidth?.toString() ?? '');
    _hCtrl = TextEditingController(text: ctrl.customHeight?.toString() ?? '');
  }

  @override
  void dispose() {
    _wCtrl.dispose();
    _hCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<ImageCompressorController>();
    final mode = ctrl.resizeMode;
    final isCustom = mode == ResizeMode.custom;

    return DastraCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.aspect_ratio_rounded, size: 20, color: context.colors.accentBlue),
              const SizedBox(width: AppSpacing.sm),
              Text('Resize Options', style: context.textStyles.h4),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

            // Options presets
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                _ModeButton(label: 'Original', selected: mode == ResizeMode.original, onTap: () => ctrl.setResizeMode(ResizeMode.original)),
                _ModeButton(label: '50% Size', selected: mode == ResizeMode.scale50, onTap: () => ctrl.setResizeMode(ResizeMode.scale50)),
                _ModeButton(label: '75% Size', selected: mode == ResizeMode.scale75, onTap: () => ctrl.setResizeMode(ResizeMode.scale75)),
                _ModeButton(label: 'Custom', selected: mode == ResizeMode.custom, onTap: () => ctrl.setResizeMode(ResizeMode.custom)),
              ],
            ),

            if (isCustom) ...[
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Width (px)', style: context.textStyles.bodySmall.copyWith(
                          color: context.colors.textSecondary,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        )),
                        const SizedBox(height: AppSpacing.xs),
                        TextField(
                          controller: _wCtrl,
                          keyboardType: TextInputType.number,
                          style: context.textStyles.bodyMedium.copyWith(color: context.colors.textPrimary),
                          decoration: InputDecoration(
                            hintText: 'Auto',
                            hintStyle: context.textStyles.bodyMedium.copyWith(color: context.colors.textSecondary),
                            filled: true,
                            fillColor: context.colors.background,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 10),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.sm), borderSide: BorderSide(color: context.colors.border)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.sm), borderSide: BorderSide(color: context.colors.border)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.sm), borderSide: BorderSide(color: context.colors.accentBlue)),
                          ),
                          onChanged: (val) {
                            final parsed = int.tryParse(val);
                            ctrl.setCustomWidth(parsed);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Height (px)', style: context.textStyles.bodySmall.copyWith(
                          color: context.colors.textSecondary,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        )),
                        const SizedBox(height: AppSpacing.xs),
                        TextField(
                          controller: _hCtrl,
                          keyboardType: TextInputType.number,
                          style: context.textStyles.bodyMedium.copyWith(color: context.colors.textPrimary),
                          decoration: InputDecoration(
                            hintText: 'Auto',
                            hintStyle: context.textStyles.bodyMedium.copyWith(color: context.colors.textSecondary),
                            filled: true,
                            fillColor: context.colors.background,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 10),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.sm), borderSide: BorderSide(color: context.colors.border)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.sm), borderSide: BorderSide(color: context.colors.border)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.sm), borderSide: BorderSide(color: context.colors.accentBlue)),
                          ),
                          onChanged: (val) {
                            final parsed = int.tryParse(val);
                            ctrl.setCustomHeight(parsed);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: ctrl.maintainAspectRatio,
                      activeColor: context.colors.accentBlue,
                      onChanged: (val) => ctrl.setMaintainAspectRatio(val ?? true),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text('Maintain Aspect Ratio', style: context.textStyles.bodyMedium.copyWith(color: context.colors.textPrimary)),
                ],
              ),
            ].animate().fadeIn(duration: 200.ms),
          ],
        ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? context.colors.accentBlue.withValues(alpha: 0.1) : context.colors.background,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
            color: selected ? context.colors.accentBlue : context.colors.border,
            width: 1,
          ),
        ),
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
