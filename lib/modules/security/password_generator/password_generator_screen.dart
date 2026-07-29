// Password Generator Screen — fully functional offline tool.
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/widgets.dart';
import 'controller/password_generator_controller.dart';
import 'widgets/password_display_card.dart';
import 'widgets/strength_indicator_card.dart';
import 'widgets/length_control_card.dart';
import 'widgets/options_card.dart';
import 'widgets/count_selector_card.dart';
import 'widgets/personalized_inputs_card.dart';
import 'widgets/improve_inputs_card.dart';
import 'model/password_settings.dart' show GenerationMode;

class PasswordGeneratorScreen extends StatelessWidget {
  const PasswordGeneratorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PasswordGeneratorController(),
      child: const _PasswordGeneratorContent(),
    );
  }
}

class _PasswordGeneratorContent extends StatelessWidget {
  const _PasswordGeneratorContent();

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<PasswordGeneratorController>();
    final mode = ctrl.mode;

    return DastraToolPage(
      title: 'Password Generator',
      icon: Icons.key_rounded,
      headerGradient: AppGradients.security,
      primaryContentHeader: const _ModeSelector(),
      primaryContent: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            const PasswordDisplayCard(),
            const SizedBox(height: AppSpacing.md),
            if (mode == GenerationMode.random) ...[
              const StrengthIndicatorCard(),
              const SizedBox(height: AppSpacing.md),
              const CountSelectorCard(),
              const SizedBox(height: AppSpacing.md),
            ],
          ],
        ),
      ),
      configurationPanel: DastraConfigurationPanel(
        sections: [
          if (mode == GenerationMode.random) ...[
            const LengthControlCard(),
            const OptionsCard(),
          ] else if (mode == GenerationMode.personalized) ...[
            const PersonalizedInputsCard(),
          ] else if (mode == GenerationMode.improve) ...[
            const ImproveInputsCard(),
          ],
        ],
      ),
      primaryAction: Container(
        decoration: BoxDecoration(
          color: context.colors.surface,
          border: Border(top: BorderSide(color: context.colors.border)),
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: const SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _GenerateButton(),
              SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: _RegenerateButton(isMobile: true),
              ),
            ],
          ),
        ),
      ),
      primaryFlex: 6,
      configurationFlex: 5,
    );
  }
}

// ── Shared Widgets ─────────────────────────────────────────────────────────────

