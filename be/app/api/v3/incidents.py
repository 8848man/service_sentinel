from datetime import datetime
from typing import Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.auth_v3 import get_auth_context, verify_project_ownership
from app.models.incident import IncidentStatus, IncidentSeverity
from app.repositories.incident_repository import IncidentRepository
from app.repositories.service_repository import ServiceRepository
from app.repositories.ai_analysis_repository import AIAnalysisRepository
from app.schemas.auth_context_schema import AuthContext
from app.schemas.incident_schema import (
    IncidentResponse,
    IncidentWithService,
    IncidentListResponse,
    IncidentUpdate
)
from app.schemas.ai_analysis_schema import AIAnalysisRequest, AIAnalysisResponse
from app.services.ai_analysis_service import AIAnalysisService

router = APIRouter(prefix="/projects/{project_id}", tags=["Incidents (v3)"])


@router.get("/incidents", response_model=IncidentListResponse)
async def get_incidents(
    project_id: int,
    status_filter: Optional[IncidentStatus] = Query(None, alias="status"),
    severity: Optional[IncidentSeverity] = None,
    service_id: Optional[int] = None,
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=1000),
    auth_context: AuthContext = Depends(get_auth_context),
    db: Session = Depends(get_db),
):
    """
    Get all incidents for the project.
    Requires project ownership.
    """
    # Verify project ownership
    await verify_project_ownership(auth_context, db)

    # Get all service IDs for this project using repository
    service_repo = ServiceRepository(db)
    service_ids = service_repo.get_service_ids_by_project(project_id)

    if not service_ids:
        return IncidentListResponse(total=0, items=[])

    # If service_id is specified, verify it belongs to project
    if service_id and service_id not in service_ids:
        raise HTTPException(status_code=404, detail="Service not found in this project")

    # Get incidents using repository method that filters by service_ids
    incident_repo = IncidentRepository(db)
    incidents = incident_repo.find_all_by_service_ids(
        service_ids=service_ids,
        status=status_filter,
        severity=severity,
        service_id=service_id,
        skip=skip,
        limit=limit
    )

    # Add service names
    items_with_service = []
    for incident in incidents:
        item = IncidentWithService(
            **incident.__dict__,
            service_name=incident.service.name
        )
        items_with_service.append(item)

    total = len(items_with_service)

    return IncidentListResponse(total=total, items=items_with_service)


@router.get("/incidents/{incident_id}", response_model=IncidentResponse)
async def get_incident(
    incident_id: int,
    project_id: int,
    auth_context: AuthContext = Depends(get_auth_context),
    db: Session = Depends(get_db),
):
    """
    Get incident by ID.
    Requires project ownership.
    """
    # Verify project ownership
    await verify_project_ownership(auth_context, db)

    repo = IncidentRepository(db)
    incident = repo.find_by_id(incident_id)

    if not incident:
        raise HTTPException(status_code=404, detail="Incident not found")

    # Verify incident belongs to a service in this project
    if incident.service.project_id != project_id:
        raise HTTPException(status_code=404, detail="Incident not found")

    return incident


@router.patch("/incidents/{incident_id}", response_model=IncidentResponse)
async def update_incident(
    incident_id: int,
    data: IncidentUpdate,
    project_id: int,
    auth_context: AuthContext = Depends(get_auth_context),
    db: Session = Depends(get_db),
):
    """
    Update incident.
    Requires project ownership.
    """
    # Verify project ownership
    await verify_project_ownership(auth_context, db)

    repo = IncidentRepository(db)
    incident = repo.find_by_id(incident_id)

    if not incident:
        raise HTTPException(status_code=404, detail="Incident not found")

    # Verify incident belongs to a service in this project
    if incident.service.project_id != project_id:
        raise HTTPException(status_code=404, detail="Incident not found")

    update_kwargs = data.model_dump(exclude_unset=True)
    incident = repo.update(incident_id, **update_kwargs)

    return incident


