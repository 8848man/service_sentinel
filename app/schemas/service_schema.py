from datetime import datetime
from typing import Optional, Dict
from pydantic import BaseModel, HttpUrl, Field, ConfigDict

from app.models.service import ServiceType, HttpMethod


class ServiceCreate(BaseModel):
    name: str = Field(..., min_length=1, max_length=100)
    description: Optional[str] = Field(None, max_length=500)
    endpoint_url: HttpUrl
    http_method: HttpMethod = HttpMethod.GET
    service_type: ServiceType
    headers: Optional[dict] = Field(default_factory=dict)
    request_body: Optional[dict] = None
    expected_status_codes: list[int] = Field(default_factory=lambda: [200])
    timeout_seconds: int = Field(default=10, ge=1, le=300)
    check_interval_seconds: int = Field(default=60, ge=10, le=3600)
    failure_threshold: int = Field(default=3, ge=1, le=10)


class ServiceUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=1, max_length=100)
    description: Optional[str] = Field(None, max_length=500)
    endpoint_url: Optional[HttpUrl] = None
    http_method: Optional[HttpMethod] = None
    headers: Optional[dict] = None
    request_body: Optional[dict] = None
    expected_status_codes: Optional[list[int]] = None
    timeout_seconds: Optional[int] = Field(None, ge=1, le=300)
    check_interval_seconds: Optional[int] = Field(None, ge=10, le=3600)
    failure_threshold: Optional[int] = Field(None, ge=1, le=10)
    is_active: Optional[bool] = None


class ServiceResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    name: str
    description: Optional[str]
    endpoint_url: str
    http_method: HttpMethod
    service_type: ServiceType
    headers: Optional[Dict[str, str]] = None
    request_body: Optional[dict]
    expected_status_codes: list[int]
    timeout_seconds: int
    check_interval_seconds: int
    failure_threshold: int
    is_active: bool
    created_at: datetime
    updated_at: datetime
    last_checked_at: Optional[datetime]


class ServiceStats(BaseModel):
    service_id: int
    uptime_percentage: float
    total_checks: int
    successful_checks: int
    failed_checks: int
    avg_latency_ms: float
    period: str  # e.g., "24h", "7d"