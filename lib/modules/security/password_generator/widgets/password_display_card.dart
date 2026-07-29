// Displays generated password(s) with copy and regenerate actions.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../controller/password_generator_controller.dart';
import '../model/password_settings.dart' show GenerationMode;
import '../utils/password_utils.dart';

/// Top section showing the generated password(s) and action buttons.
class PasswordDisplayCard extends StatelessWidget {
  const PasswordDisplayCard({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<PasswordGeneratorController>();
    final mode = ctrl.mode;
    final count = ctrl.settings.count;

    if (mode == GenerationMode.random) {
      if (count == 1) {
        return _SinglePasswordCard(password: ctrl.primaryPassword, key: ValueKey(ctrl.generationKey));
      }
      return _MultiPasswordList(passwords: ctrl.passwords, key: ValueKey(ctrl.generationKey));
    } else {
      // Personalized / Improve modes
      return Column(
        children: [
          if (ctrl.passwords.isNotEmpty && ctrl.primaryPassword.isNotEmpty) ...[
            _SinglePasswordCard(password: ctrl.primaryPassword, key: ValueKey(ctrl.primaryPassword)),
            const SizedBox(height: AppSpacing.md),
            _EducationalStrengthCard(password: ctrl.primaryPassword),
            const SizedBox(height: AppSpacing.md),
          ],
          if (ctrl.passwords.length > 1) ...[
            _SuggestionList(passwords: ctrl.passwords.skip(1).toList(), key: ValueKey(ctrl.generationKey)),
          ],
        ],
      );
    }
  }
}

// ── Educational Strength Card ────────────────────────────────────────────────

class _EducationalStrengthCard extends StatelessWidget {
  const _EducationalStrengthCard({required this.password});
  final String password;

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();

    final entropy = PasswordUtils.calculatePasswordEntropy(password);
    final strength = PasswordUtils.strengthLevel(entropy);
    final crackTime = PasswordUtils.estimateCrackTime(entropy);

    final hasUpper = password.contains(RegExp(r'[A-Z]'));
    final hasLower = password.contains(RegExp(r'[a-z]'));
    final hasNum = password.contains(RegExp(r'[0-9]'));
    final hasSym = password.contains(RegExp(r'[^A-Za-z0-9]'));
    
    int classes = 0;
    if (hasUpper) classes++;
    if (hasLower) classes++;
    if (hasNum) classes++;
    if (hasSym) classes++;

    return DastraCard(
      backgroundColor: context.colors.surface,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Why it\'s strong', style: context.textStyles.labelLarge),
          const SizedBox(height: AppSpacing.sm),
          _CheckItem('High entropy (${entropy.toStringAsFixed(1)} bits)'),
          if (classes > 2) _CheckItem('Multiple character classes ($classes)'),
          if (password.length >= 12) _CheckItem('Long password (${password.length} chars)'),
          const _CheckItem('Resistant to dictionary attacks'),
          const SizedBox(height: AppSpacing.xs),
          const Divider(),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Text('Estimated crack time:', style: context.textStyles.caption.copyWith(color: context.colors.textMuted)),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  crackTime,
                  style: context.textStyles.labelMedium.copyWith(color: strength.color),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms);
  }
}

class _CheckItem extends StatelessWidget {
  const _CheckItem(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          Icon(Icons.check_circle_rounded, size: 16, color: context.colors.success),
          const SizedBox(width: AppSpacing.sm),
          Text(text, style: context.textStyles.bodyMedium.copyWith(fontSize: 13)),
        ],
      ),
    );
  }
}

// ── Suggestion List ────────────────────────────────────────────────────────

class _SuggestionList extends StatelessWidget {
  const _SuggestionList({super.key, required this.passwords});
  final List<String> passwords;

  @override
  Widget build(BuildContext context) {
    return DastraCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.sm),
            child: Text('Alternative Suggestions', style: context.textStyles.labelLarge),
          ),
          const Divider(height: 1),
          ...List.generate(passwords.length, (i) {
            final pw = passwords[i];
            return Column(
              children: [
                InkWell(
                  onTap: () {
                    // +1 because passwords list here is skipping the first one
                    context.read<PasswordGeneratorController>().setPrimaryPassword(i + 1);
                  },
                  borderRadius: i == passwords.length - 1
                      ? const BorderRadius.vertical(bottom: Radius.circular(AppRadius.lg))
                      : BorderRadius.zero,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                    child: Row(
                      children: [
                        Icon(Icons.lightbulb_outline_rounded, size: 16, color: context.colors.textMuted),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            pw,
                            style: GoogleFonts.robotoMono(
                              fontSize: 13,
                              color: context.colors.textPrimary,
                              letterSpacing: 0.3,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(Icons.arrow_upward_rounded, size: 16, color: context.colors.accentBlue),
                      ],
                    ),
                  ),
                ),
                if (i < passwords.length - 1)
                  const Divider(height: 1, indent: AppSpacing.md),
              ],
            ).animate(delay: (i * 30).ms).fadeIn(duration: 150.ms);
          }),
        ],
      ),
    );
  }
}

