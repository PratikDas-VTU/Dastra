import '../../core/widgets/widgets.dart';
import 'dart:io';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/di/service_locator.dart';
import '../../core/storage/storage_service.dart';
import '../../core/theme/theme.dart';

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
    return AdaptiveScaffold(
      title: 'About Dastra',
      body: DastraPage(
        maxWidth: AppMetrics.maxAboutWidth,
        child: Column(
          children: [
                // 1. Product Hero Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.xxxl),
                  decoration: BoxDecoration(
                    color: context.colors.card,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    border: Border.all(color: context.colors.border),
                    boxShadow: AppShadows.cardShadow(context),
                    gradient: LinearGradient(
                      colors: [
                        context.colors.accentBlue.withValues(alpha: 0.15),
                        context.colors.card,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: context.colors.surface,
                          border: Border.all(color: context.colors.border),
                          boxShadow: [
                            BoxShadow(
                              color: context.colors.accentBlue.withValues(alpha: 0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.layers_rounded,
                          size: 56,
                          color: context.colors.accentBlue,
                        ),
                      ).animate().scaleXY(begin: 0.8, end: 1.0, duration: AppAnimations.normal),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        'Dastra',
                        style: context.typography.displayMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Universal Offline Document & Media Engineering Suite',
                        style: context.typography.h3.copyWith(
                          color: context.colors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: context.colors.accentBlue.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          border: Border.all(
                            color: context.colors.accentBlue.withValues(alpha: 0.3),
                          ),
                        ),
                        child: FutureBuilder<PackageInfo>(
                          future: PackageInfo.fromPlatform(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              final packageInfo = snapshot.data!;
                              // The user asked for "Version 1.0 RC1"
                              // For the badge, we can put Dastra v${packageInfo.version}
                              return Text(
                                'RELEASE CANDIDATE 1 (v${packageInfo.version})',
                                style: context.typography.labelSmall.copyWith(
                                  color: context.colors.accentBlue,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.0,
                                ),
                              );
                            }
                            return const SizedBox();
                          },
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: AppAnimations.normal).slideY(begin: 0.05, end: 0),

                // 2. Specifications & Release Details
                DastraContentSection(
                  title: 'Release Credentials',
                  subtitle: 'Technical specifications and application runtime environment',
                  child: FutureBuilder<PackageInfo>(
                    future: PackageInfo.fromPlatform(),
                    builder: (context, snapshot) {
                      final version = snapshot.hasData ? snapshot.data!.version : 'Loading...';
                      final buildNumber = snapshot.hasData ? snapshot.data!.buildNumber : '...';
                      
                      return Column(
                        children: [
                          DastraInfoTile(
                            label: 'Application Version',
                            value: 'Version 1.0 RC1', // As requested explicitly
                            icon: Icons.verified_rounded,
                            canCopy: true,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          DastraInfoTile(
                            label: 'Build Number',
                            value: 'Build $buildNumber',
                            icon: Icons.tag_rounded,
                            canCopy: true,
                          ),
                      const SizedBox(height: AppSpacing.sm),
                      DastraInfoTile(
                        label: 'Active Platform',
                        value: _getPlatformName(),
                        icon: Icons.desktop_windows_rounded,
                        canCopy: true,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const DastraInfoTile(
                        label: 'Core Framework',
                        value: 'Flutter 3.x (Material 3 Dynamic Architecture)',
                        icon: Icons.code_rounded,
                        canCopy: true,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const DastraInfoTile(
                        label: 'Supported Targets',
                        value: 'Windows x64, Android APK, macOS, Linux',
                        icon: Icons.devices_rounded,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      FutureBuilder<String>(
                        future: _getStoragePath(),
                        builder: (context, snapshot) {
                          final path = snapshot.data ?? 'Locating storage...';
                          return DastraInfoTile(
                            label: 'Database Path (100% Offline SQLite)',
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

                // 3. Legal & Development Credits
                const DastraContentSection(
                  title: 'Development & Licensing',
                  subtitle: 'Software engineering credits and open source licensing',
                  child: Column(
                    children: [
                      DastraInfoTile(
                        label: 'Principal Developer',
                        value: 'Pratik Das',
                        icon: Icons.engineering_rounded,
                      ),
                      SizedBox(height: AppSpacing.sm),
                      DastraInfoTile(
                        label: 'Software License',
                        value: 'Pending License Selection',
                        icon: Icons.gavel_rounded,
                      ),
                      SizedBox(height: AppSpacing.sm),
                      DastraInfoTile(
                        label: 'Privacy Guarantee',
                        value: 'Zero Telemetry • Zero Cloud Processing • Local Offline Storage Only',
                        icon: Icons.privacy_tip_rounded,
                      ),
                    ],
                  ),
                ).animate().fadeIn().slideY(begin: 0.05, end: 0),

                // 4. Acknowledgements
                DastraContentSection(
                  title: 'Acknowledgements',
                  subtitle: 'Powered by open-source libraries and high-performance engines',
                  child: DastraCard(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'We extend our gratitude to the contributors of Flutter, Syncfusion PDF, PDFX, Provider, GoRouter, Image, Archive, and the Dart ecosystem for enabling high-speed offline document processing.',
                          style: context.typography.bodyMedium.copyWith(
                            color: context.colors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.favorite_rounded, size: 16, color: context.colors.error),
                            const SizedBox(width: 8),
                            Text(
                              'Designed for Privacy and Speed',
                              style: context.typography.labelMedium.copyWith(
                                color: context.colors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn().slideY(begin: 0.05, end: 0),
          ],
        ),
      ),
    );
  }
}
