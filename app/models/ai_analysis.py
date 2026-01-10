from sqlalchemy import Column, Integer, String, DateTime, Text, ForeignKey, JSON, Float
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.core.database import Base


class AIAnalysis(Base):
    __tablename__ = "ai_analyses"

    id = Column(Integer, primary_key=True, index=True)
    incident_id = Column(Integer, ForeignKey("incidents.id", ondelete="CASCADE"), nullable=False, unique=True)

    # AI model info
    model_used = Column(String(50), nullable=False)  # e.g., "gpt-4", "claude-3"
    prompt_tokens = Column(Integer, nullable=True)
    completion_tokens = Column(Integer, nullable=True)
    total_cost_usd = Column(Float, nullable=True)

    # Analysis results
    root_cause_hypothesis = Column(Text, nullable=False)
    confidence_score = Column(Float, nullable=True)  # 0.0 to 1.0

    # Structured suggestions
    debug_checklist = Column(JSON, nullable=False)  # ["Check DNS", "Verify SSL cert"]
    suggested_actions = Column(JSON, nullable=False)  # [{"action": "...", "priority": "high"}]
    related_error_patterns = Column(JSON, nullable=True)

    # Full AI response
    raw_response = Column(Text, nullable=True)  # Store full LLM output

    # Timing
    analyzed_at = Column(DateTime(timezone=True), server_default=func.now())
    analysis_duration_ms = Column(Integer, nullable=True)

    # Relationships
    incident = relationship("Incident", back_populates="ai_analysis")
