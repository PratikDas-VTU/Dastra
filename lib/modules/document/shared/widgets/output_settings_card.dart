import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../model/output_configuration.dart';

class OutputSettingsCard extends StatefulWidget {
  final OutputConfiguration config;
  final ValueChanged<OutputConfiguration> onChanged;
  final VoidCallback onPickFolder;
  final String fileExtension;

  const OutputSettingsCard({
    super.key,
    required this.config,
    required this.onChanged,
    required this.onPickFolder,
    required this.fileExtension,
  });

  @override
  State<OutputSettingsCard> createState() => _OutputSettingsCardState();
}

class _OutputSettingsCardState extends State<OutputSettingsCard> {
  late TextEditingController _nameCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.config.filename);
  }

  @override
  void didUpdateWidget(OutputSettingsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config.filename != widget.config.filename && _nameCtrl.text != widget.config.filename) {
      _nameCtrl.text = widget.config.filename;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _onNameChanged(String val) {
    widget.onChanged(widget.config.copyWith(filename: val));
  }

  @override
  Widget build(BuildContext context) {
    return DastraCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Output Settings',
            style: context.textStyles.h4,
          ),
          const SizedBox(height: AppSpacing.xl),
          
          // File Name
          Text('File Name', style: context.textStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSpacing.xs),
          TextField(
            controller: _nameCtrl,
            onChanged: _onNameChanged,
            style: context.textStyles.bodyMedium,
            decoration: InputDecoration(
              filled: true,
              fillColor: context.colors.background,
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
                borderSide: BorderSide(color: context.colors.accentBlue),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 14),
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: AppSpacing.md),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Text(widget.fileExtension, style: context.textStyles.bodyMedium.copyWith(color: context.colors.textSecondary, fontWeight: FontWeight.bold))],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Output Folder
          Text('Output Folder', style: context.textStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 14),
                  decoration: BoxDecoration(
                    color: context.colors.background,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(color: context.colors.border),
                  ),
                  child: Text(
                    widget.config.folderPath,
                    style: context.textStyles.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              DastraButton(
                onTap: widget.onPickFolder,
                label: 'Browse',
                type: DastraButtonType.secondary,
              ),
            ],
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Duplicate Handling
          Text('If file exists:', style: context.textStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              _buildStrategyChip(DuplicateHandlingStrategy.autoRename, 'Auto Rename'),
              _buildStrategyChip(DuplicateHandlingStrategy.replace, 'Replace'),
              _buildStrategyChip(DuplicateHandlingStrategy.ask, 'Ask'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStrategyChip(DuplicateHandlingStrategy strategy, String label) {
    final isSelected = widget.config.duplicateStrategy == strategy;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        if (val) widget.onChanged(widget.config.copyWith(duplicateStrategy: strategy));
      },
      selectedColor: context.colors.accentBlue.withValues(alpha: 0.1),
      backgroundColor: context.colors.background,
      labelStyle: TextStyle(
        color: isSelected ? context.colors.accentBlue : context.colors.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(color: isSelected ? context.colors.accentBlue : context.colors.border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
    );
  }
}
