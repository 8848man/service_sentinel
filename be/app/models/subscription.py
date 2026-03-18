import enum
from sqlalchemy import Column, Integer, DateTime, ForeignKey, Enum
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.core.database import Base


class SubscriptionPlan(str, enum.Enum):
    FREE = "free"
    PRO = "pro"
    MAX = "max"


class SubscriptionStatus(str, enum.Enum):
    ACTIVE = "active"
    EXPIRED = "expired"
    CANCELLED = "cancelled"
    TRIAL = "trial"


class Subscription(Base):
    __tablename__ = "subscriptions"

    id = Column(Integer, primary_key=True)
    user_id = Column(
        Integer,
        ForeignKey("users.id", ondelete="CASCADE"),
        unique=True,
        nullable=False,
        index=True,
    )

    plan = Column(Enum(SubscriptionPlan), default=SubscriptionPlan.PRO, nullable=False)
    status = Column(Enum(SubscriptionStatus), default=SubscriptionStatus.ACTIVE, nullable=False)

    started_at = Column(DateTime(timezone=True), server_default=func.now())
    expires_at = Column(DateTime(timezone=True), nullable=True)

    previous_plan = Column(Enum(SubscriptionPlan), nullable=True)
    plan_changed_at = Column(DateTime(timezone=True), nullable=True)

    monitoring_suspended_at = Column(DateTime(timezone=True), nullable=True)

    # Relationships
    user = relationship("User", back_populates="subscription")
    history = relationship(
        "SubscriptionHistory",
        back_populates="subscription",
        cascade="all, delete-orphan",
    )
