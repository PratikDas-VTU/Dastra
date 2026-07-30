enum BuildProfile {
  developer,
  public,
  internal,
  enterprise,
}

enum DastraEdition {
  developer,
  community,
}

class BuildConfig {
  static const String _editionString = String.fromEnvironment('EDITION', defaultValue: 'Community');
  static const String _profileString = String.fromEnvironment('BUILD_PROFILE', defaultValue: 'Public');
  static const String _channelString = String.fromEnvironment('RELEASE_CHANNEL', defaultValue: 'Stable');
  static const String _licenseString = String.fromEnvironment('LICENSE_TIER', defaultValue: 'Community');

  static DastraEdition get edition {
    return _editionString.toLowerCase() == 'developer' ? DastraEdition.developer : DastraEdition.community;
  }

  static BuildProfile get activeProfile {
    switch (_profileString.toLowerCase()) {
      case 'developer':
        return BuildProfile.developer;
      case 'internal':
        return BuildProfile.internal;
      case 'enterprise':
        return BuildProfile.enterprise;
      case 'public':
      default:
        return BuildProfile.public;
    }
  }

  static String get editionName => _editionString;
  static String get releaseChannel => _channelString;
  static String get licenseTier => _licenseString;

  static bool get isDeveloperEdition => edition == DastraEdition.developer;
  static bool get isCommunityEdition => edition == DastraEdition.community;

  static bool get isDeveloperProfile => activeProfile == BuildProfile.developer;
  static bool get isPublicProfile => activeProfile == BuildProfile.public;
  static bool get isInternalProfile => activeProfile == BuildProfile.internal;
  static bool get isEnterpriseProfile => activeProfile == BuildProfile.enterprise;

  /// Defines whether debug tools and logs are visible based on the active profile.
  static bool get showDebugTools => isDeveloperProfile || isInternalProfile || isDeveloperEdition;
}
