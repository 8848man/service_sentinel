from datetime import datetime, timedelta
from typing import Optional
from sqlalchemy.orm import Session
from sqlalchemy import func, and_

from app.models.service import Service, ServiceState
from app.models.health_check import HealthCheck
from app.models.incident import Incident, IncidentStatus, IncidentSeverity
from app.models.ai_analysis import AIAnalysis
from app.models.project import Project


class DashboardRepository:
    """Repository for dashboard data aggregation"""

    def __init__(self, db: Session):
        self.db = db

    # def get_overview_data(self, project_id: int) -> dict:
    #     """
    #     Get dashboard overview data for a project.
    #     Returns services with their health status and incident counts.
    #     """
    #     # Get all active services for this project
    #     services = self.db.query(Service).filter(
    #         Service.project_id == project_id,
    #         Service.is_active == True
    #     ).all()
    #
    #     service_statuses = []
    #
    #     for service in services:
    #         # Get latest health check
    #         latest_check = self.db.query(HealthCheck).filter(
    #             HealthCheck.service_id == service.id
    #         ).order_by(HealthCheck.checked_at.desc()).first()
    #
    #         # Get open incidents
    #         open_incidents = self.db.query(func.count(Incident.id)).filter(
    #             Incident.service_id == service.id,
    #             Incident.status.in_([IncidentStatus.OPEN, IncidentStatus.INVESTIGATING])
    #         ).scalar() or 0
    #
    #         service_statuses.append({
    #             "service_id": service.id,
    #             "service_name": service.name,
    #             "service_type": service.service_type,
    #             "service_state": service.service_state,  # NEW: Use state instead of is_alive
    #             "is_alive": latest_check.is_alive if latest_check else None,  # Keep for backward compat
    #             "last_check": latest_check.checked_at if latest_check else None,
    #             "latency_ms": latest_check.latency_ms if latest_check else None,
    #             "open_incidents": open_incidents,
    #         })
    #
    #     # Calculate overall stats
    #     total_services = len(services)
    #     healthy_services = sum(1 for s in services if s.service_state == ServiceState.HEALTHY)
    #     error_services = sum(1 for s in services if s.service_state == ServiceState.ERROR)
    #     total_incidents = self.db.query(func.count(Incident.id)).join(Service).filter(
    #         Service.project_id == project_id,
    #         Incident.status.in_([IncidentStatus.OPEN, IncidentStatus.INVESTIGATING])
    #     ).scalar() or 0
    #
    #     return {
    #         "total_services": total_services,
    #         "healthy_services": healthy_services,
    #         "error_services": error_services,  # NEW
    #         "unhealthy_services": total_services - healthy_services,  # Keep for backward compat
    #         "total_open_incidents": total_incidents,
    #         "services": service_statuses,
    #         "last_updated": datetime.utcnow()
    #     }
    def get_overview_data(self, project_id: int) -> dict:
        services = self.db.query(Service).filter(
            Service.project_id == project_id,
            Service.is_active == True
        ).all()

        service_summaries = []

        healthy = warning = down = unknown = 0
        open_incidents = 0
        critical_incidents = 0

        for service in services:
            latest_check = self.db.query(HealthCheck).filter(
                HealthCheck.service_id == service.id
            ).order_by(HealthCheck.checked_at.desc()).first()

            active_incident = self.db.query(Incident).filter(
                Incident.service_id == service.id,
                Incident.status.in_([IncidentStatus.OPEN, IncidentStatus.INVESTIGATING])
            ).order_by(Incident.detected_at.desc()).first()

            # status 집계
            match service.service_state:
                case ServiceState.HEALTHY:
                    healthy += 1
                # case ServiceState.WARNING:
                #     warning += 1
                case ServiceState.ERROR:
                    down += 1
                case _:
                    unknown += 1

            if active_incident:
                open_incidents += 1
                if active_incident.severity == IncidentSeverity.CRITICAL:
                    critical_incidents += 1

            service_summaries.append({
                "id": service.id,
                "name": service.name,
                "status": service.service_state.value,  # "healthy", "warning", ...
                "last_check_is_alive": latest_check.is_alive if latest_check else None,
                "last_check_latency_ms": latest_check.latency_ms if latest_check else None,
                "last_checked_at": latest_check.checked_at if latest_check else None,
                "active_incident_id": active_incident.id if active_incident else None,
                "active_incident_severity": active_incident.severity if active_incident else None,
            })

        return {
            "total_services":len(services),
            "active_services": len(services),
            "services_healthy": healthy,
            "services_warning": warning,
            "services_down": down,
            "services_unknown": unknown,

            "open_incidents": open_incidents,
            "critical_incidents": critical_incidents,

            "services": service_summaries,
            "last_updated": datetime.utcnow(),
        }

    def get_metrics(self, project_id: int, since: datetime) -> dict:
        """
        Get aggregated metrics for a project over a time period.
        """
        # Get service IDs for this project
        service_ids_query = self.db.query(Service.id).filter(
            Service.project_id == project_id
        ).subquery()

        # Total health checks
        total_checks = self.db.query(func.count(HealthCheck.id)).filter(
            HealthCheck.service_id.in_(service_ids_query),
            HealthCheck.checked_at >= since
        ).scalar() or 0

        # Failed checks
        failed_checks = self.db.query(func.count(HealthCheck.id)).filter(
            HealthCheck.service_id.in_(service_ids_query),
            HealthCheck.is_alive == False,
            HealthCheck.checked_at >= since
        ).scalar() or 0

        # Average latency
        avg_latency = self.db.query(func.avg(HealthCheck.latency_ms)).filter(
            HealthCheck.service_id.in_(service_ids_query),
            HealthCheck.is_alive == True,
            HealthCheck.checked_at >= since
        ).scalar() or 0.0

        # Uptime percentage
        uptime_percentage = ((total_checks - failed_checks) / total_checks * 100) if total_checks > 0 else 100.0

        # Total incidents
        total_incidents = self.db.query(func.count(Incident.id)).filter(
            Incident.service_id.in_(service_ids_query),
            Incident.detected_at >= since
        ).scalar() or 0

        # Open incidents
        open_incidents = self.db.query(func.count(Incident.id)).filter(
            Incident.service_id.in_(service_ids_query),
            Incident.status.in_([IncidentStatus.OPEN, IncidentStatus.INVESTIGATING])
        ).scalar() or 0

        # AI analysis count
        ai_analyses_count = self.db.query(func.count(AIAnalysis.id)).join(Incident).filter(
            Incident.service_id.in_(service_ids_query),
            AIAnalysis.analyzed_at >= since
        ).scalar() or 0

        # Total AI cost
        ai_total_cost = self.db.query(func.sum(AIAnalysis.total_cost_usd)).join(Incident).filter(
            Incident.service_id.in_(service_ids_query),
            AIAnalysis.analyzed_at >= since
        ).scalar() or 0.0

        return {
            "total_health_checks": total_checks,
            "failed_health_checks": failed_checks,
            "uptime_percentage": round(uptime_percentage, 2),
            "average_latency_ms": round(float(avg_latency), 2),
            "total_incidents": total_incidents,
            "open_incidents": open_incidents,
            "ai_analyses_count": ai_analyses_count,
            "ai_total_cost_usd": round(float(ai_total_cost), 4)
        }

    def get_global_aggregations(self) -> dict:
        """
        Get system-wide aggregations across all projects.
        For admin/overview dashboards.
        """
        # Total projects
        total_projects = self.db.query(func.count(Project.id)).scalar() or 0

        # Total services by state
        total_services = self.db.query(func.count(Service.id)).scalar() or 0

        healthy_services = self.db.query(func.count(Service.id)).filter(
            Service.service_state == ServiceState.HEALTHY
        ).scalar() or 0

        error_services = self.db.query(func.count(Service.id)).filter(
            Service.service_state == ServiceState.ERROR
        ).scalar() or 0

        inactive_services = self.db.query(func.count(Service.id)).filter(
            Service.service_state == ServiceState.INACTIVE
        ).scalar() or 0

        # Active incidents
        active_incidents = self.db.query(func.count(Incident.id)).filter(
            Incident.status.in_([IncidentStatus.OPEN, IncidentStatus.INVESTIGATING])
        ).scalar() or 0

        # Projects with degraded health (at least 1 error service or active incident)
        # Use subquery approach for efficiency
        degraded_project_ids = self.db.query(Service.project_id).filter(
            Service.service_state == ServiceState.ERROR
        ).union(
            self.db.query(Service.project_id).join(Incident).filter(
                Incident.status.in_([IncidentStatus.OPEN, IncidentStatus.INVESTIGATING])
            )
        ).distinct().subquery()

        degraded_projects = self.db.query(func.count()).select_from(degraded_project_ids).scalar() or 0

        return {
            "total_projects": total_projects,
            "total_services": total_services,
            "healthy_services": healthy_services,
            "error_services": error_services,
            "inactive_services": inactive_services,
            "active_incidents": active_incidents,
            "degraded_projects": degraded_projects
        }
