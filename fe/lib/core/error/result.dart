import 'package:freezed_annotation/freezed_annotation.dart';
import 'app_error.dart';

part 'result.freezed.dart';

/// Result type for handling success and failure cases
/// Prevents throwing exceptions across layers
@freezed
class Result<T> with _$Result<T> {
  const factory Result.success(T data) = Success<T>;
  const factory Result.failure(AppError error) = Failure<T>;

  const Result._();

  /// Check if result is success
  bool get isSuccess => this is Success<T>;

  /// Check if result is failure
  bool get isFailure => this is Failure<T>;

  /// Get data if success, null otherwise
  T? get dataOrNull => when(
        success: (data) => data,
        failure: (_) => null,
      );

  /// Get error if failure, null otherwise
  AppError? get errorOrNull => when(
        success: (_) => null,
        failure: (error) => error,
      );

  /// Transform success value
  Result<R> mapData<R>(R Function(T data) transform) {
    return when(
      success: (data) => Result.success(transform(data)),
      failure: (error) => Result.failure(error),
    );
  }

  /// Chain async operations
  Future<Result<R>> flatMap<R>(
    Future<Result<R>> Function(T data) transform,
  ) async {
    return when(
      success: (data) => transform(data),
      failure: (error) => Result.failure(error),
    );
  }

  /// Get data or throw error
  T getOrThrow() {
    return when(
      success: (data) => data,
      failure: (error) => throw error,
    );
  }

  /// Get data or return default value
  T getOrElse(T defaultValue) {
    return when(
      success: (data) => data,
      failure: (_) => defaultValue,
    );
  }
}
