import 'dart:convert';

class WorkspaceRecord {
  final String id;
  final String toolId;
  final String toolName;
  final String? engineId;
  final String inputPath;
  final String outputPath;
  final String outputFolder;
  final String outputExtension;
  final int inputSize;
  final int outputSize;
  final int processingTime;
  final DateTime createdAt;
  final String status;
  final bool isFavorite;
  final bool isDeleted;
  
  // Future extensibility fields
  final List<String>? tags;
  final String? notes;
  final String? thumbnailPath;
  final String? projectId;

  WorkspaceRecord({
    required this.id,
    required this.toolId,
    required this.toolName,
    this.engineId,
    required this.inputPath,
    required this.outputPath,
    required this.outputFolder,
    required this.outputExtension,
    required this.inputSize,
    required this.outputSize,
    required this.processingTime,
    required this.createdAt,
    required this.status,
    this.isFavorite = false,
    this.isDeleted = false,
    this.tags,
    this.notes,
    this.thumbnailPath,
    this.projectId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'toolId': toolId,
      'toolName': toolName,
      'engineId': engineId,
      'inputPath': inputPath,
      'outputPath': outputPath,
      'outputFolder': outputFolder,
      'outputExtension': outputExtension,
      'inputSize': inputSize,
      'outputSize': outputSize,
      'processingTime': processingTime,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
      'isFavorite': isFavorite ? 1 : 0,
      'isDeleted': isDeleted ? 1 : 0,
      'tags': tags != null ? jsonEncode(tags) : null,
      'notes': notes,
      'thumbnailPath': thumbnailPath,
      'projectId': projectId,
    };
  }

  factory WorkspaceRecord.fromMap(Map<String, dynamic> map) {
    List<String>? parsedTags;
    if (map['tags'] != null && map['tags'].toString().isNotEmpty) {
      try {
        parsedTags = List<String>.from(jsonDecode(map['tags']));
      } catch (_) {}
    }

    return WorkspaceRecord(
      id: map['id'],
      toolId: map['toolId'],
      toolName: map['toolName'],
      engineId: map['engineId'],
      inputPath: map['inputPath'],
      outputPath: map['outputPath'],
      outputFolder: map['outputFolder'],
      outputExtension: map['outputExtension'],
      inputSize: map['inputSize'],
      outputSize: map['outputSize'],
      processingTime: map['processingTime'],
      createdAt: DateTime.parse(map['createdAt']),
      status: map['status'],
      isFavorite: map['isFavorite'] == 1,
      isDeleted: map['isDeleted'] == 1,
      tags: parsedTags,
      notes: map['notes'],
      thumbnailPath: map['thumbnailPath'],
      projectId: map['projectId'],
    );
  }
}
