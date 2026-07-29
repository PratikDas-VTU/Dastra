enum FeatureAvailability {
  free,
  pro,
  enterprise,
  internal,
}

enum FeatureMaturity {
  stable,
  beta,
  experimental,
  comingSoon,
}

class FeatureMetadata {
  final FeatureAvailability availability;
  final FeatureMaturity maturity;

  const FeatureMetadata({
    this.availability = FeatureAvailability.free,
    this.maturity = FeatureMaturity.stable,
  });

  bool get isPro => availability == FeatureAvailability.pro;
  bool get isEnterprise => availability == FeatureAvailability.enterprise;
  bool get isInternal => availability == FeatureAvailability.internal;
  bool get isFree => availability == FeatureAvailability.free;

  bool get isStable => maturity == FeatureMaturity.stable;
  bool get isBeta => maturity == FeatureMaturity.beta;
  bool get isExperimental => maturity == FeatureMaturity.experimental;
  bool get isComingSoon => maturity == FeatureMaturity.comingSoon;
}
