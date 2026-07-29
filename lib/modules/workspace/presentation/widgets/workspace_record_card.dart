import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/utils/file_icon_resolver.dart';
import '../../domain/models/workspace_record.dart';
import '../controller/workspace_controller.dart';

class WorkspaceRecordCard extends StatelessWidget {
  const WorkspaceRecordCard({
    super.key,
    required this.record,
    required this.controller,
  });

  final WorkspaceRecord record;
  final WorkspaceController controller;

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    int i = 0;
    double d = bytes.toDouble();
    while (d > 1024 && i < suffixes.length - 1) {
      d /= 1024;
      i++;
    }
    return '${d.toStringAsFixed(1)} ${suffixes[i]}';
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.surface,
        title: Text('Delete Record', style: context.textStyles.h4),
        content: Text(
          'Do you want to only remove this from your history, or also permanently delete the generated file from your disk?',
          style: context.textStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: context.colors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              controller.deleteRecord(record, deleteFileFromDisk: false);
            },
            child: Text('History Only', style: TextStyle(color: context.colors.warning)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: context.colors.error),
            onPressed: () {
              Navigator.pop(ctx);
              controller.deleteRecord(record, deleteFileFromDisk: true);
            },
            child: const Text('Delete File', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = Adaptive.of(context);
    final isCompact = size == ScreenSize.compact || size == ScreenSize.largePhone;
    final originalFileName = p.basename(record.inputPath);
    final iconData = FileIconResolver.getIcon(record.outputExtension);
    final iconColor = FileIconResolver.getColor(record.outputExtension);
    final dateStr = DateFormat('MMM dd, yyyy • HH:mm').format(record.createdAt);
    
    // Status visual
    Color statusColor = context.colors.textMuted;
    if (record.status.toLowerCase() == 'completed' || record.status.toLowerCase() == 'success') {
      statusColor = context.colors.success;
    } else if (record.status.toLowerCase() == 'failed' || record.status.toLowerCase() == 'error') {
      statusColor = context.colors.error;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: DastraCard(
        borderColor: context.colors.borderSubtle,
        onTap: () => controller.openFile(record),
        padding: EdgeInsets.all(isCompact ? AppSpacing.sm : AppSpacing.md),
        child: Row(
          children: [
            // Tool/File Icon
            Container(
              width: isCompact ? 40 : 48,
              height: isCompact ? 40 : 48,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(iconData, color: iconColor, size: isCompact ? 22 : 28),
            ),
            SizedBox(width: AppSpacing.md),
            
            // Core Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          record.toolName,
                          style: context.textStyles.labelLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    'From: $originalFileName',
                    style: context.textStyles.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Text(
                        dateStr,
                        style: context.textStyles.caption,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Text(
                          record.status.toUpperCase(),
                          style: context.textStyles.caption.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 9,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        _formatBytes(record.outputSize),
                        style: context.textStyles.caption,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Actions
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    record.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: record.isFavorite ? context.colors.accentOrange : context.colors.textMuted,
                    size: 20,
                  ),
                  onPressed: () => controller.toggleFavorite(record),
                  tooltip: record.isFavorite ? 'Remove from favorites' : 'Add to favorites',
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert_rounded, color: context.colors.textMuted, size: 20),
                  color: context.colors.surface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                  onSelected: (val) {
                    if (val == 'open') controller.openFile(record);
                    if (val == 'folder') controller.openFolder(record);
                    if (val == 'delete') _showDeleteDialog(context);
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'open',
                      child: Row(
                        children: [
                          Icon(Icons.open_in_new_rounded, size: 18, color: Theme.of(context).colorScheme.onSurface),
                          const SizedBox(width: AppSpacing.sm),
                          const Text('Open File'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'folder',
                      child: Row(
                        children: [
                          Icon(Icons.folder_open_rounded, size: 18, color: Theme.of(context).colorScheme.onSurface),
                          const SizedBox(width: AppSpacing.sm),
                          const Text('Show in Folder'),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline_rounded, size: 18, color: Theme.of(context).colorScheme.error),
                          const SizedBox(width: AppSpacing.sm),
                          Text('Delete', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
