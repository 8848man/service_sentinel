from datetime import datetime
from typing import Optional
from pydantic import BaseModel

from app.models.incident import IncidentSeverity


class ServiceHealthSummary(BaseModel):
    id: int
    name: str
    status: str  # "healthy", "warning", "down", "unknown"
    last_check_is_alive: Optional[bool]
    last_check_latency_ms: Optional[int]
    last_checked_at: Optional[datetime]
    active_incident_id: Optional[int]
    active_incident_severity: Optional[IncidentSeverity]


class DashboardOverview(BaseModel):
    total_services: int
    active_services: int
    services_healthy: int
    services_warning: int
    services_down: int
    services_unknown: int
    open_incidents: int
    critical_incidents: int
    services: list[ServiceHealthSummary]
    error_services: int = 0  # NEW: For compatibility with service_state model
    inactive_services: int = 0  # NEW


class GlobalDashboardMetrics(BaseModel):
    """System-wide dashboard metrics across all projects"""
    total_projects: int
    total_services: int
    healthy_services: int
    error_services: int
    inactive_services: int
    active_incidents: int
    degraded_projects: int  # Projects with errors or incidents


class SystemMetrics(BaseModel):
    total_services_monitored: int
    successful_checks_last_hour: int
    failed_checks_last_hour: int
    avg_check_duration_ms: float
    ai_analyses_performed: int
    total_ai_cost_usd: float
    incidents_open: int
    incidents_resolved_today: int
