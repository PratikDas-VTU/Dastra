// Password Strength Checker Screen — fully offline password analyzer.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/widgets.dart';
import 'controller/password_checker_controller.dart';
import 'widgets/strength_meter.dart';
import 'widgets/analysis_card.dart';
import 'widgets/recommendation_card.dart';
import 'widgets/breach_warning_card.dart';
import 'widgets/entropy_card.dart';
import 'widgets/pattern_detection_card.dart';

class PasswordCheckerScreen extends StatelessWidget {
  const PasswordCheckerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PasswordCheckerController(),
      child: const _PasswordCheckerContent(),
    );
  }
}

class _PasswordCheckerContent extends StatefulWidget {
  const _PasswordCheckerContent();

  @override
  State<_PasswordCheckerContent> createState() => _PasswordCheckerContentState();
}

class _PasswordCheckerContentState extends State<_PasswordCheckerContent> {
  final _inputFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Auto-focus the input field as requested
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _inputFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _inputFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DastraToolPage(
      title: 'Password Strength Checker',
      icon: Icons.security_rounded,
      headerGradient: AppGradients.security,
      primaryContent: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            _PasswordInputCard(focusNode: _inputFocusNode),
            const SizedBox(height: AppSpacing.md),
            const StrengthMeter(),
            const SizedBox(height: AppSpacing.md),
            const BreachWarningCard(),
            const SizedBox(height: AppSpacing.md),
            const RecommendationCard(),
            const SizedBox(height: AppSpacing.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shield_rounded, size: 14, color: context.colors.success),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Analysis performed locally. Your password never leaves your device.',
                      style: context.textStyles.caption,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      configurationPanel: const DastraConfigurationPanel(
        sections: [
          AnalysisCard(),
          PatternDetectionCard(),
          EntropyCard(),
        ],
      ),
      primaryFlex: 6,
      configurationFlex: 5,
    );
  }
}

// ── Password Input Card Widget ───────────────────────────────────────────────

class _PasswordInputCard extends StatefulWidget {
  const _PasswordInputCard({required this.focusNode});
  final FocusNode focusNode;

  @override
  State<_PasswordInputCard> createState() => _PasswordInputCardState();
}

class _PasswordInputCardState extends State<_PasswordInputCard> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pasteFromClipboard(PasswordCheckerController ctrl) async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data != null && data.text != null) {
      final text = data.text!;
      _controller.text = text;
      ctrl.setPassword(text);
    }
  }

  void _clearInput(PasswordCheckerController ctrl) {
    _controller.clear();
    ctrl.clearPassword();
    widget.focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<PasswordCheckerController>();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.colors.border),
        boxShadow: AppShadows.cardShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Enter Password to Analyze', style: context.textStyles.labelLarge),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _controller,
            focusNode: widget.focusNode,
            obscureText: ctrl.obscureText,
            style: context.textStyles.bodyLarge.copyWith(letterSpacing: 0.5),
            onChanged: ctrl.setPassword,
            decoration: InputDecoration(
              hintText: 'Type or paste a password...',
              hintStyle: context.textStyles.caption,
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
                borderSide: BorderSide(color: context.colors.accentBlue, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              prefixIcon: Icon(
                Icons.lock_outline_rounded,
                color: context.colors.textMuted,
                size: 20,
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Paste button
                  if (_controller.text.isEmpty)
                    IconButton(
                      icon: const Icon(Icons.paste_rounded, size: 18),
                      tooltip: 'Paste from clipboard',
                      color: context.colors.textMuted,
                      onPressed: () => _pasteFromClipboard(ctrl),
                    ),
                  // Clear button
                  if (_controller.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      tooltip: 'Clear',
                      color: context.colors.textMuted,
                      onPressed: () => _clearInput(ctrl),
                    ),
                  // Toggle Show/Hide obscureText
                  IconButton(
                    icon: Icon(
                      ctrl.obscureText
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 18,
                    ),
                    tooltip: ctrl.obscureText ? 'Show password' : 'Hide password',
                    color: context.colors.textMuted,
                    onPressed: ctrl.toggleObscureText,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

