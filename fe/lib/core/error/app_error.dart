/// Base class for application errors
abstract class AppError implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  AppError({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => message;
}

/// Network-related errors
class NetworkError extends AppError {
  NetworkError({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Authentication errors
class AuthError extends AppError {
  AuthError({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Validation errors
class ValidationError extends AppError {
  final Map<String, List<String>>? fieldErrors;

  ValidationError({
    required super.message,
    super.code,
    super.originalError,
    this.fieldErrors,
  });
}

/// Server errors
class ServerError extends AppError {
  final int? statusCode;

  ServerError({
    required super.message,
    super.code,
    super.originalError,
    this.statusCode,
  });
}

/// Not found errors
class NotFoundError extends AppError {
  NotFoundError({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Unauthorized errors
class UnauthorizedError extends AppError {
  UnauthorizedError({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Local storage errors
class StorageError extends AppError {
  StorageError({
    required super.message,
    super.code,
    super.originalError,
  });
}

class UndefinedError extends AppError {
  UndefinedError({required super.message, super.code, super.originalError});
}

class AnalysisError extends AppError {
  AnalysisError({required super.message, super.code, super.originalError});
}

/// Guest user project limit exceeded
/// Thrown when guest users attempt to create more than allowed projects
class GuestProjectLimitError extends AppError {
  GuestProjectLimitError({
    required super.message,
    super.code,
    super.originalError,
  });
}
