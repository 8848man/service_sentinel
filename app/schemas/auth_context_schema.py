from typing import Optional, Literal
from pydantic import BaseModel


class AuthContext(BaseModel):
    """
    Request-scoped authentication context for v3 APIs.
    NOT a database entity.

    Represents the authenticated user/guest and their project context.
    """
    # Internal user identifier
    user_id: Optional[int] = None

    # Firebase user identifier (for Firebase-authenticated users)
    firebase_uid: Optional[str] = None

    # Guest identifier (for guest API key authentication)
    guest_uuid: Optional[str] = None

    # Authentication type
    auth_type: Literal["firebase", "guest"]

    # Project context (mandatory in v3)
    project_id: int

    class Config:
        frozen = True  # Make immutable
