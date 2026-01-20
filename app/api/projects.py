from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session
from sqlalchemy import func

from app.core.database import get_db
from app.repositories.project_repository import ProjectRepository
from app.repositories.api_key_repository import APIKeyRepository
from app.models.service import Service
from app.models.incident import Incident, IncidentStatus
from app.schemas.project_schema import (
    ProjectCreate,
    ProjectResponse,
    ProjectUpdate,
    ProjectWithStats
)
from app.schemas.api_key_schema import (
    APIKeyCreate,
    APIKeyResponse,
    APIKeyWithSecret,
    APIKeyListResponse
)

router = APIRouter(prefix="/projects", tags=["Projects"])


@router.post("", response_model=ProjectResponse, status_code=status.HTTP_201_CREATED)
def create_project(
    request: ProjectCreate,
    db: Session = Depends(get_db),
):
    """
    Create a new project.
    This is the first step in setting up monitoring.
    """
    repo = ProjectRepository(db)
    return repo.create(name=request.name, description=request.description)


@router.get("", response_model=list[ProjectResponse])
def list_projects(
    is_active: bool = Query(default=None),
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=1000),
    db: Session = Depends(get_db)
):
    """
    List all projects with optional filtering.
    No authentication required for listing (add auth if needed).
    """
    repo = ProjectRepository(db)
    return repo.find_all(is_active=is_active, skip=skip, limit=limit)


@router.get("/{project_id}", response_model=ProjectResponse)
def get_project(
    project_id: int,
    db: Session = Depends(get_db),
):
    """Get project by ID"""
    repo = ProjectRepository(db)
    project = repo.find_by_id(project_id)

    if not project:
        raise HTTPException(status_code=404, detail="Project not found")

    return project


@router.get("/{project_id}/stats", response_model=ProjectWithStats)
def get_project_stats(
    project_id: int,
    db: Session = Depends(get_db),
):
    """Get project with statistics"""
    repo = ProjectRepository(db)
    project = repo.find_by_id(project_id)

    if not project:
        raise HTTPException(status_code=404, detail="Project not found")

    # Calculate stats
    total_services = db.query(func.count(Service.id)).filter(
        Service.project_id == project_id
    ).scalar()

    active_services = db.query(func.count(Service.id)).filter(
        Service.project_id == project_id,
        Service.is_active == True
    ).scalar()

    total_incidents = db.query(func.count(Incident.id)).join(Service).filter(
        Service.project_id == project_id
    ).scalar()

    open_incidents = db.query(func.count(Incident.id)).join(Service).filter(
        Service.project_id == project_id,
        Incident.status.in_([IncidentStatus.OPEN, IncidentStatus.INVESTIGATING])
    ).scalar()

    return ProjectWithStats(
        **project.__dict__,
        total_services=total_services or 0,
        active_services=active_services or 0,
        total_incidents=total_incidents or 0,
        open_incidents=open_incidents or 0
    )


@router.patch("/{project_id}", response_model=ProjectResponse)
def update_project(
    project_id: int,
    data: ProjectUpdate,
    db: Session = Depends(get_db),
):
    """Update project"""
    repo = ProjectRepository(db)
    project = repo.update(project_id, **data.model_dump(exclude_unset=True))

    if not project:
        raise HTTPException(status_code=404, detail="Project not found")

    return project


@router.delete("/{project_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_project(
    project_id: int,
    db: Session = Depends(get_db),
):
    """
    Delete a project and ALL associated data (services, health checks, incidents).
    This is a destructive operation and cannot be undone.
    """
    repo = ProjectRepository(db)
    success = repo.delete(project_id)

    if not success:
        raise HTTPException(status_code=404, detail="Project not found")


# ===== API Key Management =====

@router.post("/{project_id}/api-keys", response_model=APIKeyWithSecret, status_code=status.HTTP_201_CREATED)
def create_api_key(
    project_id: int,
    request: APIKeyCreate,
    db: Session = Depends(get_db),
):
    """
    Create a new API key for a project.
    The key_value will ONLY be shown in this response - store it securely!
    """
    # Verify project exists
    project_repo = ProjectRepository(db)
    project = project_repo.find_by_id(project_id)
    if not project:
        raise HTTPException(status_code=404, detail="Project not found")

    # Create API key
    repo = APIKeyRepository(db)
    api_key = repo.create(
        project_id=project_id,
        name=request.name,
        description=request.description,
        expires_at=request.expires_at
    )

    return api_key


@router.get("/{project_id}/api-keys", response_model=APIKeyListResponse)
def list_project_api_keys(
    project_id: int,
    is_active: bool = Query(default=None),
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=1000),
    db: Session = Depends(get_db)
):
    """List all API keys for a project (without revealing key values)"""
    # Verify project exists
    project_repo = ProjectRepository(db)
    project = project_repo.find_by_id(project_id)
    if not project:
        raise HTTPException(status_code=404, detail="Project not found")

    repo = APIKeyRepository(db)
    keys = repo.find_all_for_project(project_id, is_active=is_active, skip=skip, limit=limit)

    return APIKeyListResponse(
        project_id=project_id,
        total=len(keys),
        items=keys
    )


@router.delete("/{project_id}/api-keys/{key_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_api_key(
    project_id: int,
    key_id: int,
    db: Session = Depends(get_db),
):
    """Delete an API key"""
    repo = APIKeyRepository(db)
    api_key = repo.find_by_id(key_id)

    if not api_key:
        raise HTTPException(status_code=404, detail="API key not found")

    if api_key.project_id != project_id:
        raise HTTPException(status_code=403, detail="API key does not belong to this project")

    repo.delete(key_id)


@router.post("/{project_id}/api-keys/{key_id}/deactivate", response_model=APIKeyResponse)
def deactivate_api_key(
    project_id: int,
    key_id: int,
    db: Session = Depends(get_db),
):
    """Deactivate an API key (soft delete)"""
    repo = APIKeyRepository(db)
    api_key = repo.find_by_id(key_id)

    if not api_key:
        raise HTTPException(status_code=404, detail="API key not found")

    if api_key.project_id != project_id:
        raise HTTPException(status_code=403, detail="API key does not belong to this project")

    api_key = repo.deactivate(key_id)
    return api_key