class _ModeSelector extends StatelessWidget {
  const _ModeSelector();

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<PasswordGeneratorController>();
    final mode = ctrl.mode;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(bottom: BorderSide(color: context.colors.border)),
      ),
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SegmentedButton<GenerationMode>(
            segments: const [
              ButtonSegment(
                value: GenerationMode.random,
                icon: Icon(Icons.shuffle_rounded, size: 18),
                label: Text('Random', style: TextStyle(fontSize: 13)),
              ),
              ButtonSegment(
                value: GenerationMode.personalized,
                icon: Icon(Icons.tune_rounded, size: 18),
                label: Text('Custom', style: TextStyle(fontSize: 13)),
              ),
              ButtonSegment(
                value: GenerationMode.improve,
                icon: Icon(Icons.security_update_good_rounded, size: 18),
                label: Text('Improve', style: TextStyle(fontSize: 13)),
              ),
            ],
            selected: {mode},
            onSelectionChanged: (Set<GenerationMode> newSelection) {
              ctrl.setMode(newSelection.first);
            },
            style: SegmentedButton.styleFrom(
              foregroundColor: context.colors.textPrimary,
              selectedForegroundColor: context.colors.accentBlue,
              backgroundColor: context.colors.background,
              selectedBackgroundColor: context.colors.accentBlue.withValues(alpha: 0.1),
              side: BorderSide(color: context.colors.border),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Action Buttons ─────────────────────────────────────────────────────────────

class _GenerateButton extends StatelessWidget {
  const _GenerateButton();

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<PasswordGeneratorController>();
    final mode = ctrl.mode;
    
    final isEmptyCharset = mode == GenerationMode.random && ctrl.isCharsetEmpty;
    final isImproveEmpty = mode == GenerationMode.improve && ctrl.settings.existingPasswordToImprove.trim().isEmpty;
    final isPersonalizedEmpty = mode == GenerationMode.personalized && 
        ctrl.settings.personalizedName.trim().isEmpty &&
        ctrl.settings.personalizedWord.trim().isEmpty &&
        ctrl.settings.personalizedNumber.trim().isEmpty &&
        ctrl.settings.personalizedCustom1.trim().isEmpty &&
        ctrl.settings.personalizedCustom2.trim().isEmpty;
        
    final isDisabled = isEmptyCharset || isImproveEmpty || isPersonalizedEmpty;

    String buttonText = 'Generate New Password${ctrl.settings.count > 1 && mode == GenerationMode.random ? 's' : ''}';
    if (mode == GenerationMode.personalized) {
      buttonText = isPersonalizedEmpty ? 'Provide inputs to generate' : 'Generate Suggestions';
    } else if (mode == GenerationMode.improve) {
      buttonText = isImproveEmpty ? 'Enter a password to improve' : 'Improve Password';
    } else if (isEmptyCharset) {
      buttonText = 'Select at least one charset';
    }

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: isDisabled ? null : AppGradients.security,
          color: isDisabled ? context.colors.border : null,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: isDisabled
              ? null
              : [
                  BoxShadow(
                    color: context.colors.accentOrange.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isDisabled
                ? null
                : () =>
                    context.read<PasswordGeneratorController>().generate(),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            splashColor: Colors.white.withValues(alpha: 0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.bolt_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  buttonText,
                  style: context.textStyles.button.copyWith(
                    color: isDisabled ? context.colors.textMuted : Colors.white,
                    fontSize: isMobile(context) ? 13 : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 100.ms, duration: 300.ms)
        .slideY(begin: 0.05, end: 0);
  }
}

class _RegenerateButton extends StatefulWidget {
  final bool isMobile;
  const _RegenerateButton({required this.isMobile});

  @override
  State<_RegenerateButton> createState() => _RegenerateButtonState();
}

class _RegenerateButtonState extends State<_RegenerateButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spinCtrl;
  int _lastKey = -1;

  @override
  void initState() {
    super.initState();
    _spinCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
  }

  @override
  void dispose() {
    _spinCtrl.dispose();
    super.dispose();
  }

  void _onPressed(PasswordGeneratorController ctrl) {
    ctrl.generate();
    _spinCtrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<PasswordGeneratorController>();

    if (ctrl.generationKey != _lastKey) {
      _lastKey = ctrl.generationKey;
      _spinCtrl.forward(from: 0);
    }

    final buttonStyle = TextButton.styleFrom(
      foregroundColor: context.colors.textSecondary,
      padding: widget.isMobile
          ? const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm)
          : const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(widget.isMobile ? AppRadius.md : AppRadius.full),
        side: BorderSide(color: context.colors.border),
      ),
    );

    final icon = RotationTransition(
      turns: CurvedAnimation(parent: _spinCtrl, curve: Curves.easeOut),
      child: const Icon(Icons.refresh_rounded, size: 20),
    );

    return Tooltip(
      message: 'Generate a new password using the current settings',
      child: widget.isMobile
          ? TextButton(
              onPressed: () => _onPressed(context.read<PasswordGeneratorController>()),
              style: buttonStyle,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  icon,
                  const SizedBox(width: AppSpacing.xs),
                  Text('Regenerate', style: context.textStyles.button.copyWith(fontSize: 13)),
                ],
              ),
            )
          : TextButton.icon(
              onPressed: () => _onPressed(context.read<PasswordGeneratorController>()),
              style: buttonStyle,
              icon: icon,
              label: Text('Regenerate Password', style: context.textStyles.button),
            ),
    );
  }
}
