# Not yet active — planned for billing integration
import enum
from sqlalchemy import Column, Integer, DateTime, ForeignKey, Enum
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.core.database import Base
from app.models.subscription import SubscriptionPlan


class ChangeReason(str, enum.Enum):
    UPGRADE = "upgrade"
    DOWNGRADE = "downgrade"
    EXPIRY = "expiry"
    CANCELLATION = "cancellation"
    ADMIN = "admin"


class SubscriptionHistory(Base):
    __tablename__ = "subscription_history"

    id = Column(Integer, primary_key=True)
    subscription_id = Column(
        Integer,
        ForeignKey("subscriptions.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )

    previous_plan = Column(Enum(SubscriptionPlan), nullable=False)
    new_plan = Column(Enum(SubscriptionPlan), nullable=False)
    changed_at = Column(DateTime(timezone=True), server_default=func.now())
    reason = Column(Enum(ChangeReason), nullable=True)

    # Relationship
    subscription = relationship("Subscription", back_populates="history")
