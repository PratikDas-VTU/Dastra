import 'subscription_tier.dart';

abstract class LicenseProvider {
  Future<SubscriptionTier> getCurrentTier();
  Future<bool> validateLicense();
}

class LicenseManager {
  final List<LicenseProvider> _providers;

  LicenseManager(this._providers);

  Future<SubscriptionTier> getHighestActiveTier() async {
    SubscriptionTier highest = SubscriptionTier.free;

    for (final provider in _providers) {
      try {
        final isValid = await provider.validateLicense();
        if (isValid) {
          final tier = await provider.getCurrentTier();
          if (tier.index > highest.index) {
            highest = tier;
          }
        }
      } catch (e) {
        // Log provider error but continue checking others
      }
    }

    return highest;
  }
}
