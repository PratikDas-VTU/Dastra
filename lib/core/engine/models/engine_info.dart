enum EngineStatus {
  installed,
  notInstalled,
  downloading,
  error,
}

enum EngineType {
  dart,
  native,
  cli,
  com,
}

class EngineInfo {
  final String id;
  final String name;
  final EngineType type;
  final EngineStatus status;
  final String? version;
  final String? downloadUrl;
  final int? sizeBytes;
  final double? downloadProgress; // 0.0 to 1.0

  const EngineInfo({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    this.version,
    this.downloadUrl,
    this.sizeBytes,
    this.downloadProgress,
  });

  EngineInfo copyWith({
    String? id,
    String? name,
    EngineType? type,
    EngineStatus? status,
    String? version,
    String? downloadUrl,
    int? sizeBytes,
    double? downloadProgress,
  }) {
    return EngineInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      status: status ?? this.status,
      version: version ?? this.version,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      downloadProgress: downloadProgress ?? this.downloadProgress,
    );
  }
}
