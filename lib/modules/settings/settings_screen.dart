import '../../core/widgets/widgets.dart';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/di/service_locator.dart';
import '../../core/theme/theme.dart';
import '../../modules/workspace/domain/workspace_repository.dart';
import 'controller/user_preferences_controller.dart';
import '../../core/config/build_config.dart';
import '../../core/storage/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _showEditNameDialog(BuildContext context, String? currentName) {
    _nameController.text = currentName ?? '';
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: context.colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          side: BorderSide(color: context.colors.border),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Edit Profile Name', style: context.typography.h2),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Set your display name for personalized greetings in your workspace.',
                  style: context.typography.bodyMedium.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                TextField(
                  controller: _nameController,
                  autofocus: true,
                  style: context.typography.bodyLarge.copyWith(
                    color: context.colors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter name...',
                    hintStyle: context.typography.bodyLarge.copyWith(
                      color: context.colors.textMuted,
                    ),
                  ),
                  onSubmitted: (_) {
                    context.read<UserPreferencesController>().updateName(_nameController.text);
                    Navigator.of(ctx).pop();
                  },
                ),
                const SizedBox(height: AppSpacing.xxl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text(
                        'Cancel',
                        style: context.typography.labelLarge.copyWith(
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    DastraButton(
                      label: 'Save Changes',
                      onTap: () {
                        context.read<UserPreferencesController>().updateName(_nameController.text);
                        Navigator.of(ctx).pop();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showStartupOptionDialog(BuildContext context, String currentOption) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: context.colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          side: BorderSide(color: context.colors.border),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Startup Behavior', style: context.typography.h2),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Choose which screen opens when Dastra launches.',
                  style: context.typography.bodyMedium.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                _buildRadioTile(ctx, 'Home', 'home', currentOption),
                const SizedBox(height: AppSpacing.sm),
                _buildRadioTile(ctx, 'Workspace', 'workspace', currentOption),
                const SizedBox(height: AppSpacing.sm),
                _buildRadioTile(ctx, 'Resume Last Activity', 'resume_last', currentOption),
                const SizedBox(height: AppSpacing.xxl),
                Align(
                  alignment: Alignment.centerRight,
                  child: DastraButton(
                    label: 'Done',
                    onTap: () => Navigator.of(ctx).pop(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRadioTile(BuildContext ctx, String label, String value, String groupValue) {
    final isSelected = value == groupValue;
    return GestureDetector(
      onTap: () {
        context.read<UserPreferencesController>().updateStartupOption(value);
        Navigator.of(ctx).pop();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? context.colors.accentBlue.withValues(alpha: 0.12) : context.colors.card,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? context.colors.accentBlue : context.colors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
              size: 20,
              color: isSelected ? context.colors.accentBlue : context.colors.textMuted,
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              label,
              style: context.typography.titleMedium.copyWith(
                color: isSelected ? context.colors.accentBlue : context.colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickOutputFolder(BuildContext context) async {
    final String? selectedDirectory = await FilePicker.getDirectoryPath(
      dialogTitle: 'Select Default Output Folder',
    );
    if (selectedDirectory != null && context.mounted) {
      context.read<UserPreferencesController>().updateDefaultOutputFolder(selectedDirectory);
    }
  }

  Future<void> _exportHistory(BuildContext context) async {
    try {
      final repository = sl<WorkspaceRepository>();
      final records = await repository.getAllRecords();
      final jsonList = records.map((r) => r.toMap()).toList();
      final jsonString = const JsonEncoder.withIndent('  ').convert(jsonList);

      final String? outputFile = await FilePicker.saveFile(
        dialogTitle: 'Export History as JSON',
        fileName: 'dastra_history_export.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (outputFile != null) {
        final file = File(outputFile);
        await file.writeAsString(jsonString);
        if (context.mounted) {
          DastraSnackbar.show(context: context, message: 'History exported successfully to $outputFile');
        }
      }
    } catch (e) {
      if (context.mounted) {
        DastraSnackbar.show(context: context, message: 'Failed to export history: $e', isError: true);
      }
    }
  }

  Future<void> _confirmClearHistory(BuildContext context) async {
    final confirmed = await DastraConfirmationDialog.show(
      context: context,
      title: 'Clear All History?',
      message: 'This will permanently delete all conversion records and saved workspace history. This action cannot be undone.',
      confirmLabel: 'Clear History',
      cancelLabel: 'Cancel',
      isDestructive: true,
      icon: Icons.delete_forever_rounded,
    );

    if (confirmed && context.mounted) {
      await context.read<UserPreferencesController>().clearHistory();
      if (context.mounted) {
        DastraSnackbar.show(context: context, message: 'Workspace history cleared');
      }
    }
  }

  Future<void> _confirmResetLocalData(BuildContext context) async {
    final confirmed = await DastraConfirmationDialog.show(
      context: context,
      title: 'Reset Local Data?',
      message: 'DEVELOPER ONLY: This will permanently wipe all local application data (SQLite, Settings, Cache) and immediately restart the app.',
      confirmLabel: 'Wipe Data & Restart',
      cancelLabel: 'Cancel',
      isDestructive: true,
      icon: Icons.warning_rounded,
    );

    if (confirmed && context.mounted) {
      await sl<StorageService>().resetLocalData();
    }
  }

  String _formatStartupLabel(String option) {
    switch (option) {
      case 'home':
        return 'Home';
      case 'workspace':
        return 'Workspace';
      case 'resume_last':
        return 'Resume Last Activity';
      default:
        return 'Home';
    }
  }

  Widget _buildThemeButton(BuildContext context, String label, IconData icon, String mode, String activeMode) {
    final isSelected = mode == activeMode;
    return Expanded(
      child: GestureDetector(
        onTap: () => context.read<UserPreferencesController>().updateThemeMode(mode),
        child: AnimatedContainer(
          duration: AppAnimations.fast,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? context.colors.accentBlue.withValues(alpha: 0.15) : context.colors.card,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: isSelected ? context.colors.accentBlue : context.colors.border,
              width: isSelected ? 2.0 : 1.0,
            ),
            boxShadow: isSelected ? AppShadows.cardHoverShadow(context) : null,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? context.colors.accentBlue : context.colors.textSecondary,
              ),
              const SizedBox(height: 4),
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
    final profile = prefs.profile;

    return AdaptiveScaffold(
      title: 'Settings',
      actions: [
        if (prefs.isLoading)
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(context.colors.accentBlue),
                ),
              ),
            ),
          ),
      ],
      body: DastraPage(
        maxWidth: AppMetrics.maxSettingsWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Profile Card
              DastraProfileCard(
                name: profile.name,
                subtitle: 'Offline Productivity Workspace • Dastra v1.0 RC1',
                onEdit: () => _showEditNameDialog(context, profile.name),
              ),
              const SizedBox(height: AppSpacing.xxxl),

              // 2. Appearance Section
              DastraContentSection(
                title: 'Appearance',
                subtitle: 'Customize theme and visual style for your workspace',
                child: DastraCard(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Theme Mode', style: context.typography.titleMedium),
                      const SizedBox(height: 4),
                      Text(
                        'Choose between light, dark, or sync with your operating system.',
                        style: context.typography.bodySmall,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Row(
                        children: [
                          _buildThemeButton(context, 'System', Icons.brightness_auto_rounded, 'system', profile.theme.mode),
                          const SizedBox(width: AppSpacing.md),
                          _buildThemeButton(context, 'Light', Icons.light_mode_rounded, 'light', profile.theme.mode),
                          const SizedBox(width: AppSpacing.md),
                          _buildThemeButton(context, 'Dark', Icons.dark_mode_rounded, 'dark', profile.theme.mode),
                        ],
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn().slideY(begin: 0.05, end: 0),

            // 3. Workspace & Output Section
            DastraContentSection(
              title: 'Workspace',
              subtitle: 'Manage default conversion paths and file handling behavior',
              child: Column(
                children: [
                    DastraSettingTile(
                      title: 'Default Output Folder',
                      description: profile.output.defaultFolder,
                      icon: Icons.folder_special_rounded,
                      onTap: () => _pickOutputFolder(context),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    DastraSettingTile(
                      title: 'Remember Last Folder',
                      description: 'Automatically select the most recently used output directory',
                      icon: Icons.history_rounded,
                      trailing: Switch(
                        value: profile.output.rememberLastFolder,
                        onChanged: prefs.toggleRememberLastFolder,
                      ),
                      onTap: () => prefs.toggleRememberLastFolder(!profile.output.rememberLastFolder),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    DastraSettingTile(
                      title: 'Open File After Conversion',
                      description: 'Automatically launch generated documents or images when processing finishes',
                      icon: Icons.launch_rounded,
                      trailing: Switch(
                        value: profile.output.openFileAfterConversion,
                        onChanged: prefs.toggleOpenFileAfterConversion,
                      ),
                      onTap: () => prefs.toggleOpenFileAfterConversion(!profile.output.openFileAfterConversion),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    DastraSettingTile(
                      title: 'Open Output Folder',
                      description: 'Open file explorer to destination directory after conversion completes',
                      icon: Icons.folder_open_rounded,
                      trailing: Switch(
                        value: profile.output.openFolderAfterConversion,
                        onChanged: prefs.toggleOpenFolderAfterConversion,
                      ),
                      onTap: () => prefs.toggleOpenFolderAfterConversion(!profile.output.openFolderAfterConversion),
                    ),
                  ],
                ),
            ).animate().fadeIn().slideY(begin: 0.05, end: 0),

            // 4. Startup Section
            DastraContentSection(
              title: 'Startup',
              subtitle: 'Configure application initial screen and routing behavior',
              child: DastraSettingTile(
                  title: 'Initial Screen',
                  description: 'Currently set to: ${_formatStartupLabel(profile.general.startupOption)}',
                  icon: Icons.rocket_launch_rounded,
                  onTap: () => _showStartupOptionDialog(context, profile.general.startupOption),
                ),
            ).animate().fadeIn().slideY(begin: 0.05, end: 0),

            // 5. Notifications Section
            DastraContentSection(
              title: 'Notifications',
              subtitle: 'Control desktop alerts and activity feedback',
              child: Column(
                  children: [
                    DastraSettingTile(
                      title: 'Enable Notifications',
                      description: 'Master toggle for all desktop status alerts',
                      icon: Icons.notifications_active_rounded,
                      trailing: Switch(
                        value: profile.notifications.enabled,
                        onChanged: prefs.toggleNotifications,
                      ),
                      onTap: () => prefs.toggleNotifications(!profile.notifications.enabled),
                    ),
                    if (profile.notifications.enabled) ...[
                      const SizedBox(height: AppSpacing.md),
                      DastraSettingTile(
                        title: 'Success Alerts',
                        description: 'Show toast notifications on successful task completions',
                        icon: Icons.check_circle_outline_rounded,
                        trailing: Switch(
                          value: profile.notifications.onSuccess,
                          onChanged: prefs.toggleNotifyOnSuccess,
                        ),
                        onTap: () => prefs.toggleNotifyOnSuccess(!profile.notifications.onSuccess),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      DastraSettingTile(
                        title: 'Error Alerts',
                        description: 'Notify immediately when an operation fails or encounters an error',
                        icon: Icons.error_outline_rounded,
                        trailing: Switch(
                          value: profile.notifications.onError,
                          onChanged: prefs.toggleNotifyOnError,
                        ),
                        onTap: () => prefs.toggleNotifyOnError(!profile.notifications.onError),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      DastraSettingTile(
                        title: 'Completion Alerts',
                        description: 'Notify when background processing pipelines conclude',
                        icon: Icons.done_all_rounded,
                        trailing: Switch(
                          value: profile.notifications.onCompletion,
                          onChanged: prefs.toggleNotifyOnCompletion,
                        ),
                        onTap: () => prefs.toggleNotifyOnCompletion(!profile.notifications.onCompletion),
                      ),
                    ],
                  ],
                ),
            ).animate().fadeIn().slideY(begin: 0.05, end: 0),

            // 6. History Management Section
            DastraContentSection(
              title: 'History Management',
              subtitle: 'Export activity logs or reset local workspace data',
              child: Column(
                  children: [
                    DastraSettingTile(
                      title: 'Export Activity History',
                      description: 'Save all conversion records and metadata as a standard JSON backup file',
                      icon: Icons.download_rounded,
                      onTap: () => _exportHistory(context),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    DastraSettingTile(
                      title: 'Clear Workspace History',
                      description: 'Permanently remove all local conversion history and logs',
                      icon: Icons.delete_sweep_rounded,
                      isDestructive: true,
                      onTap: () => _confirmClearHistory(context),
                    ),
                  ],
                ),
            ).animate().fadeIn().slideY(begin: 0.05, end: 0),

            // 7. About & System Details Section
            DastraContentSection(
              title: 'System Information',
              subtitle: 'View release credentials and software credits',
              child: DastraSettingTile(
                  title: 'About Dastra',
                  description: 'Version v1.0.0 (Build 100) • MIT License • Built with Flutter',
                  icon: Icons.info_outline_rounded,
                  onTap: () => context.push('/about'),
                ),
            ).animate().fadeIn().slideY(begin: 0.05, end: 0),

            if (BuildConfig.isDeveloperEdition) ...[
              // 8. Developer Options Section
              DastraContentSection(
                title: 'Developer Options',
                subtitle: 'Internal tools and diagnostics for the developer edition',
                child: DastraSettingTile(
                    title: 'Reset Local Data',
                    description: 'Safely wipe all application data and restart',
                    icon: Icons.warning_rounded,
                    isDestructive: true,
                    onTap: () => _confirmResetLocalData(context),
                  ),
              ).animate().fadeIn().slideY(begin: 0.05, end: 0),
            ],
          ],
        ),
      ),
    );
  }
}
