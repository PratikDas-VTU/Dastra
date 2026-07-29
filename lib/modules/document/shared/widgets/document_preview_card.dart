import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../image/image_compressor/utils/compression_utils.dart'; // Reusing formatBytes
import '../model/document_job.dart';

class DocumentPreviewCard extends StatefulWidget {
  final DocumentJob job;
  final VoidCallback? onRemove;
  final bool isReorderable;

  const DocumentPreviewCard({
    super.key,
    required this.job,
    this.onRemove,
    this.isReorderable = false,
  });

  @override
  State<DocumentPreviewCard> createState() => _DocumentPreviewCardState();
}

class _DocumentPreviewCardState extends State<DocumentPreviewCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: DastraCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            // Icon Placeholder
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: context.colors.documentGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppRadius.md),
                boxShadow: [
                  BoxShadow(
                    color: context.colors.accentBlue.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.picture_as_pdf_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.job.fileName,
                    style: context.textStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.colors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      _buildBadge(Icons.sd_storage_rounded, CompressionUtils.formatBytes(widget.job.fileSize)),
                      if (widget.job.pageCount != null && widget.job.pageCount! > 0) ...[
                        const SizedBox(width: AppSpacing.sm),
                        _buildBadge(Icons.file_copy_rounded, '${widget.job.pageCount} Pages'),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            
            // Actions
            if (widget.onRemove != null)
              IconButton(
                icon: Icon(Icons.close_rounded, color: context.colors.textSecondary),
                onPressed: widget.onRemove,
                tooltip: 'Remove',
                hoverColor: context.colors.error.withValues(alpha: 0.1),
                splashRadius: 20,
              ),
            
            if (widget.isReorderable) ...[
              const SizedBox(width: AppSpacing.sm),
              // Reorder drag handle
              MouseRegion(
                cursor: SystemMouseCursors.grab,
                child: Icon(
                  Icons.drag_indicator_rounded, 
                  color: _isHovering ? context.colors.textPrimary : context.colors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: context.colors.background,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: context.colors.textSecondary),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: context.colors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
