import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:service_sentinel_fe_v2/features/api_monitoring/presentation/states/add_service_state.dart';

part 'add_service_view_model.g.dart';

@riverpod
class AddServiceViewModel extends _$AddServiceViewModel {
  @override
  AddServiceState build() {
    return const AddServiceState(isLoading: false, errorMessage: {});
  }

  Future<void> createService({
    required String name,
    required String description,
    required String endpoint,
    required String method,
    required String type,
    required int timeout,
    required int interval,
    required int threshold,
  }) async {
    state = state.copyWith(isLoading: true);

    // try {}
  }
}
