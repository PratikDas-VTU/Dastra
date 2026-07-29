abstract class AbstractEngine {
  /// The unique ID of this engine (matches the EngineInfo id)
  String get engineId;
  
  /// Dynamically check if this engine is currently available/installed.
  Future<bool> isAvailable();
  
  /// Verifies the engine functions correctly (e.g. CLI responds)
  Future<bool> healthCheck();
  
  /// Gets the version of the engine, returns 'unknown' if undetectable
  Future<String> engineVersion();
  
  /// Lists specific capabilities (e.g. ['tables', 'images'])
  List<String> get supportedCapabilities;
}

abstract class DocumentConversionEngine extends AbstractEngine {
  // Base class for document conversion engines
}
