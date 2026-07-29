import 'package:flutter/material.dart';
import '../../di/service_locator.dart';
import '../../premium/feature_gate_service.dart';
import 'feature_lock_overlay.dart';

class GatedToolScreen extends StatelessWidget {
  final String toolId;
  final Widget child;

  const GatedToolScreen({
    super.key,
    required this.toolId,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final gate = sl<FeatureGateService>();
    final isLocked = !gate.canAccessTool(toolId);

    return FeatureLockOverlay(
      isLocked: isLocked,
      toolId: toolId,
      child: child,
    );
  }
}