// ── Single password large display ──────────────────────────────────────────

class _SinglePasswordCard extends StatefulWidget {
  const _SinglePasswordCard({super.key, required this.password});
  final String password;

  @override
  State<_SinglePasswordCard> createState() => _SinglePasswordCardState();
}

class _SinglePasswordCardState extends State<_SinglePasswordCard> {
  late final TextEditingController _textController;
  bool _copied = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.password);
  }

  @override
  void didUpdateWidget(covariant _SinglePasswordCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update the controller only if the generated password changed from outside
    if (oldWidget.password != widget.password && _textController.text != widget.password) {
      _textController.text = widget.password;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: _textController.text));
    setState(() => _copied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    return DastraCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label row
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, AppSpacing.md, AppSpacing.md, 0,
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppGradients.accent,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text('Generated Password (Editable)', style: context.textStyles.labelMedium),
              ],
            ),
          ),
          // Password text
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: TextField(
              controller: _textController,
              onChanged: (val) {
                context.read<PasswordGeneratorController>().updatePrimaryPassword(val);
              },
              style: GoogleFonts.robotoMono(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: widget.password.isEmpty
                    ? context.colors.textMuted
                    : context.colors.textPrimary,
                height: 1.6,
                letterSpacing: 0.5,
              ),
              decoration: InputDecoration(
                hintText: 'Type custom password or alter generated...',
                hintStyle: context.textStyles.caption,
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const Divider(height: 1),
          // Action row
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _ActionButton(
                  icon: _copied ? Icons.check_rounded : Icons.copy_rounded,
                  label: _copied ? 'Copied!' : 'Copy',
                  color: _copied ? context.colors.success : context.colors.accentBlue,
                  onTap: _copy,
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 250.ms)
        .slideY(begin: 0.04, end: 0, duration: 250.ms);
  }
}

// ── Multi-password list ────────────────────────────────────────────────────

class _MultiPasswordList extends StatefulWidget {
  const _MultiPasswordList({super.key, required this.passwords});
  final List<String> passwords;

  @override
  State<_MultiPasswordList> createState() => _MultiPasswordListState();
}

class _MultiPasswordListState extends State<_MultiPasswordList> {
  bool _allCopied = false;
  final Map<int, bool> _copiedMap = {};

  Future<void> _copyOne(int index) async {
    await Clipboard.setData(ClipboardData(text: widget.passwords[index]));
    setState(() => _copiedMap[index] = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copiedMap[index] = false);
  }

  Future<void> _copyAll() async {
    await Clipboard.setData(
      ClipboardData(text: widget.passwords.join('\n')),
    );
    setState(() => _allCopied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _allCopied = false);
  }

  @override
  Widget build(BuildContext context) {
    return DastraCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, AppSpacing.sm, AppSpacing.sm, AppSpacing.sm,
            ),
            child: Row(
              children: [
                Text(
                  '${widget.passwords.length} Passwords',
                  style: context.textStyles.labelLarge,
                ),
                const Spacer(),
                _ActionButton(
                  icon: _allCopied ? Icons.check_rounded : Icons.copy_all_rounded,
                  label: _allCopied ? 'Copied!' : 'Copy All',
                  color: _allCopied ? context.colors.success : context.colors.accentBlue,
                  onTap: _copyAll,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Password rows
          ...List.generate(widget.passwords.length, (i) {
            final pw = widget.passwords[i];
            final isCopied = _copiedMap[i] ?? false;
            return Column(
              children: [
                InkWell(
                  onTap: () => _copyOne(i),
                  borderRadius: i == widget.passwords.length - 1
                      ? const BorderRadius.vertical(
                          bottom: Radius.circular(AppRadius.lg))
                      : BorderRadius.zero,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        // Index badge
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: context.colors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.xs),
                            border: Border.all(color: context.colors.border),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${i + 1}',
                            style: context.textStyles.caption,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        // Password
                        Expanded(
                          child: Text(
                            pw,
                            style: GoogleFonts.robotoMono(
                              fontSize: 13,
                              color: context.colors.textPrimary,
                              letterSpacing: 0.3,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Copy icon
                        Icon(
                          isCopied ? Icons.check_rounded : Icons.copy_rounded,
                          size: 16,
                          color: isCopied
                              ? context.colors.success
                              : context.colors.textMuted,
                        ),
                      ],
                    ),
                  ),
                ),
                if (i < widget.passwords.length - 1)
                  const Divider(height: 1, indent: AppSpacing.md + 22 + AppSpacing.sm),
              ],
            ).animate(delay: (i * 40).ms).fadeIn(duration: 200.ms);
          }),
        ],
      ),
    );
  }
}

// ── Reusable action button ─────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16, color: color),
      label: Text(label, style: context.textStyles.labelMedium.copyWith(color: color)),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );
  }
}
