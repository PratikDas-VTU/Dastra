enum DuplicateHandlingStrategy { autoRename, replace, ask }

class OutputConfiguration {
  final String filename;
  final String folderPath;
  final DuplicateHandlingStrategy duplicateStrategy;
  final bool rememberFolder;
  final bool openAfterConversion;

  const OutputConfiguration({
    required this.filename,
    required this.folderPath,
    this.duplicateStrategy = DuplicateHandlingStrategy.autoRename,
    this.rememberFolder = true,
    this.openAfterConversion = false,
  });

  OutputConfiguration copyWith({
    String? filename,
    String? folderPath,
    DuplicateHandlingStrategy? duplicateStrategy,
    bool? rememberFolder,
    bool? openAfterConversion,
  }) {
    return OutputConfiguration(
      filename: filename ?? this.filename,
      folderPath: folderPath ?? this.folderPath,
      duplicateStrategy: duplicateStrategy ?? this.duplicateStrategy,
      rememberFolder: rememberFolder ?? this.rememberFolder,
      openAfterConversion: openAfterConversion ?? this.openAfterConversion,
    );
  }
}
