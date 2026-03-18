import logging
from datetime import datetime, timedelta

from sqlalchemy.orm import Session

from app.core.database import SessionLocal
from app.models.subscription import SubscriptionPlan, SubscriptionStatus
from app.models.service import ServiceState

logger = logging.getLogger(__name__)

INACTIVITY_SUSPENSION_DAYS = 30
WARNING_DAYS = [7, 3, 0]


class InactivityService:
    """
    Checks free-plan users for inactivity and suspends monitoring
    when last_login_at has been idle for INACTIVITY_SUSPENSION_DAYS days.
    Also sends warning notifications at D-7, D-3, and D-0 (day of suspension).
    """

    def __init__(self, db: Session):
        self.db = db

    def check_inactivity(self) -> None:
        """
        Suspend monitoring for free-plan users who have been inactive
        for >= INACTIVITY_SUSPENSION_DAYS days.
        Called daily by scheduler.
        """
        from app.models.user import User
        from app.models.project import Project
        from app.models.service import Service
        from app.repositories.subscription_repository import SubscriptionRepository
        from app.repositories.service_repository import ServiceRepository

        now = datetime.utcnow()
        cutoff = now - timedelta(days=INACTIVITY_SUSPENSION_DAYS)

        # Find free-plan active subscriptions not yet suspended,
        # where user last logged in before the cutoff
        from app.models.subscription import Subscription
        candidates = (
            self.db.query(Subscription)
            .join(User, Subscription.user_id == User.id)
            .filter(
                Subscription.plan == SubscriptionPlan.FREE,
                Subscription.status == SubscriptionStatus.ACTIVE,
                Subscription.monitoring_suspended_at.is_(None),
                User.last_login_at.isnot(None),
                User.last_login_at <= cutoff,
            )
            .all()
        )

        sub_repo = SubscriptionRepository(self.db)
        svc_repo = ServiceRepository(self.db)
        project_repo_query = self.db.query(Project)

        for sub in candidates:
            logger.info(f"Suspending monitoring for user_id={sub.user_id} due to inactivity")

            # Set all services to INACTIVE
            projects = project_repo_query.filter(Project.user_id == sub.user_id).all()
            for project in projects:
                services = svc_repo.find_all(project_id=project.id, limit=10000)
                for svc in services:
                    if svc.service_state != ServiceState.INACTIVE:
                        svc_repo.update_state(svc.id, ServiceState.INACTIVE)

            # Mark subscription as suspended
            sub_repo.set_suspended(sub.id, now)

    def check_warnings(self) -> None:
        """
        Send warning push notifications to free-plan users approaching suspension.
        Warning thresholds: 7, 3, and 0 days before suspension.
        Called daily by scheduler.
        """
        from app.models.user import User
        from app.models.subscription import Subscription
        from app.repositories.device_token_repository import DeviceTokenRepository
        from app.core.firebase import send_push_message

        now = datetime.utcnow()
        dev_token_repo = DeviceTokenRepository(self.db)

        for days_before in WARNING_DAYS:
            # Users whose suspension day falls exactly today + days_before
            # i.e. last_login_at was (INACTIVITY_SUSPENSION_DAYS - days_before) days ago
            target_idle_days = INACTIVITY_SUSPENSION_DAYS - days_before
            range_start = now - timedelta(days=target_idle_days + 1)
            range_end = now - timedelta(days=target_idle_days)

            candidates = (
                self.db.query(Subscription)
                .join(User, Subscription.user_id == User.id)
                .filter(
                    Subscription.plan == SubscriptionPlan.FREE,
                    Subscription.status == SubscriptionStatus.ACTIVE,
                    Subscription.monitoring_suspended_at.is_(None),
                    User.last_login_at.isnot(None),
                    User.last_login_at > range_start,
                    User.last_login_at <= range_end,
                )
                .all()
            )

            for sub in candidates:
                user = self.db.query(User).filter(User.id == sub.user_id).first()
                if not user:
                    continue

                tokens = dev_token_repo.get_active_tokens_by_user(user.id)
                if not tokens:
                    continue

                if days_before == 0:
                    msg = "Your monitoring has been suspended due to inactivity. Log in to reactivate."
                else:
                    msg = (
                        f"Your monitoring will be suspended in {days_before} days "
                        "due to inactivity. Log in to reset the timer."
                    )

                for token in tokens:
                    try:
                        send_push_message(
                            token=token.token,
                            title="Monitoring Suspension Warning",
                            body=msg,
                            data={"type": "inactivity_warning", "days_remaining": str(days_before)},
                        )
                    except Exception as e:
                        logger.warning(
                            f"Failed to send inactivity warning to token {token.id}: {e}"
                        )


def run_inactivity_checks() -> None:
    """Entry point for scheduler — runs both suspension and warning checks."""
    db = SessionLocal()
    try:
        svc = InactivityService(db)
        svc.check_warnings()
        svc.check_inactivity()
    except Exception:
        logger.exception("Error in inactivity check")
    finally:
        db.close()
