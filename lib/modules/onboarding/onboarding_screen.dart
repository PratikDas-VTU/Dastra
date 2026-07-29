import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/widgets.dart';
import '../settings/controller/user_preferences_controller.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding() async {
    final prefs = context.read<UserPreferencesController>();
    await prefs.updateName(_nameController.text);
    await prefs.setHasSeenOnboarding(true);
    if (mounted) {
      context.go('/');
    }
  }

  Widget _buildThemeCard({
    required String label,
    required IconData icon,
    required String mode,
    required String activeMode,
  }) {
    final isSelected = activeMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          context.read<UserPreferencesController>().updateThemeMode(mode);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? context.colors.accentBlue.withValues(alpha: 0.15)
                : context.colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: isSelected ? context.colors.accentBlue : context.colors.border,
              width: isSelected ? 2.0 : 1.0,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 24,
                color: isSelected ? context.colors.accentBlue : context.colors.textSecondary,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: context.typography.labelMedium.copyWith(
                  color: isSelected ? context.colors.accentBlue : context.colors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<UserPreferencesController>();
    final activeMode = prefs.profile.theme.mode;

    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xxxl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xxl),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          context.colors.accentBlue.withValues(alpha: 0.15),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Icon(
                      Icons.person_outline_rounded,
                      size: 72,
                      color: context.colors.accentBlue,
                    ),
                  ).animate().scaleXY(
                        begin: 0.8,
                        end: 1.0,
                        duration: AppAnimations.slow,
                        curve: AppAnimations.subtleSpring,
                      ).fadeIn(duration: AppAnimations.slow),
                  const SizedBox(height: AppSpacing.xxl),
                  Text(
                    'What should we call you?',
                    style: context.typography.displayMedium,
                    textAlign: TextAlign.center,
                  ).animate().slideY(
                        begin: 0.2,
                        end: 0,
                        duration: AppAnimations.slow,
                        curve: AppAnimations.decelerate,
                      ).fadeIn(duration: AppAnimations.slow),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'We will use this to personalize your offline workspace and greetings.',
                    style: context.typography.bodyLarge.copyWith(
                      color: context.colors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ).animate(delay: AppAnimations.fast).slideY(
                        begin: 0.2,
                        end: 0,
                        duration: AppAnimations.slow,
                        curve: AppAnimations.decelerate,
                      ).fadeIn(duration: AppAnimations.slow),
                  const SizedBox(height: AppSpacing.xxxl),
                  TextField(
                    controller: _nameController,
                    autofocus: true,
                    textAlign: TextAlign.center,
                    style: context.typography.h3.copyWith(
                      color: context.colors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter your name (optional)',
                      hintStyle: context.typography.h3.copyWith(
                        color: context.colors.textMuted,
                      ),
                    ),
                    onSubmitted: (_) => _finishOnboarding(),
                  ).animate(delay: 200.ms).fadeIn(),
                  const SizedBox(height: AppSpacing.xxxl),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Choose Theme',
                      style: context.typography.labelLarge.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ).animate(delay: 250.ms).fadeIn(),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      _buildThemeCard(
                        label: 'System',
                        icon: Icons.brightness_auto_rounded,
                        mode: 'system',
                        activeMode: activeMode,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      _buildThemeCard(
                        label: 'Light',
                        icon: Icons.light_mode_rounded,
                        mode: 'light',
                        activeMode: activeMode,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      _buildThemeCard(
                        label: 'Dark',
                        icon: Icons.dark_mode_rounded,
                        mode: 'dark',
                        activeMode: activeMode,
                      ),
                    ],
                  ).animate(delay: 250.ms).fadeIn().slideY(begin: 0.1, end: 0),
                  const SizedBox(height: AppSpacing.xxxl),
                  SizedBox(
                    width: double.infinity,
                    child: DastraButton(
                      label: 'Get Started',
                      icon: Icons.arrow_forward_rounded,
                      onTap: _finishOnboarding,
                    ),
                  ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.2, end: 0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
