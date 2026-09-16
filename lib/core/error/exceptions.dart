/// Custom exception for Firebase operations
class FirebaseException implements Exception {
  final String message;
  final String? code;

  FirebaseException({required this.message, this.code});

  @override
  String toString() => 'FirebaseException($code): $message';
}

/// Custom exception for network operations
class NetworkException implements Exception {
  final String message;

  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}
