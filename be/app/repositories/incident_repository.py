from datetime import datetime
from typing import Optional
from sqlalchemy.orm import Session
from sqlalchemy import and_, desc, or_

from app.models.incident import Incident, IncidentStatus, IncidentSeverity


class IncidentRepository:
    def __init__(self, db: Session):
        self.db = db

    def create(self, data: dict) -> Incident:
        incident = Incident(**data)
        self.db.add(incident)
        self.db.commit()
        self.db.refresh(incident)
        return incident

    def find_by_id(self, incident_id: int) -> Optional[Incident]:
        return self.db.query(Incident).filter(Incident.id == incident_id).first()

    def find_open_incident_for_service(self, service_id: int) -> Optional[Incident]:
        """Find if there's already an open incident for this service"""
        return (
            self.db.query(Incident)
            .filter(
                and_(
                    Incident.service_id == service_id,
                    Incident.status.in_([IncidentStatus.OPEN, IncidentStatus.INVESTIGATING])
                )
            )
            .order_by(desc(Incident.detected_at))
            .first()
        )

    def find_all(
        self,
        status: Optional[IncidentStatus] = None,
        severity: Optional[IncidentSeverity] = None,
        service_id: Optional[int] = None,
        since: Optional[datetime] = None,
        skip: int = 0,
        limit: int = 100
    ) -> list[Incident]:
        query = self.db.query(Incident)

        if status:
            query = query.filter(Incident.status == status)
        if severity:
            query = query.filter(Incident.severity == severity)
        if service_id:
            query = query.filter(Incident.service_id == service_id)
        if since:
            query = query.filter(Incident.detected_at >= since)

        return query.order_by(desc(Incident.detected_at)).offset(skip).limit(limit).all()

    def count_all(
        self,
        status: Optional[IncidentStatus] = None,
        severity: Optional[IncidentSeverity] = None
    ) -> int:
        query = self.db.query(Incident)

        if status:
            query = query.filter(Incident.status == status)
        if severity:
            query = query.filter(Incident.severity == severity)

        return query.count()

    def update_status(
        self,
        incident_id: int,
        status: IncidentStatus,
        resolved_at: Optional[datetime] = None,
        acknowledged_at: Optional[datetime] = None
    ) -> Optional[Incident]:
        incident = self.find_by_id(incident_id)
        if not incident:
            return None

        incident.status = status

        if status == IncidentStatus.RESOLVED and resolved_at:
            incident.resolved_at = resolved_at
        if status == IncidentStatus.ACKNOWLEDGED and acknowledged_at:
            incident.acknowledged_at = acknowledged_at

        self.db.commit()
        self.db.refresh(incident)
        return incident

    def increment_failure_count(self, incident_id: int) -> None:
        """Increment consecutive failures for an existing incident"""
        incident = self.find_by_id(incident_id)
        if incident:
            incident.consecutive_failures += 1
            incident.total_affected_checks += 1
            self.db.commit()

    def update(self, incident_id: int, **kwargs) -> Optional[Incident]:
        incident = self.find_by_id(incident_id)
        if not incident:
            return None

        for key, value in kwargs.items():
            if hasattr(incident, key) and value is not None:
                setattr(incident, key, value)

        self.db.commit()
        self.db.refresh(incident)
        return incident

    def find_all_by_service_ids(
        self,
        service_ids: list[int],
        status: Optional[IncidentStatus] = None,
        severity: Optional[IncidentSeverity] = None,
        service_id: Optional[int] = None,
        skip: int = 0,
        limit: int = 100
    ) -> list[Incident]:
        """Find incidents for a list of service IDs (for project-scoped queries)"""
        if not service_ids:
            return []

        query = self.db.query(Incident).filter(Incident.service_id.in_(service_ids))

        if status:
            query = query.filter(Incident.status == status)
        if severity:
            query = query.filter(Incident.severity == severity)
        if service_id:
            query = query.filter(Incident.service_id == service_id)

        return query.order_by(desc(Incident.detected_at)).offset(skip).limit(limit).all()
