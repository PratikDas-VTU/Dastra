class DocumentException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const DocumentException(this.message, {this.code, this.originalError});

  @override
  String toString() {
    if (code != null) {
      return 'DocumentException[$code]: $message';
    }
    return 'DocumentException: $message';
  }
}