@router.post("/incidents/{incident_id}/acknowledge", response_model=IncidentResponse)
async def acknowledge_incident(
    incident_id: int,
    project_id: int,
    auth_context: AuthContext = Depends(get_auth_context),
    db: Session = Depends(get_db),
):
    """
    Mark incident as acknowledged.
    Requires project ownership.
    """
    # Verify project ownership
    await verify_project_ownership(auth_context, db)

    repo = IncidentRepository(db)
    incident = repo.find_by_id(incident_id)

    if not incident:
        raise HTTPException(status_code=404, detail="Incident not found")

    # Verify incident belongs to a service in this project
    if incident.service.project_id != project_id:
        raise HTTPException(status_code=404, detail="Incident not found")

    incident = repo.update_status(
        incident_id,
        IncidentStatus.ACKNOWLEDGED,
        acknowledged_at=datetime.utcnow()
    )

    return incident


@router.post("/incidents/{incident_id}/resolve", response_model=IncidentResponse)
async def resolve_incident(
    incident_id: int,
    project_id: int,
    auth_context: AuthContext = Depends(get_auth_context),
    db: Session = Depends(get_db),
):
    """
    Mark incident as resolved.
    Requires project ownership.
    """
    # Verify project ownership
    await verify_project_ownership(auth_context, db)

    repo = IncidentRepository(db)
    incident = repo.find_by_id(incident_id)

    if not incident:
        raise HTTPException(status_code=404, detail="Incident not found")

    # Verify incident belongs to a service in this project
    if incident.service.project_id != project_id:
        raise HTTPException(status_code=404, detail="Incident not found")

    incident = repo.update_status(
        incident_id,
        IncidentStatus.RESOLVED,
        resolved_at=datetime.utcnow()
    )

    return incident


@router.get("/incidents/{incident_id}/analysis", response_model=AIAnalysisResponse)
async def get_incident_analysis(
    incident_id: int,
    project_id: int,
    auth_context: AuthContext = Depends(get_auth_context),
    db: Session = Depends(get_db),
):
    """
    Get AI analysis for incident.
    Requires project ownership.
    """
    # Verify project ownership
    await verify_project_ownership(auth_context, db)

    incident_repo = IncidentRepository(db)
    incident = incident_repo.find_by_id(incident_id)

    if not incident:
        raise HTTPException(status_code=404, detail="Incident not found")

    # Verify incident belongs to a service in this project
    if incident.service.project_id != project_id:
        raise HTTPException(status_code=404, detail="Incident not found")

    analysis_repo = AIAnalysisRepository(db)
    analysis = analysis_repo.find_by_incident_id(incident_id)

    if not analysis:
        raise HTTPException(
            status_code=404,
            detail="AI analysis not found. Use POST to request analysis."
        )

    return analysis


@router.post("/incidents/{incident_id}/analysis", response_model=AIAnalysisResponse)
async def request_incident_analysis(
    project_id: int,
    incident_id: int,
    request: AIAnalysisRequest = AIAnalysisRequest(),
    auth_context: AuthContext = Depends(get_auth_context),
    db: Session = Depends(get_db),
):
    """
    Request AI analysis for incident.
    Requires project ownership.
    """
    # Verify project ownership
    await verify_project_ownership(auth_context, db)

    incident_repo = IncidentRepository(db)
    incident = incident_repo.find_by_id(incident_id)

    if not incident:
        raise HTTPException(status_code=404, detail="Incident not found")

    # Verify incident belongs to a service in this project
    if incident.service.project_id != project_id:
        raise HTTPException(status_code=404, detail="Incident not found")

    ai_service = AIAnalysisService(db)
    analysis = await ai_service.analyze_incident(incident, request.force_reanalyze)

    if not analysis:
        raise HTTPException(
            status_code=500,
            detail="Failed to generate AI analysis. Check if AI is enabled and configured."
        )

    return analysis
