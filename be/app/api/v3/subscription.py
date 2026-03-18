from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.auth_v3 import get_firebase_user
from app.models.user import User
from app.repositories.subscription_repository import SubscriptionRepository
from app.repositories.service_repository import ServiceRepository
from app.repositories.project_repository import ProjectRepository
from app.models.subscription import SubscriptionPlan
from app.models.service import ServiceState
from app.schemas.subscription_schema import SubscriptionResponse

router = APIRouter(prefix="/subscription", tags=["Subscription (v3)"])


@router.get("", response_model=SubscriptionResponse)
async def get_subscription(
    user: User = Depends(get_firebase_user),
    db: Session = Depends(get_db),
):
    """Get current user's subscription"""
    sub_repo = SubscriptionRepository(db)
    sub = sub_repo.get_by_user_id(user.id)

    if not sub:
        # Auto-create if missing (backfill for existing users)
        sub = sub_repo.create(user_id=user.id, plan="pro", status="active")

    return sub


@router.post("/reactivate", response_model=SubscriptionResponse)
async def reactivate_monitoring(
    user: User = Depends(get_firebase_user),
    db: Session = Depends(get_db),
):
    """
    Reactivate monitoring after inactivity suspension.
    Only valid when plan=free AND monitoring_suspended_at is not null.
    """
    sub_repo = SubscriptionRepository(db)
    sub = sub_repo.get_by_user_id(user.id)

    if not sub:
        raise HTTPException(status_code=404, detail="Subscription not found")

    if sub.plan != SubscriptionPlan.FREE:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Reactivation is only available for free plan users"
        )

    if sub.monitoring_suspended_at is None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Monitoring is not suspended"
        )

    # Clear suspension
    sub = sub_repo.clear_suspended(sub.id)

    # Restore service_state to healthy for all user's services
    project_repo = ProjectRepository(db)
    service_repo = ServiceRepository(db)
    projects = project_repo.find_by_user_id(user_id=user.id, limit=1000)
    for project in projects:
        services = service_repo.find_all(project_id=project.id, limit=10000)
        for svc in services:
            if svc.service_state == ServiceState.INACTIVE:
                service_repo.update_state(svc.id, ServiceState.HEALTHY)

    return sub
