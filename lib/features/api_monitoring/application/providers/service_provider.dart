import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/di/repository_providers.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/service.dart';
import '../../domain/repositories/service_repository.dart';
import '../../domain/usecases/load_services.dart';
import '../../domain/usecases/create_service.dart';
import '../../domain/usecases/update_service.dart';
import '../../domain/usecases/delete_service.dart';

part 'service_provider.g.dart';

/// Provider for LoadServices use case
@riverpod
LoadServices loadServices(LoadServicesRef ref) {
  return LoadServices(
    repository: ref.watch(serviceRepositoryProvider),
  );
}

/// Provider to fetch all services for current project
/// This provider auto-refreshes when dependencies change
@riverpod
Future<List<Service>> services(ServicesRef ref) async {
  final useCase = ref.watch(loadServicesProvider);
  final result = await useCase.execute();

  if (result.isSuccess) {
    return result.dataOrNull!;
  } else {
    throw result.errorOrNull!;
  }
}

/// Provider to fetch active services only
@riverpod
Future<List<Service>> activeServices(ActiveServicesRef ref) async {
  final useCase = ref.watch(loadServicesProvider);
  final result = await useCase.executeActive();

  if (result.isSuccess) {
    return result.dataOrNull!;
  } else {
    throw result.errorOrNull!;
  }
}

/// Provider to fetch a service by ID
@riverpod
Future<Service> serviceById(ServiceByIdRef ref, int serviceId) async {
  final repository = ref.watch(serviceRepositoryProvider);
  final result = await repository.getById(serviceId);

  if (result.isSuccess) {
    return result.dataOrNull!;
  } else {
    throw result.errorOrNull!;
  }
}

/// Provider to fetch service statistics
@riverpod
Future<ServiceStats> serviceStats(
  ServiceStatsRef ref,
  int serviceId,
  String period,
) async {
  final repository = ref.watch(serviceRepositoryProvider);
  final result = await repository.getStats(serviceId, period);

  if (result.isSuccess) {
    return result.dataOrNull!;
  } else {
    throw result.errorOrNull!;
  }
}

/// Provider for CreateService use case
@riverpod
CreateService createService(CreateServiceRef ref) {
  return CreateService(
    repository: ref.watch(serviceRepositoryProvider),
  );
}

/// Provider for UpdateService use case
@riverpod
UpdateService updateService(UpdateServiceRef ref) {
  return UpdateService(
    repository: ref.watch(serviceRepositoryProvider),
  );
}

/// Provider for DeleteService use case
@riverpod
DeleteService deleteService(DeleteServiceRef ref) {
  return DeleteService(
    repository: ref.watch(serviceRepositoryProvider),
  );
}
