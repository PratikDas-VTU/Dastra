import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../controller/password_generator_controller.dart';

class ImproveInputsCard extends StatelessWidget {
  const ImproveInputsCard({super.key});

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
              Icon(Icons.security_update_good_rounded, size: 20, color: context.colors.accentBlue),
              const SizedBox(width: AppSpacing.sm),
              Text('Improve Existing Password', style: context.textStyles.h4),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Enter an existing weak password. Dastra will intelligently strengthen it while keeping it familiar.',
            style: context.textStyles.caption.copyWith(color: context.colors.textMuted),
          ),
          const SizedBox(height: AppSpacing.lg),
          
          Text('Existing Password', style: context.textStyles.labelMedium),
          const SizedBox(height: AppSpacing.xs),
          TextFormField(
            initialValue: ctrl.settings.existingPasswordToImprove,
            onChanged: (val) => context.read<PasswordGeneratorController>().setExistingPasswordToImprove(val),
            style: context.textStyles.bodyMedium,
            decoration: InputDecoration(
              hintText: 'e.g. password123',
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
      ),
    );
  }
}
