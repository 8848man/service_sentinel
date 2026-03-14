from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict


class HealthCheckCreate(BaseModel):
    service_id: int
    is_alive: bool
    status_code: Optional[int] = None
    latency_ms: int
    response_body: Optional[str] = None
    error_message: Optional[str] = None
    error_type: Optional[str] = None
    needs_analysis: bool = False


class HealthCheckResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    service_id: int
    is_alive: bool
    status_code: Optional[int]
    latency_ms: int
    response_body: Optional[str]
    error_message: Optional[str]
    error_type: Optional[str]
    checked_at: datetime
    needs_analysis: bool


class HealthCheckListResponse(BaseModel):
    service_id: int
    total: int
    items: list[HealthCheckResponse]