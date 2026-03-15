import 'package:freezed_annotation/freezed_annotation.dart';

part 'add_service_state.freezed.dart';

@freezed
class AddServiceState with _$AddServiceState {
  const factory AddServiceState({
    @Default(false) bool isLoading,
    @Default(<String, String>{}) Map<String, String> errorMessage,
  }) = _AddServiceState;
}
