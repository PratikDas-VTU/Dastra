// Enum for the top-level tool categories in Dastra
enum ToolCategory {
  document,
  image,
  security;

  String get label {
    switch (this) {
      case ToolCategory.document:
        return 'Document Tools';
      case ToolCategory.image:
        return 'Image Tools';
      case ToolCategory.security:
        return 'Security Tools';
    }
  }

  String get description {
    switch (this) {
      case ToolCategory.document:
        return 'Convert, merge, split and compress PDF files';
      case ToolCategory.image:
        return 'Compress and convert images between formats';
      case ToolCategory.security:
        return 'Generate and evaluate passwords securely';
    }
  }
}
