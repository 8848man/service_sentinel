from datetime import datetime, timedelta
from typing import Optional
from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.auth_v3 import get_auth_context, verify_project_ownership
from app.repositories.dashboard_repository import DashboardRepository
from app.schemas.auth_context import AuthContext
from app.schemas.dashboard_schema import DashboardOverview, SystemMetrics, GlobalDashboardMetrics

router = APIRouter(prefix="/projects/{project_id}", tags=["Dashboard (v3)"])
global_router = APIRouter(prefix="/dashboard", tags=["Global Dashboard (v3)"])


@router.get("/dashboard/overview", response_model=DashboardOverview)
async def get_dashboard_overview(
    project_id: int,
    auth_context: AuthContext = Depends(get_auth_context),
    db: Session = Depends(get_db)
):
    """
    Get dashboard overview with health status for all services.
    Requires project ownership.
    """
    # Verify project ownership
    await verify_project_ownership(auth_context, db)

    # Get overview data from repository
    repo = DashboardRepository(db)
    data = repo.get_overview_data(project_id)

    return DashboardOverview(**data)


@router.get("/dashboard/metrics", response_model=SystemMetrics)
async def get_dashboard_metrics(
    project_id: int,
    period: str = Query("24h", pattern="^(1h|24h|7d|30d)$"),
    auth_context: AuthContext = Depends(get_auth_context),
    db: Session = Depends(get_db)
):
    """
    Get aggregated metrics.
    Requires project ownership.
    """
    # Verify project ownership
    await verify_project_ownership(auth_context, db)

    # Calculate time range
    period_map = {
        "1h": timedelta(hours=1),
        "24h": timedelta(hours=24),
        "7d": timedelta(days=7),
        "30d": timedelta(days=30)
    }
    since = datetime.utcnow() - period_map[period]

    # Get metrics from repository
    repo = DashboardRepository(db)
    metrics = repo.get_metrics(project_id, since)

    return SystemMetrics(
        period=period,
        **metrics
    )


# ===== Global Dashboard Endpoints (no auth required - for admin overview) =====

@global_router.get("/global", response_model=GlobalDashboardMetrics)
async def get_global_dashboard(db: Session = Depends(get_db)):
    """
    Get system-wide dashboard metrics across all projects.
    Useful for admin dashboards or overview pages.

    Note: This endpoint does NOT require authentication.
    Consider adding auth if you want to restrict access to admins only.

    Returns:
    - total_projects: Total number of projects
    - total_services: Total number of services across all projects
    - healthy_services: Services in HEALTHY state
    - error_services: Services in ERROR state
    - inactive_services: Services in INACTIVE state
    - active_incidents: Total open/investigating incidents
    - degraded_projects: Projects with at least one error service or incident
    """
    repo = DashboardRepository(db)
    metrics = repo.get_global_aggregations()

    return GlobalDashboardMetrics(**metrics)
