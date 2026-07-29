import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme.dart';
import '../../core/utils/app_constants.dart';
import '../../core/di/service_locator.dart';
import '../../core/utils/tool_registry.dart';
import '../settings/controller/user_preferences_controller.dart';
import '../workspace/domain/workspace_repository.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final duration = Platform.environment.containsKey('FLUTTER_TEST')
        ? Duration.zero
        : AppConstants.splashDuration;
    _timer = Timer(duration, () async {
      if (mounted) {
        if (!sl.isRegistered<UserPreferencesController>()) {
          context.go('/');
          return;
        }
        final prefs = sl<UserPreferencesController>();
        final hasSeenOnboarding = prefs.hasSeenOnboarding;
        if (!hasSeenOnboarding) {
          context.go('/onboarding');
        } else {
          final startup = prefs.profile.general.startupOption;
          if (startup == 'workspace') {
            context.go('/workspace');
          } else if (startup == 'resume_last') {
            try {
              if (sl.isRegistered<WorkspaceRepository>()) {
                final repo = sl<WorkspaceRepository>();
                final lastIds = await repo.getRecentlyUsedToolIds(1);
                if (!mounted) return;
                
                if (lastIds.isNotEmpty) {
                  final tool = ToolRegistry.allTools.firstWhere(
                    (t) => t.id == lastIds.first,
                    orElse: () => ToolRegistry.allTools.first,
                  );
                  if (tool.route != null) {
                    context.go(tool.route!);
                    return;
                  }
                }
              }
            } catch (_) {}
            
            if (mounted) {
              context.go('/');
            }
          } else {
            context.go('/');
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo with scale + fade animation
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.xl),
                boxShadow: [
                  BoxShadow(
                    color: context.colors.accentBlue.withValues(alpha: 0.3),
                    blurRadius: 48,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: context.colors.accentPurple.withValues(alpha: 0.2),
                    blurRadius: 80,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                AppConstants.logoPath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: context.colors.accentGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Icon(
                    Icons.bolt_rounded,
                    color: Colors.white,
                    size: 56,
                  ),
                ),
              ),
            )
                .animate()
                .scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1.0, 1.0),
                  duration: 800.ms,
                  curve: Curves.easeOutBack,
                )
                .fadeIn(duration: 600.ms),

            const SizedBox(height: AppSpacing.xl),

            // App name
            Text(
              AppConstants.appName,
              style: context.textStyles.displayMedium,
            )
                .animate(delay: 400.ms)
                .fadeIn(duration: 500.ms)
                .slideY(begin: 0.2, end: 0),

            const SizedBox(height: AppSpacing.xs),

            // Subtitle
            Text(
              AppConstants.appSubtitle,
              style: context.textStyles.bodyMedium,
            )
                .animate(delay: 600.ms)
                .fadeIn(duration: 500.ms)
                .slideY(begin: 0.2, end: 0),

            const SizedBox(height: AppSpacing.xxl),

            // Loading indicator
            SizedBox(
              width: 120,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.full),
                child: LinearProgressIndicator(
                  value: Platform.environment.containsKey('FLUTTER_TEST') ? 1.0 : null,
                  backgroundColor: context.colors.border,
                  valueColor: AlwaysStoppedAnimation<Color>(context.colors.accentBlue),
                  minHeight: 2,
                ),
              ),
            ).animate(delay: 800.ms).fadeIn(duration: 400.ms),
          ],
        ),
      ),
    );
  }
}
