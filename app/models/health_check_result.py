from sqlalchemy import (
    Column,
    Integer,
    Boolean,
    String,
    DateTime,
    ForeignKey,
)
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship

from app.core.database import Base


class HealthCheckResult(Base):
    __tablename__ = "health_check_results"

    id = Column(Integer, primary_key=True, index=True)

    service_id = Column(
        Integer,
        ForeignKey("services.id", ondelete="CASCADE"),
        nullable=False,
    )

    is_alive = Column(Boolean, nullable=False)
    status_code = Column(Integer, nullable=True)
    latency_ms = Column(Integer, nullable=True)
    error_message = Column(String(500), nullable=True)

    checked_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
    )

    service = relationship("Service")