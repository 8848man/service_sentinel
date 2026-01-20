from sqlalchemy import Column, Integer, String, Boolean, DateTime, ForeignKey, Text
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
import secrets

from app.core.database import Base


def generate_api_key() -> str:
    """Generate a secure API key"""
    return f"ss_{secrets.token_urlsafe(32)}"


class APIKey(Base):
    """
    APIKey provides project-scoped authentication.
    Each API key belongs to a single Project.
    """
    __tablename__ = "api_keys"

    id = Column(Integer, primary_key=True, index=True)
    project_id = Column(Integer, ForeignKey("projects.id", ondelete="CASCADE"), nullable=False, index=True)

    # Key details
    key_value = Column(String(200), unique=True, nullable=False, index=True)
    name = Column(String(100), nullable=False)  # Human-readable name like "Production Key"
    description = Column(Text, nullable=True)

    # Key status
    is_active = Column(Boolean, default=True, index=True)

    # Usage tracking
    last_used_at = Column(DateTime(timezone=True), nullable=True)
    usage_count = Column(Integer, default=0)

    # Metadata
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    expires_at = Column(DateTime(timezone=True), nullable=True)  # Optional expiration

    # Relationships
    project = relationship("Project", back_populates="api_keys")
