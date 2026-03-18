from datetime import datetime
from typing import Optional

from sqlalchemy.orm import Session

from app.models.subscription import Subscription, SubscriptionPlan, SubscriptionStatus


class SubscriptionRepository:
    """Repository for Subscription operations"""

    def __init__(self, db: Session):
        self.db = db

    def get_by_user_id(self, user_id: int) -> Optional[Subscription]:
        """Get subscription by user ID"""
        return self.db.query(Subscription).filter(Subscription.user_id == user_id).first()

    def create(self, user_id: int, plan: str = "pro", status: str = "active") -> Subscription:
        """Create a new subscription for a user"""
        subscription = Subscription(
            user_id=user_id,
            plan=SubscriptionPlan(plan),
            status=SubscriptionStatus(status),
            started_at=datetime.utcnow(),
        )
        self.db.add(subscription)
        self.db.commit()
        self.db.refresh(subscription)
        return subscription

    def update_plan(self, subscription_id: int, new_plan: str) -> Optional[Subscription]:
        """Update plan, recording previous plan and timestamp"""
        sub = self.db.query(Subscription).filter(Subscription.id == subscription_id).first()
        if not sub:
            return None
        sub.previous_plan = sub.plan
        sub.plan_changed_at = datetime.utcnow()
        sub.plan = SubscriptionPlan(new_plan)
        self.db.commit()
        self.db.refresh(sub)
        return sub

    def set_suspended(self, subscription_id: int, suspended_at: datetime) -> Optional[Subscription]:
        """Mark monitoring as suspended"""
        sub = self.db.query(Subscription).filter(Subscription.id == subscription_id).first()
        if not sub:
            return None
        sub.monitoring_suspended_at = suspended_at
        self.db.commit()
        self.db.refresh(sub)
        return sub

    def clear_suspended(self, subscription_id: int) -> Optional[Subscription]:
        """Clear monitoring suspension"""
        sub = self.db.query(Subscription).filter(Subscription.id == subscription_id).first()
        if not sub:
            return None
        sub.monitoring_suspended_at = None
        self.db.commit()
        self.db.refresh(sub)
        return sub
