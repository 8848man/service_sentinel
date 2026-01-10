from datetime import datetime
from typing import Optional
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.models.incident import IncidentStatus, IncidentSeverity
from app.repositories.incident_repository import IncidentRepository
from app.repositories.ai_analysis_repository import AIAnalysisRepository
from app.schemas.incident_schema import (
    IncidentResponse,
    IncidentWithService,
    IncidentListResponse,
    IncidentUpdate
)
from app.schemas.ai_analysis_schema import AIAnalysisRequest, AIAnalysisResponse
from app.services.ai_analysis_service import AIAnalysisService

router = APIRouter(prefix="/incidents", tags=["Incidents"])


@router.get("", response_model=IncidentListResponse)
def get_incidents(
    status: Optional[IncidentStatus] = None,
    severity: Optional[IncidentSeverity] = None,
    service_id: Optional[int] = None,
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=1000),
    db: Session = Depends(get_db),
):
    """Get all incidents with filtering"""
    repo = IncidentRepository(db)
    incidents = repo.find_all(
        status=status,
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

    total = repo.count_all(status=status, severity=severity)

    return IncidentListResponse(total=total, items=items_with_service)


@router.get("/{incident_id}", response_model=IncidentResponse)
def get_incident(
    incident_id: int,
    db: Session = Depends(get_db),
):
    """Get incident by ID"""
    repo = IncidentRepository(db)
    incident = repo.find_by_id(incident_id)

    if not incident:
        raise HTTPException(status_code=404, detail="Incident not found")

    return incident


@router.patch("/{incident_id}", response_model=IncidentResponse)
def update_incident(
    incident_id: int,
    data: IncidentUpdate,
    db: Session = Depends(get_db),
):
    """Update incident"""
    repo = IncidentRepository(db)

    update_kwargs = data.model_dump(exclude_unset=True)
    incident = repo.update(incident_id, **update_kwargs)

    if not incident:
        raise HTTPException(status_code=404, detail="Incident not found")

    return incident


@router.post("/{incident_id}/acknowledge", response_model=IncidentResponse)
def acknowledge_incident(
    incident_id: int,
    db: Session = Depends(get_db),
):
    """Mark incident as acknowledged"""
    repo = IncidentRepository(db)
    incident = repo.update_status(
        incident_id,
        IncidentStatus.ACKNOWLEDGED,
        acknowledged_at=datetime.utcnow()
    )

    if not incident:
        raise HTTPException(status_code=404, detail="Incident not found")

    return incident


@router.post("/{incident_id}/resolve", response_model=IncidentResponse)
def resolve_incident(
    incident_id: int,
    db: Session = Depends(get_db),
):
    """Mark incident as resolved"""
    repo = IncidentRepository(db)
    incident = repo.update_status(
        incident_id,
        IncidentStatus.RESOLVED,
        resolved_at=datetime.utcnow()
    )

    if not incident:
        raise HTTPException(status_code=404, detail="Incident not found")

    return incident


@router.get("/{incident_id}/analysis", response_model=AIAnalysisResponse)
def get_incident_analysis(
    incident_id: int,
    db: Session = Depends(get_db),
):
    """Get AI analysis for incident"""
    incident_repo = IncidentRepository(db)
    incident = incident_repo.find_by_id(incident_id)

    if not incident:
        raise HTTPException(status_code=404, detail="Incident not found")

    analysis_repo = AIAnalysisRepository(db)
    analysis = analysis_repo.find_by_incident_id(incident_id)

    if not analysis:
        raise HTTPException(
            status_code=404,
            detail="AI analysis not found. Use POST to request analysis."
        )

    return analysis


@router.post("/{incident_id}/analysis", response_model=AIAnalysisResponse)
async def request_incident_analysis(
    incident_id: int,
    request: AIAnalysisRequest = AIAnalysisRequest(),
    db: Session = Depends(get_db),
):
    """Request AI analysis for incident"""
    incident_repo = IncidentRepository(db)
    incident = incident_repo.find_by_id(incident_id)

    if not incident:
        raise HTTPException(status_code=404, detail="Incident not found")

    ai_service = AIAnalysisService(db)
    analysis = await ai_service.analyze_incident(incident, request.force_reanalyze)

    if not analysis:
        raise HTTPException(
            status_code=500,
            detail="Failed to generate AI analysis. Check if AI is enabled and configured."
        )

    return analysis
