import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../../image/image_compressor/utils/compression_utils.dart'; // Reusing formatBytes
import '../../shared/model/document_job.dart';

class ImageToPdfPreviewCard extends StatefulWidget {
  final DocumentJob job;
  final int index;
  final VoidCallback? onRemove;

  const ImageToPdfPreviewCard({
    super.key,
    required this.job,
    required this.index,
    this.onRemove,
  });

  @override
  State<ImageToPdfPreviewCard> createState() => _ImageToPdfPreviewCardState();
}

class _ImageToPdfPreviewCardState extends State<ImageToPdfPreviewCard> {
  bool _isHovering = false;

  Future<String> _getDimensions() async {
    if (widget.job.bytes == null) return 'Unknown';
    try {
      final ui.Image image = await decodeImageFromList(widget.job.bytes!);
      final res = '${image.width} × ${image.height}';
      image.dispose();
      return res;
    } catch (e) {
      return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onHover: (hovering) => setState(() => _isHovering = hovering),
        onTap: () {}, // Empty tap for hover/splash effects
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: _isHovering ? context.colors.surface.withValues(alpha: 0.9) : context.colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovering ? context.colors.accentBlue.withValues(alpha: 0.5) : context.colors.border,
          ),
          boxShadow: [
            if (_isHovering)
              BoxShadow(
                color: context.colors.accentBlue.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Drag handle
            MouseRegion(
              cursor: SystemMouseCursors.grab,
              child: Icon(
                Icons.drag_indicator_rounded, 
                color: _isHovering ? context.colors.textPrimary : context.colors.textSecondary,
              ),
            ),
            const SizedBox(width: 8),

            // Index Badge
            CircleAvatar(
              radius: 12,
              backgroundColor: context.colors.background,
              child: Text(
                '${widget.index + 1}',
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Image Thumbnail
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: context.colors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: context.colors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: widget.job.bytes != null
                  ? Image.memory(
                      widget.job.bytes!,
                      fit: BoxFit.cover,
                    )
                  : Icon(Icons.image_not_supported_rounded, color: context.colors.textSecondary),
            ),
            const SizedBox(width: 16),
            
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
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _buildBadge(Icons.sd_storage_rounded, CompressionUtils.formatBytes(widget.job.fileSize)),
                      const SizedBox(width: 8),
                      FutureBuilder<String>(
                        future: _getDimensions(),
                        builder: (context, snapshot) {
                          return _buildBadge(
                            Icons.aspect_ratio_rounded, 
                            snapshot.data ?? '...'
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            
            // Remove Action
            if (widget.onRemove != null)
              IconButton(
                icon: Icon(Icons.close_rounded, color: context.colors.textSecondary),
                onPressed: widget.onRemove,
                tooltip: 'Remove',
                hoverColor: context.colors.error.withValues(alpha: 0.1),
                splashRadius: 20,
              ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: context.colors.background,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: context.colors.textSecondary),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: context.colors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
