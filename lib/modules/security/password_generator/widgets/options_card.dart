// Character-set options and exclusion settings card.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../controller/password_generator_controller.dart';

/// Card containing all boolean toggles and exclusion text fields.
class OptionsCard extends StatefulWidget {
  const OptionsCard({super.key});

  @override
  State<OptionsCard> createState() => _OptionsCardState();
}

class _OptionsCardState extends State<OptionsCard> {
  late TextEditingController _excludeCtrl;
  late TextEditingController _customBaseCtrl;

  @override
  void initState() {
    super.initState();
    final ctrl = context.read<PasswordGeneratorController>();
    _excludeCtrl =
        TextEditingController(text: ctrl.settings.excludeCustom);
    _customBaseCtrl =
        TextEditingController(text: ctrl.settings.customBase);
  }

  @override
  void dispose() {
    _excludeCtrl.dispose();
    _customBaseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<PasswordGeneratorController>();
    final s = ctrl.settings;

    return DastraCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // ── Section label
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, AppSpacing.md, AppSpacing.md, 0,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.tune_rounded,
                  size: 16,
                  color: context.colors.textMuted,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(child: Text('Character Options', style: context.textStyles.labelLarge)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),

          // ── Charset toggles
          _OptionToggle(
            icon: Icons.title_rounded,
            gradientColors: const [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
            label: 'Uppercase',
            sublabel: 'A – Z',
            value: s.useUppercase,
            onChanged: (_) => ctrl.toggleUppercase(),
          ),
          const Divider(height: 1, indent: 56),
          _OptionToggle(
            icon: Icons.text_fields_rounded,
            gradientColors: const [Color(0xFF06B6D4), Color(0xFF3B82F6)],
            label: 'Lowercase',
            sublabel: 'a – z',
            value: s.useLowercase,
            onChanged: (_) => ctrl.toggleLowercase(),
          ),
          const Divider(height: 1, indent: 56),
          _OptionToggle(
            icon: Icons.pin_rounded,
            gradientColors: const [Color(0xFF10B981), Color(0xFF06B6D4)],
            label: 'Numbers',
            sublabel: '0 – 9',
            value: s.useNumbers,
            onChanged: (_) => ctrl.toggleNumbers(),
          ),
          const Divider(height: 1, indent: 56),
          _OptionToggle(
            icon: Icons.tag_rounded,
            gradientColors: const [Color(0xFFF97316), Color(0xFFEF4444)],
            label: 'Symbols',
            sublabel: r'!@#$%^&*…',
            value: s.useSymbols,
            onChanged: (_) => ctrl.toggleSymbols(),
          ),

          const Divider(height: 1),

          // ── Exclusion toggles
          _OptionToggle(
            icon: Icons.visibility_off_rounded,
            gradientColors: const [Color(0xFF8B5CF6), Color(0xFFEC4899)],
            label: 'Exclude Similar',
            sublabel: 'O, 0, l, I, 1, |',
            value: s.excludeSimilar,
            onChanged: (_) => ctrl.toggleExcludeSimilar(),
          ),

          const Divider(height: 1),

          // ── Custom base text field (e.g. seed name)
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF06B6D4), Color(0xFF8B5CF6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                  ),
                  child: const Icon(
                    Icons.badge_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Include Custom Text', style: context.textStyles.bodySmall.copyWith(
                        color: context.colors.textPrimary,
                      )),
                      const SizedBox(height: 4),
                      TextField(
                        controller: _customBaseCtrl,
                        style: context.textStyles.bodySmall.copyWith(
                          color: context.colors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'e.g. name, base word…',
                          hintStyle: context.textStyles.caption,
                          filled: true,
                          fillColor: context.colors.surface,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8,
                          ),
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
                            borderSide: BorderSide(
                              color: context.colors.accentBlue,
                              width: 1.5,
                            ),
                          ),
                          suffixIcon: _customBaseCtrl.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.close_rounded,
                                    size: 14,
                                    color: context.colors.textMuted,
                                  ),
                                  onPressed: () {
                                    _customBaseCtrl.clear();
                                    ctrl.setCustomBase('');
                                  },
                                )
                              : null,
                        ),
                        onChanged: ctrl.setCustomBase,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // ── Custom exclusion field
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                  ),
                  child: const Icon(
                    Icons.block_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Exclude Characters', style: context.textStyles.bodySmall.copyWith(
                        color: context.colors.textPrimary,
                      )),
                      const SizedBox(height: 4),
                      TextField(
                        controller: _excludeCtrl,
                        style: context.textStyles.bodySmall.copyWith(
                          color: context.colors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Type characters to exclude…',
                          hintStyle: context.textStyles.caption,
                          filled: true,
                          fillColor: context.colors.surface,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8,
                          ),
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
                            borderSide: BorderSide(
                              color: context.colors.accentBlue,
                              width: 1.5,
                            ),
                          ),
                          suffixIcon: _excludeCtrl.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.close_rounded,
                                    size: 14,
                                    color: context.colors.textMuted,
                                  ),
                                  onPressed: () {
                                    _excludeCtrl.clear();
                                    ctrl.setExcludeCustom('');
                                  },
                                )
                              : null,
                        ),
                        onChanged: ctrl.setExcludeCustom,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A single toggle row inside the options card.
class _OptionToggle extends StatelessWidget {
  const _OptionToggle({
    required this.icon,
    required this.gradientColors,
    required this.label,
    required this.sublabel,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final List<Color> gradientColors;
  final String label;
  final String sublabel;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            // Gradient icon box
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppRadius.xs),
              ),
              child: Icon(icon, size: 16, color: Colors.white),
            ),
            const SizedBox(width: AppSpacing.sm),
            // Labels
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: context.textStyles.bodySmall.copyWith(
                    color: context.colors.textPrimary,
                  )),
                  Text(sublabel, style: context.textStyles.caption),
                ],
              ),
            ),
            // Toggle switch
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: context.colors.accentBlue,
              activeTrackColor: context.colors.accentBlue.withValues(alpha: 0.3),
              inactiveThumbColor: context.colors.textMuted,
              inactiveTrackColor: context.colors.border,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
      ),
    );
  }
}
