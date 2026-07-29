// Card for adjusting password length via slider, +/- buttons, and text input.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../controller/password_generator_controller.dart';

/// Lets the user set the desired password length.
class LengthControlCard extends StatefulWidget {
  const LengthControlCard({super.key});

  @override
  State<LengthControlCard> createState() => _LengthControlCardState();
}

class _LengthControlCardState extends State<LengthControlCard> {
  late TextEditingController _textCtrl;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    final ctrl = context.read<PasswordGeneratorController>();
    _textCtrl = TextEditingController(text: ctrl.settings.length.toString());
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  void _onTextSubmit(PasswordGeneratorController ctrl) {
    final parsed = int.tryParse(_textCtrl.text);
    if (parsed != null) {
      ctrl.setLength(parsed);
      _textCtrl.text = ctrl.settings.length.toString();
    } else {
      _textCtrl.text = ctrl.settings.length.toString();
    }
    setState(() => _editing = false);
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<PasswordGeneratorController>();
    final length = ctrl.settings.length;

    // Sync text field when not actively editing.
    if (!_editing) {
      _textCtrl.text = length.toString();
    }

    return DastraCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: label + numeric value
          Row(
            children: [
              Icon(Icons.straighten_rounded, size: 16, color: context.colors.textMuted),
              const SizedBox(width: AppSpacing.xs),
              Text('Length', style: context.textStyles.labelLarge),
              const Spacer(),
              // Editable numeric field
              SizedBox(
                width: 52,
                child: Focus(
                  onFocusChange: (hasFocus) {
                    if (!hasFocus) _onTextSubmit(ctrl);
                    setState(() => _editing = hasFocus);
                  },
                  child: TextField(
                    controller: _textCtrl,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: context.textStyles.h3.copyWith(color: context.colors.accentBlue),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: context.colors.surface,
                      contentPadding: const EdgeInsets.symmetric(vertical: 6),
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
                        borderSide:
                            BorderSide(color: context.colors.accentBlue, width: 1.5),
                      ),
                    ),
                    onSubmitted: (_) => _onTextSubmit(ctrl),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // ── Slider
          AdaptiveSlider(
            value: length.toDouble(),
            min: 4,
            max: 128,
            divisions: 124,
            onChanged: (v) => ctrl.setLength(v.round()),
          ),

          // ── Min/Max labels + stepper buttons
          Row(
            children: [
              Text('4', style: context.textStyles.caption),
              const Spacer(),
              // Minus
              _StepButton(
                icon: Icons.remove_rounded,
                onTap: () => ctrl.setLength(length - 1),
                enabled: length > 4,
              ),
              const SizedBox(width: AppSpacing.xs),
              // Plus
              _StepButton(
                icon: Icons.add_rounded,
                onTap: () => ctrl.setLength(length + 1),
                enabled: length < 128,
              ),
              const Spacer(),
              Text('128', style: context.textStyles.caption),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.onTap,
    required this.enabled,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(AppRadius.xs),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.xs),
          border: Border.all(
            color: enabled ? context.colors.border : context.colors.borderSubtle,
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: enabled ? context.colors.textSecondary : context.colors.textDisabled,
        ),
      ),
    );
  }
}
