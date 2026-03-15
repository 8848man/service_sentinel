from sqlalchemy import Column, Integer, String, Boolean, DateTime, Text, ForeignKey
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.core.database import Base


class HealthCheck(Base):
    __tablename__ = "health_checks"

    id = Column(Integer, primary_key=True, index=True)
    service_id = Column(Integer, ForeignKey("services.id", ondelete="CASCADE"), nullable=False, index=True)

    # Check results
    is_alive = Column(Boolean, nullable=False)
    status_code = Column(Integer, nullable=True)
    latency_ms = Column(Integer, nullable=False)

    # Response data
    response_body = Column(Text, nullable=True)  # First 1000 chars
    error_message = Column(Text, nullable=True)
    error_type = Column(String(100), nullable=True)  # timeout, connection, ssl, etc.

    # Timing
    checked_at = Column(DateTime(timezone=True), server_default=func.now(), index=True)

    # Analysis flag
    needs_analysis = Column(Boolean, default=False)

    # Relationships
    service = relationship("Service", back_populates="health_checks")
    incident = relationship("Incident", back_populates="trigger_check", uselist=False)
