import 'package:service_sentinel_fe_v2/core/error/result.dart';
import 'package:service_sentinel_fe_v2/features/dashboard/domain/entities/dashboard_matrics.dart';
import 'package:service_sentinel_fe_v2/features/dashboard/domain/repositories/dashboard_repository.dart';

class GetDashboardMatrix {
  GetDashboardMatrix(this._repository, this.projectId);
  final DashboardRepository _repository;
  final int projectId;

  /// Execute use case
  /// @return Result containing GlobalDashboardMetrics or AppError
  Future<Result<DashboardMetrics>> execute() {
    return _repository.getMetrics(projectId: projectId);
  }
}
