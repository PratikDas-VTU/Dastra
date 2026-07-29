enum BuildProfile {
  developer,
  public,
  internal,
  enterprise,
}

class BuildConfig {
  static const String _profileString = String.fromEnvironment(
    'BUILD_PROFILE',
    defaultValue: 'developer',
  );

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

  static bool get isDeveloperProfile => activeProfile == BuildProfile.developer;
  static bool get isPublicProfile => activeProfile == BuildProfile.public;
  static bool get isInternalProfile => activeProfile == BuildProfile.internal;
  static bool get isEnterpriseProfile => activeProfile == BuildProfile.enterprise;

  /// Defines whether debug tools and logs are visible based on the active profile.
  static bool get showDebugTools => isDeveloperProfile || isInternalProfile;
}
