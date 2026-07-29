import 'dart:io';

abstract class StorageStrategy {
  /// Initialize the storage strategy, ensuring required directories exist.
  Future<void> initialize();

  /// The directory for application databases.
  Future<Directory> getDatabaseDirectory();
  
  /// The directory for temporary processing files.
  Future<Directory> getTempDirectory();
  
  /// The default output directory for user exports.
  Future<Directory> getExportsDirectory();
  
  /// The directory for logs.
  Future<Directory> getLogsDirectory();

  /// The directory for application settings.
  Future<Directory> getSettingsDirectory();
}
