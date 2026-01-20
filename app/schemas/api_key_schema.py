from datetime import datetime
from typing import Optional
from pydantic import BaseModel, Field, ConfigDict


class APIKeyCreate(BaseModel):
    """Schema for creating a new API key"""
    name: str = Field(..., min_length=1, max_length=100)
    description: Optional[str] = Field(None, max_length=500)
    expires_at: Optional[datetime] = None


class APIKeyResponse(BaseModel):
    """Schema for API key response"""
    model_config = ConfigDict(from_attributes=True)

    id: int
    project_id: int
    name: str
    description: Optional[str]
    is_active: bool
    created_at: datetime
    expires_at: Optional[datetime]
    last_used_at: Optional[datetime]
    usage_count: int


class APIKeyWithSecret(APIKeyResponse):
    """Schema for API key response that includes the secret key value (only shown once at creation)"""
    key_value: str


class APIKeyListResponse(BaseModel):
    """Schema for API key list response"""
    project_id: int
    total: int
    items: list[APIKeyResponse]
