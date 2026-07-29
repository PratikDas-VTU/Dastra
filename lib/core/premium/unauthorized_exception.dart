class UnauthorizedException implements Exception {
  final String message;
  final String toolId;

  UnauthorizedException(this.toolId, [this.message = 'Unauthorized access to premium feature']);

  @override
  String toString() => 'UnauthorizedException: $message (toolId: $toolId)';
}
