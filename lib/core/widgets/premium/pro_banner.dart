import 'package:flutter/material.dart';
import 'upgrade_dialog.dart';

class ProBanner extends StatelessWidget {
  final String message;

  const ProBanner({
    super.key,
    this.message = 'Upgrade to Dastra Pro for unlimited access',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFFD946EF)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          FilledButton(
            onPressed: () => UpgradeDialog.show(context, featureName: 'This feature'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF8B5CF6),
            ),
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }
}
