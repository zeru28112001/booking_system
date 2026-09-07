// Typed exceptions used across all features.
// Throw these from ApiClient / repositories; catch them in providers.

class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection. Please try again.']);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = 'Session expired. Please login again.']);
}

class ServerException extends AppException {
  const ServerException([super.message = 'Something went wrong on the server. Please try again.']);
}

class NotFoundException extends AppException {
  const NotFoundException([super.message = 'The requested resource was not found.']);
}

class ValidationException extends AppException {
  const ValidationException(super.message);
}
