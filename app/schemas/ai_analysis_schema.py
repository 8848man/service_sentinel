from datetime import datetime
from typing import Optional
from pydantic import BaseModel, Field, ConfigDict


class AIAnalysisRequest(BaseModel):
    model_config = ConfigDict(protected_namespaces=())

    force_reanalyze: bool = False
    model_preference: Optional[str] = None


class SuggestedAction(BaseModel):
    action: str
    priority: str  # high, medium, low
    estimated_impact: str


class AIAnalysisResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True, protected_namespaces=())

    id: int
    incident_id: int
    model_used: str
    prompt_tokens: Optional[int]
    completion_tokens: Optional[int]
    total_cost_usd: Optional[float]
    root_cause_hypothesis: str
    confidence_score: Optional[float]
    debug_checklist: list[str]
    suggested_actions: list[dict]
    related_error_patterns: Optional[list[str]]
    analyzed_at: datetime
    analysis_duration_ms: Optional[int]


class AIAnalysisSummary(BaseModel):
    total_analyses: int
    total_cost_usd: float
    avg_analysis_time_ms: float
    models_used: dict[str, int]
