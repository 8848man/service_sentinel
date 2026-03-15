from datetime import datetime
from typing import Optional
from fastapi import Header, HTTPException, Depends, status
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.repositories.api_key_repository import APIKeyRepository
from app.models.api_key import APIKey


def get_api_key_from_header(x_api_key: Optional[str] = Header(None)) -> str:
    """Extract API key from header"""
    if not x_api_key:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Missing API key. Provide X-API-Key header."
        )
    return x_api_key


async def verify_api_key(
    api_key: str = Depends(get_api_key_from_header),
    db: Session = Depends(get_db)
) -> APIKey:
    """
    Verify API key and return the associated APIKey object.
    This dependency should be used to protect project-scoped endpoints.
    """
    repo = APIKeyRepository(db)
    api_key_obj = repo.find_by_key_value(api_key)

    if not api_key_obj:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid API key"
        )

    if not api_key_obj.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="API key is inactive"
        )

    # Check expiration
    if api_key_obj.expires_at and api_key_obj.expires_at < datetime.utcnow():
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="API key has expired"
        )

    # Update usage tracking
    repo.update_last_used(api_key_obj.id)

    return api_key_obj


async def get_current_project_id(
    api_key: APIKey = Depends(verify_api_key)
) -> int:
    """
    Get the current project ID from the authenticated API key.
    This is the primary way to ensure project-scoping in API endpoints.
    """
    return api_key.project_id


async def verify_project_access(
    project_id: int,
    api_key: APIKey = Depends(verify_api_key)
) -> int:
    """
    Verify that the authenticated API key has access to the specified project.
    Returns the project_id if access is granted.
    Raises 403 if the API key doesn't belong to the project.
    """
    if api_key.project_id != project_id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Access denied. API key does not have access to this project."
        )
    return project_id
