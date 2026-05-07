// RF: Base failure classes for error handling
abstract class Failure {
  final String message;

  Failure(this.message);

  @override
  String toString() => message;
}

class NetworkFailure extends Failure {
  NetworkFailure(String message) : super(message);
}

class CacheFailure extends Failure {
  CacheFailure(String message) : super(message);
}

class ValidationFailure extends Failure {
  ValidationFailure(String message) : super(message);
}

class GeneralFailure extends Failure {
  GeneralFailure(String message) : super(message);
}
