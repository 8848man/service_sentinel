from datetime import datetime
from pydantic import BaseModel


class LatencyPoint(BaseModel):
    """A single time-bucketed latency measurement."""

    bucket_start: datetime
    avg_ms: float
    p95_ms: float
    sample_count: int


class LatencySeriesResponse(BaseModel):
    """Latency time-series for a single service."""

    service_id: int
    period: str
    bucket: str
    avg_latency_ms: float
    p95_latency_ms: float
    data_points: list[LatencyPoint]
