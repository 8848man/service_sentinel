import 'package:service_sentinel_fe_v2/core/error/result.dart';
import 'package:service_sentinel_fe_v2/features/dashboard/domain/entities/dashboard_overview.dart';
import 'package:service_sentinel_fe_v2/features/dashboard/domain/repositories/dashboard_repository.dart';

class GetDashboardOverview {
  final DashboardRepository _repository;
  final int projectId;

  GetDashboardOverview(this._repository, this.projectId);

  /// Execute use case
  /// @return Result containing DashboardOverview or AppError
  Future<Result<DashboardOverview>> execute() {
    return _repository.getOverview(projectId: projectId);
  }
}
