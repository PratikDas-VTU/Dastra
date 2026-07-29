import 'package:flutter/material.dart';
import '../../utils/tool_registry.dart';

class UpgradeDialog extends StatelessWidget {
  final String toolId;

  const UpgradeDialog({
    super.key,
    required this.toolId,
  });

  static Future<void> show(BuildContext context, {required String toolId}) {
    return showDialog(
      context: context,
      builder: (context) => UpgradeDialog(toolId: toolId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.workspace_premium_rounded, color: Color(0xFF8B5CF6), size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Dastra Pro – Coming Soon',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thank you for trying this feature.',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          const Text(
            'This tool is planned to become part of Dastra Pro in a future release.',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          const Text(
            'Dastra Pro will introduce advanced productivity features such as:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 12),
          _buildFeatureRow(Icons.picture_as_pdf_rounded, 'PDF → Word Conversion'),
          _buildFeatureRow(Icons.description_rounded, 'Word → PDF Conversion'),
          _buildFeatureRow(Icons.slideshow_rounded, 'PowerPoint → PDF Conversion'),
          _buildFeatureRow(Icons.library_add_check_rounded, 'Batch Processing'),
          _buildFeatureRow(Icons.document_scanner_rounded, 'OCR'),
          _buildFeatureRow(Icons.auto_awesome_mosaic_rounded, 'Advanced Productivity Tools'),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Subscriptions and licensing are not available yet. They will be introduced in a future version of Dastra.\n\nThank you for supporting the project during its early development.',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF8B5CF6),
            foregroundColor: Colors.white,
          ),
          child: const Text('Continue Using Free Features'),
        ),
      ],
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF8B5CF6)),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
