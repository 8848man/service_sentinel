import 'package:freezed_annotation/freezed_annotation.dart';
import 'project.dart';

part 'bootstrap.freezed.dart';

/// Bootstrap response from server
/// Contains both the newly created project and the Guest API Key
@freezed
class BootstrapResponse with _$BootstrapResponse {
  const factory BootstrapResponse({
    required Project project,
    required String apiKey, // Field name: apiKey (matches backend response field 'api_key')
    String? message, // Optional message from server
  }) = _BootstrapResponse;
}

/// Bootstrap request data
/// Contains project creation data for initial guest project
@freezed
class BootstrapRequest with _$BootstrapRequest {
  const factory BootstrapRequest({
    required String name,
    String? description,
  }) = _BootstrapRequest;
}
