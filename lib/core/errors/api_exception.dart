class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic errors;

  ApiException({
    required this.message,
    this.statusCode,
    this.errors,
  });

  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  NetworkException({super.message = 'Network error occurred'});
}

class UnauthorizedException extends ApiException {
  UnauthorizedException({super.message = 'Unauthorized access'})
      : super(statusCode: 401);
}

class ValidationException extends ApiException {
  ValidationException({
    super.message = 'Validation failed',
    super.errors,
  }) : super(statusCode: 422);
}
