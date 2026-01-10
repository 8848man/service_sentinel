from datetime import datetime
from typing import Optional
from pydantic import BaseModel, Field, ConfigDict

from app.models.incident import IncidentStatus, IncidentSeverity


class IncidentCreate(BaseModel):
    service_id: int
    trigger_check_id: Optional[int] = None
    title: str = Field(..., min_length=1, max_length=200)
    description: Optional[str] = None
    severity: IncidentSeverity = IncidentSeverity.MEDIUM
    consecutive_failures: int = 1
    total_affected_checks: int = 1


class IncidentUpdate(BaseModel):
    status: Optional[IncidentStatus] = None
    severity: Optional[IncidentSeverity] = None
    description: Optional[str] = None


class TriggerCheckSummary(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    status_code: Optional[int]
    error_message: Optional[str]
    error_type: Optional[str]
    latency_ms: int
    checked_at: datetime


class IncidentResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    service_id: int
    trigger_check_id: Optional[int]
    title: str
    description: Optional[str]
    status: IncidentStatus
    severity: IncidentSeverity
    consecutive_failures: int
    total_affected_checks: int
    detected_at: datetime
    resolved_at: Optional[datetime]
    acknowledged_at: Optional[datetime]
    ai_analysis_requested: bool
    ai_analysis_completed: bool


class IncidentWithService(IncidentResponse):
    service_name: str


class IncidentListResponse(BaseModel):
    total: int
    items: list[IncidentWithService]
