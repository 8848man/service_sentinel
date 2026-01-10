from datetime import datetime, timedelta
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from sqlalchemy import func

from app.core.database import get_db
from app.models.service import Service
from app.models.health_check import HealthCheck
from app.models.incident import Incident, IncidentStatus, IncidentSeverity
from app.repositories.service_repository import ServiceRepository
from app.repositories.health_check_repository import HealthCheckRepository
from app.repositories.incident_repository import IncidentRepository
from app.repositories.ai_analysis_repository import AIAnalysisRepository
from app.schemas.dashboard_schema import (
    DashboardOverview,
    ServiceHealthSummary,
    SystemMetrics
)

router = APIRouter(prefix="/dashboard", tags=["Dashboard"])


@router.get("/overview", response_model=DashboardOverview)
def get_dashboard_overview(db: Session = Depends(get_db)):
    """Get multi-service health overview"""
    service_repo = ServiceRepository(db)
    health_repo = HealthCheckRepository(db)
    incident_repo = IncidentRepository(db)

    all_services = service_repo.find_all()

    services_healthy = 0
    services_warning = 0
    services_down = 0
    services_unknown = 0

    service_summaries = []

    for service in all_services:
        latest_check = health_repo.find_latest_for_service(service.id)
        open_incident = incident_repo.find_open_incident_for_service(service.id)

        # Determine status
        if not latest_check:
            status = "unknown"
            services_unknown += 1
        elif not latest_check.is_alive:
            status = "down"
            services_down += 1
        elif open_incident and open_incident.severity in [IncidentSeverity.HIGH, IncidentSeverity.CRITICAL]:
            status = "warning"
            services_warning += 1
        else:
            status = "healthy"
            services_healthy += 1

        summary = ServiceHealthSummary(
            id=service.id,
            name=service.name,
            status=status,
            last_check_is_alive=latest_check.is_alive if latest_check else None,
            last_check_latency_ms=latest_check.latency_ms if latest_check else None,
            last_checked_at=service.last_checked_at,
            active_incident_id=open_incident.id if open_incident else None,
            active_incident_severity=open_incident.severity if open_incident else None
        )
        service_summaries.append(summary)

    open_incidents = incident_repo.count_all(status=IncidentStatus.OPEN)
    critical_incidents = incident_repo.count_all(
        status=IncidentStatus.OPEN,
        severity=IncidentSeverity.CRITICAL
    )

    return DashboardOverview(
        total_services=len(all_services),
        active_services=service_repo.count_by_status(is_active=True),
        services_healthy=services_healthy,
        services_warning=services_warning,
        services_down=services_down,
        services_unknown=services_unknown,
        open_incidents=open_incidents,
        critical_incidents=critical_incidents,
        services=service_summaries
    )


@router.get("/metrics", response_model=SystemMetrics)
def get_system_metrics(db: Session = Depends(get_db)):
    """Get system-wide metrics"""
    service_repo = ServiceRepository(db)
    incident_repo = IncidentRepository(db)
    analysis_repo = AIAnalysisRepository(db)

    # Get health check stats for last hour
    one_hour_ago = datetime.utcnow() - timedelta(hours=1)

    successful_checks_last_hour = (
        db.query(HealthCheck)
        .filter(
            HealthCheck.checked_at >= one_hour_ago,
            HealthCheck.is_alive == True
        )
        .count()
    )

    failed_checks_last_hour = (
        db.query(HealthCheck)
        .filter(
            HealthCheck.checked_at >= one_hour_ago,
            HealthCheck.is_alive == False
        )
        .count()
    )

    avg_check_duration = (
        db.query(func.avg(HealthCheck.latency_ms))
        .filter(HealthCheck.checked_at >= one_hour_ago)
        .scalar()
    ) or 0.0

    # Get incident stats
    open_incidents = incident_repo.count_all(status=IncidentStatus.OPEN)

    today_start = datetime.utcnow().replace(hour=0, minute=0, second=0, microsecond=0)
    incidents_resolved_today = (
        db.query(Incident)
        .filter(
            Incident.status == IncidentStatus.RESOLVED,
            Incident.resolved_at >= today_start
        )
        .count()
    )

    # Get AI analysis stats
    ai_stats = analysis_repo.get_summary_stats()

    return SystemMetrics(
        total_services_monitored=service_repo.count_by_status(is_active=True),
        successful_checks_last_hour=successful_checks_last_hour,
        failed_checks_last_hour=failed_checks_last_hour,
        avg_check_duration_ms=round(avg_check_duration, 2),
        ai_analyses_performed=ai_stats["total_analyses"],
        total_ai_cost_usd=ai_stats["total_cost_usd"],
        incidents_open=open_incidents,
        incidents_resolved_today=incidents_resolved_today
    )
