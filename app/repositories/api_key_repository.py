from typing import Optional
from datetime import datetime
from sqlalchemy.orm import Session

from app.models.api_key import APIKey, generate_api_key


class APIKeyRepository:
    """Repository for APIKey operations"""

    def __init__(self, db: Session):
        self.db = db

    def create(
        self,
        project_id: int,
        name: str,
        description: Optional[str] = None,
        expires_at: Optional[datetime] = None
    ) -> APIKey:
        """Create a new API key for a project"""
        api_key = APIKey(
            project_id=project_id,
            key_value=generate_api_key(),
            name=name,
            description=description,
            is_active=True,
            expires_at=expires_at
        )
        self.db.add(api_key)
        self.db.commit()
        self.db.refresh(api_key)
        return api_key

    def find_by_key_value(self, key_value: str) -> Optional[APIKey]:
        """Find API key by its value (for authentication)"""
        return self.db.query(APIKey).filter(
            APIKey.key_value == key_value
        ).first()

    def find_by_id(self, api_key_id: int) -> Optional[APIKey]:
        """Find API key by ID"""
        return self.db.query(APIKey).filter(APIKey.id == api_key_id).first()

    def find_all_for_project(
        self,
        project_id: int,
        is_active: Optional[bool] = None,
        skip: int = 0,
        limit: int = 100
    ) -> list[APIKey]:
        """Find all API keys for a project"""
        query = self.db.query(APIKey).filter(APIKey.project_id == project_id)

        if is_active is not None:
            query = query.filter(APIKey.is_active == is_active)

        return query.order_by(APIKey.created_at.desc()).offset(skip).limit(limit).all()

    def update_last_used(self, api_key_id: int) -> None:
        """Update last used timestamp and increment usage count"""
        api_key = self.find_by_id(api_key_id)
        if api_key:
            api_key.last_used_at = datetime.utcnow()
            api_key.usage_count += 1
            self.db.commit()

    def deactivate(self, api_key_id: int) -> Optional[APIKey]:
        """Deactivate an API key"""
        api_key = self.find_by_id(api_key_id)
        if not api_key:
            return None

        api_key.is_active = False
        self.db.commit()
        self.db.refresh(api_key)
        return api_key

    def delete(self, api_key_id: int) -> bool:
        """Delete an API key"""
        api_key = self.find_by_id(api_key_id)
        if not api_key:
            return False

        self.db.delete(api_key)
        self.db.commit()
        return True
