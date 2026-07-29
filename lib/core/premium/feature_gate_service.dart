import 'dart:io';
import 'package:flutter/foundation.dart';
import '../config/build_config.dart';
import '../models/feature_metadata.dart';
import '../utils/tool_registry.dart';
import 'subscription_service.dart';
import 'subscription_tier.dart';
import 'unauthorized_exception.dart';
import 'package:path_provider/path_provider.dart';

abstract class FeatureRule {
  bool evaluate(FeatureMetadata metadata, SubscriptionService subscriptionService);
  String get reason;
}

class SubscriptionRule implements FeatureRule {
  @override
  bool evaluate(FeatureMetadata metadata, SubscriptionService subscriptionService) {
    if (metadata.isFree) return true;
    if (metadata.isPro) return subscriptionService.hasAccessTo(SubscriptionTier.pro);
    if (metadata.isEnterprise) return subscriptionService.hasAccessTo(SubscriptionTier.enterprise);
    if (metadata.isInternal) return BuildConfig.isInternalProfile;
    return false;
  }

  @override
  String get reason => 'Insufficient subscription tier';
}

class FeatureGateService {
  final SubscriptionService _subscriptionService;
  final List<FeatureRule> _rules = [
    SubscriptionRule(),
    // Future rules can be added here (e.g., PlatformRule, VersionRule, RegionRule)
  ];

  FeatureGateService(this._subscriptionService);

  bool canAccessTool(String toolId) {
    final tool = ToolRegistry.allTools.firstWhere(
      (t) => t.id == toolId,
      orElse: () => throw Exception('Tool $toolId not found in registry'),
    );

    if (BuildConfig.isDeveloperProfile) {
      _logAccessEvent(toolId, true, 'Developer Profile bypass');
      return true;
    }

    for (final rule in _rules) {
      if (!rule.evaluate(tool.metadata, _subscriptionService)) {
        _logAccessEvent(toolId, false, rule.reason);
        return false;
      }
    }

    _logAccessEvent(toolId, true, 'All rules passed');
    return true;
  }

  void ensureAccess(String toolId) {
    if (!canAccessTool(toolId)) {
      throw UnauthorizedException(toolId);
    }
  }

  Future<void> _logAccessEvent(String toolId, bool granted, String reason) async {
    final timestamp = DateTime.now().toIso8601String();
    final profile = BuildConfig.activeProfile.name;
    final tier = _subscriptionService.currentTier.name;
    
    final logMessage = '[AUDIT] $timestamp | Tool: $toolId | Granted: $granted | Profile: $profile | Tier: $tier | Reason: $reason';
    
    // Print to debug console
    debugPrint(logMessage);

    // Also write to an offline local file for future debugging
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/dastra_audit_log.txt');
      await file.writeAsString('$logMessage\n', mode: FileMode.append);
    } catch (e) {
      debugPrint('Failed to write audit log: $e');
    }
  }
}
