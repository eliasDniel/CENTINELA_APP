// RF: Custom exceptions for specific error scenarios
class NetworkException implements Exception {
  final String message;

  NetworkException(this.message);

  @override
  String toString() => message;
}

class CacheException implements Exception {
  final String message;

  CacheException(this.message);

  @override
  String toString() => message;
}

class ValidationException implements Exception {
  final String message;

  ValidationException(this.message);

  @override
  String toString() => message;
}
