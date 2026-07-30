import '../../core/widgets/widgets.dart';
import 'dart:io';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/di/service_locator.dart';
import '../../core/storage/storage_service.dart';
import '../../core/theme/theme.dart';
import '../../core/config/build_config.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<String> _getStoragePath() async {
    try {
      final storage = sl<StorageService>();
      return await storage.getDatabasePath('dastra_workspace.db');
    } catch (_) {
      return 'Local Workspace Database (SQLite / Hive)';
    }
  }

  String _getPlatformName() {
    if (Platform.isWindows) return 'Windows (x64 Desktop)';
    if (Platform.isAndroid) return 'Android (Mobile APK)';
    if (Platform.isIOS) return 'iOS (Mobile App)';
    if (Platform.isMacOS) return 'macOS (Desktop)';
    if (Platform.isLinux) return 'Linux (Desktop)';
    return 'Web / Universal';
  }

  @override
  Widget build(BuildContext context) {
    final appName = BuildConfig.isDeveloperEdition ? 'Dastra Developer' : 'Dastra';
    
    return AdaptiveScaffold(
      title: 'About',
      body: DastraPage(
        maxWidth: AppMetrics.maxAboutWidth,
        child: Column(
          children: [
            // Fluent Design Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.xxxl),
              decoration: BoxDecoration(
                color: context.colors.card,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(color: context.colors.border),
                boxShadow: AppShadows.cardShadow(context),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.colors.accentBlue.withValues(alpha: 0.1),
                    ),
                    child: Icon(
                      Icons.layers_rounded,
                      size: 48,
                      color: context.colors.accentBlue,
                    ),
                  ).animate().scaleXY(begin: 0.9, end: 1.0, duration: AppAnimations.normal),
                  const SizedBox(width: AppSpacing.xxl),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appName,
                          style: context.typography.displayMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        FutureBuilder<PackageInfo>(
                          future: PackageInfo.fromPlatform(),
                          builder: (context, snapshot) {
                            final version = snapshot.hasData ? snapshot.data!.version : '...';
                            return Text(
                              'Version $version',
                              style: context.typography.bodyLarge.copyWith(
                                color: context.colors.textSecondary,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: AppAnimations.normal).slideY(begin: 0.05, end: 0),

            const SizedBox(height: AppSpacing.xl),

            // Specifications & Release Details
            DastraContentSection(
              title: 'System Information',
              subtitle: 'Application and runtime specifications',
              child: FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
                builder: (context, snapshot) {
                  final buildNumber = snapshot.hasData ? snapshot.data!.buildNumber : '...';
                  
                  return Column(
                    children: [
                      DastraInfoTile(
                        label: 'Edition',
                        value: '${BuildConfig.editionName} Edition',
                        icon: Icons.workspace_premium_rounded,
                        canCopy: true,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      DastraInfoTile(
                        label: 'Build Profile',
                        value: BuildConfig.activeProfile.name.toUpperCase(),
                        icon: Icons.build_rounded,
                        canCopy: true,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      DastraInfoTile(
                        label: 'Release Channel',
                        value: BuildConfig.releaseChannel,
                        icon: Icons.dynamic_feed_rounded,
                        canCopy: true,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      DastraInfoTile(
                        label: 'License Tier',
                        value: BuildConfig.licenseTier,
                        icon: Icons.vpn_key_rounded,
                        canCopy: true,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      DastraInfoTile(
                        label: 'Build Number',
                        value: buildNumber,
                        icon: Icons.tag_rounded,
                        canCopy: true,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      DastraInfoTile(
                        label: 'Platform',
                        value: _getPlatformName(),
                        icon: Icons.desktop_windows_rounded,
                        canCopy: true,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      FutureBuilder<String>(
                        future: _getStoragePath(),
                        builder: (context, snapshot) {
                          final path = snapshot.data ?? 'Locating storage...';
                          return DastraInfoTile(
                            label: 'Database Path',
                            value: path,
                            icon: Icons.storage_rounded,
                            canCopy: snapshot.hasData,
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ).animate().fadeIn().slideY(begin: 0.05, end: 0),

            // Legal & Development Credits
            const DastraContentSection(
              title: 'Development',
              subtitle: 'Software engineering credits',
              child: Column(
                children: [
                  DastraInfoTile(
                    label: 'Principal Developer',
                    value: 'Pratik Das',
                    icon: Icons.engineering_rounded,
                  ),
                  SizedBox(height: AppSpacing.sm),
                  DastraInfoTile(
                    label: 'Repository',
                    value: 'https://github.com/PratikDas-VTU/Dastra',
                    icon: Icons.code_rounded,
                    canCopy: true,
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: 0.05, end: 0),
          ],
        ),
      ),
    );
  }
}
