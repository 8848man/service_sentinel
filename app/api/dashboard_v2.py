from datetime import datetime, timedelta
from typing import Optional
from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from sqlalchemy import func, and_

from app.core.database import get_db
from app.models.service import Service
from app.models.health_check import HealthCheck
from app.models.incident import Incident, IncidentStatus
from app.schemas.dashboard_schema import DashboardOverview, SystemMetrics

router = APIRouter(prefix="/projects/{project_id}", tags=["Dashboard (Project-Scoped)"])


@router.get("/dashboard/overview", response_model=DashboardOverview)
def get_dashboard_overview(
    project_id: int,
    db: Session = Depends(get_db)
):
    """
    Get dashboard overview with health status for all services.
    """
    # Get all services for this project
    services = db.query(Service).filter(
        Service.project_id == project_id,
        Service.is_active == True
    ).all()

    service_statuses = []

    for service in services:
        # Get latest health check
        latest_check = db.query(HealthCheck).filter(
            HealthCheck.service_id == service.id
        ).order_by(HealthCheck.checked_at.desc()).first()

        # Get open incidents
        open_incidents = db.query(Incident).filter(
            Incident.service_id == service.id,
            Incident.status.in_([IncidentStatus.OPEN, IncidentStatus.INVESTIGATING])
        ).count()

        service_statuses.append({
            "service_id": service.id,
            "service_name": service.name,
            "service_type": service.service_type,
            "is_alive": latest_check.is_alive if latest_check else None,
            "last_check": latest_check.checked_at if latest_check else None,
            "latency_ms": latest_check.latency_ms if latest_check else None,
            "open_incidents": open_incidents,
        })

    # Calculate overall stats
    total_services = len(services)
    healthy_services = sum(1 for s in service_statuses if s["is_alive"] is True)
    total_incidents = db.query(Incident).join(Service).filter(
        Service.project_id == project_id,
        Incident.status.in_([IncidentStatus.OPEN, IncidentStatus.INVESTIGATING])
    ).count()

    return DashboardOverview(
        total_services=total_services,
        healthy_services=healthy_services,
        unhealthy_services=total_services - healthy_services,
        total_open_incidents=total_incidents,
        services=service_statuses,
        last_updated=datetime.utcnow()
    )


@router.get("/dashboard/metrics", response_model=SystemMetrics)
def get_dashboard_metrics(
    project_id: int,
    period: str = Query("24h", pattern="^(1h|24h|7d|30d)$"),
    db: Session = Depends(get_db)
):
    """
    Get aggregated metrics.
    """
    # Calculate time range
    period_map = {
        "1h": timedelta(hours=1),
        "24h": timedelta(hours=24),
        "7d": timedelta(days=7),
        "30d": timedelta(days=30)
    }
    since = datetime.utcnow() - period_map[period]

    # Get service IDs for this project
    service_ids = db.query(Service.id).filter(
        Service.project_id == project_id
    ).subquery()

    # Total health checks
    total_checks = db.query(func.count(HealthCheck.id)).filter(
        HealthCheck.service_id.in_(service_ids),
        HealthCheck.checked_at >= since
    ).scalar() or 0

    # Failed checks
    failed_checks = db.query(func.count(HealthCheck.id)).filter(
        HealthCheck.service_id.in_(service_ids),
        HealthCheck.is_alive == False,
        HealthCheck.checked_at >= since
    ).scalar() or 0

    # Average latency
    avg_latency = db.query(func.avg(HealthCheck.latency_ms)).filter(
        HealthCheck.service_id.in_(service_ids),
        HealthCheck.is_alive == True,
        HealthCheck.checked_at >= since
    ).scalar() or 0.0

    # Uptime percentage
    uptime_percentage = ((total_checks - failed_checks) / total_checks * 100) if total_checks > 0 else 100.0

    # Total incidents
    total_incidents = db.query(func.count(Incident.id)).filter(
        Incident.service_id.in_(service_ids),
        Incident.detected_at >= since
    ).scalar() or 0

    # Open incidents
    open_incidents = db.query(func.count(Incident.id)).filter(
        Incident.service_id.in_(service_ids),
        Incident.status.in_([IncidentStatus.OPEN, IncidentStatus.INVESTIGATING])
    ).scalar() or 0

    # AI analysis count
    from app.models.ai_analysis import AIAnalysis
    ai_analyses_count = db.query(func.count(AIAnalysis.id)).join(Incident).filter(
        Incident.service_id.in_(service_ids),
        AIAnalysis.analyzed_at >= since
    ).scalar() or 0

    # Total AI cost
    ai_total_cost = db.query(func.sum(AIAnalysis.total_cost_usd)).join(Incident).filter(
        Incident.service_id.in_(service_ids),
        AIAnalysis.analyzed_at >= since
    ).scalar() or 0.0

    return SystemMetrics(
        period=period,
        total_health_checks=total_checks,
        failed_health_checks=failed_checks,
        uptime_percentage=round(uptime_percentage, 2),
        average_latency_ms=round(float(avg_latency), 2),
        total_incidents=total_incidents,
        open_incidents=open_incidents,
        ai_analyses_count=ai_analyses_count,
        ai_total_cost_usd=round(float(ai_total_cost), 4)
    )
