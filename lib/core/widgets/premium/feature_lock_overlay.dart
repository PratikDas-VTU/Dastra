import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/tool_registry.dart';

class FeatureLockOverlay extends StatelessWidget {
  final Widget child;
  final bool isLocked;
  final String toolId;

  const FeatureLockOverlay({
    super.key,
    required this.child,
    required this.isLocked,
    required this.toolId,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLocked) return child;

    final tool = ToolRegistry.allTools.firstWhere(
      (t) => t.id == toolId,
      orElse: () => ToolRegistry.allTools.first,
    );

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  size: 48,
                  color: Color(0xFF8B5CF6),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Dastra Pro – Coming Soon',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                tool.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8B5CF6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'This feature will be available in a future release of Dastra.\nThank you for exploring Dastra Pro.',
                style: TextStyle(fontSize: 15, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () => context.go('/'),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Return to Dashboard'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
