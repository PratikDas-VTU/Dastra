import 'package:flutter/foundation.dart';
import 'subscription_tier.dart';
import 'license_manager.dart';

class SubscriptionService extends ChangeNotifier {
  final LicenseManager _licenseManager;
  SubscriptionTier _currentTier = SubscriptionTier.free;

  SubscriptionService(this._licenseManager);

  SubscriptionTier get currentTier => _currentTier;

  Future<void> initialize() async {
    await refreshTier();
  }

  Future<void> refreshTier() async {
    final tier = await _licenseManager.getHighestActiveTier();
    if (_currentTier != tier) {
      _currentTier = tier;
      notifyListeners();
    }
  }

  bool hasAccessTo(SubscriptionTier requiredTier) {
    return _currentTier.index >= requiredTier.index;
  }
}
