from datetime import datetime
from typing import Optional

from pydantic import BaseModel, ConfigDict


class SubscriptionResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    user_id: int
    plan: str
    status: str
    started_at: datetime
    expires_at: Optional[datetime] = None
    previous_plan: Optional[str] = None
    plan_changed_at: Optional[datetime] = None
    monitoring_suspended_at: Optional[datetime] = None
