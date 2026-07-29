import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../controller/password_generator_controller.dart';

class PersonalizedInputsCard extends StatelessWidget {
  const PersonalizedInputsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<PasswordGeneratorController>();
    
    return DastraCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_outline_rounded, size: 20, color: context.colors.accentBlue),
              const SizedBox(width: AppSpacing.sm),
              Text('Personalized Inputs', style: context.textStyles.h4),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Provide memorable inputs. The generator will securely combine and transform them.',
            style: context.textStyles.caption.copyWith(color: context.colors.textMuted),
          ),
          const SizedBox(height: AppSpacing.lg),
          
          _InputField(
            label: 'Name / Nickname',
            hint: 'e.g. Pratik',
            initialValue: ctrl.settings.personalizedName,
            onChanged: (val) => context.read<PasswordGeneratorController>().setPersonalizedName(val),
          ),
          const SizedBox(height: AppSpacing.md),
          _InputField(
            label: 'Favourite Word',
            hint: 'e.g. Orbit',
            initialValue: ctrl.settings.personalizedWord,
            onChanged: (val) => context.read<PasswordGeneratorController>().setPersonalizedWord(val),
          ),
          const SizedBox(height: AppSpacing.md),
          _InputField(
            label: 'Lucky Number',
            hint: 'e.g. 27',
            initialValue: ctrl.settings.personalizedNumber,
            onChanged: (val) => context.read<PasswordGeneratorController>().setPersonalizedNumber(val),
          ),
          const SizedBox(height: AppSpacing.md),
          _InputField(
            label: 'Custom Word 1 (Optional)',
            hint: 'e.g. Interstellar',
            initialValue: ctrl.settings.personalizedCustom1,
            onChanged: (val) => context.read<PasswordGeneratorController>().setPersonalizedCustom1(val),
          ),
          const SizedBox(height: AppSpacing.md),
          _InputField(
            label: 'Custom Word 2 (Optional)',
            hint: 'e.g. Nova',
            initialValue: ctrl.settings.personalizedCustom2,
            onChanged: (val) => context.read<PasswordGeneratorController>().setPersonalizedCustom2(val),
          ),
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.label,
    required this.hint,
    required this.initialValue,
    required this.onChanged,
  });

  final String label;
  final String hint;
  final String initialValue;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.textStyles.labelMedium),
        const SizedBox(height: AppSpacing.xs),
        TextFormField(
          initialValue: initialValue,
          onChanged: onChanged,
          style: context.textStyles.bodyMedium,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: context.textStyles.bodyMedium.copyWith(color: context.colors.textMuted),
            isDense: true,
            filled: true,
            fillColor: context.colors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(color: context.colors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(color: context.colors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(color: context.colors.accentBlue),
            ),
          ),
        ),
      ],
    );
  }
}
