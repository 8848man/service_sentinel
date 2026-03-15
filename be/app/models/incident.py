from sqlalchemy import Column, Integer, String, Boolean, DateTime, Text, ForeignKey, Enum
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
import enum

from app.core.database import Base


class IncidentStatus(str, enum.Enum):
    OPEN = "open"
    INVESTIGATING = "investigating"
    RESOLVED = "resolved"
    ACKNOWLEDGED = "acknowledged"


class IncidentSeverity(str, enum.Enum):
    CRITICAL = "critical"  # Complete service down
    HIGH = "high"          # Multiple failures
    MEDIUM = "medium"      # Intermittent issues
    LOW = "low"            # Minor degradation


class Incident(Base):
    __tablename__ = "incidents"

    id = Column(Integer, primary_key=True, index=True)
    service_id = Column(Integer, ForeignKey("services.id", ondelete="CASCADE"), nullable=False, index=True)
    trigger_check_id = Column(Integer, ForeignKey("health_checks.id"), nullable=True)

    # Incident details
    title = Column(String(200), nullable=False)  # Auto-generated or custom
    description = Column(Text, nullable=True)
    status = Column(Enum(IncidentStatus), default=IncidentStatus.OPEN, index=True)
    severity = Column(Enum(IncidentSeverity), default=IncidentSeverity.MEDIUM)

    # Failure tracking
    consecutive_failures = Column(Integer, default=1)
    total_affected_checks = Column(Integer, default=1)

    # Timing
    detected_at = Column(DateTime(timezone=True), server_default=func.now(), index=True)
    resolved_at = Column(DateTime(timezone=True), nullable=True)
    acknowledged_at = Column(DateTime(timezone=True), nullable=True)

    # AI Analysis flag
    ai_analysis_requested = Column(Boolean, default=False)
    ai_analysis_completed = Column(Boolean, default=False)

    # Relationships
    service = relationship("Service", back_populates="incidents")
    trigger_check = relationship("HealthCheck", back_populates="incident")
    ai_analysis = relationship("AIAnalysis", back_populates="incident", uselist=False)
