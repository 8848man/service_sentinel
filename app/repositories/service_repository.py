from typing import Optional
from sqlalchemy.orm import Session
from sqlalchemy import and_

from app.models.service import Service, ServiceType
from app.schemas.service_schema import ServiceCreate, ServiceUpdate


class ServiceRepository:
    def __init__(self, db: Session):
        self.db = db

    def create(self, project_id: int, data: ServiceCreate) -> Service:
        """Create a service within a project"""
        service = Service(**data.model_dump(exclude_unset=True, mode='json'))
        # Convert HttpUrl to string
        service.endpoint_url = str(data.endpoint_url)
        service.project_id = project_id
        self.db.add(service)
        self.db.commit()
        self.db.refresh(service)
        return service

    def find_by_id(self, service_id: int, project_id: Optional[int] = None) -> Optional[Service]:
        """Find service by ID, optionally scoped to project"""
        query = self.db.query(Service).filter(Service.id == service_id)
        if project_id is not None:
            query = query.filter(Service.project_id == project_id)
        return query.first()

    def find_all(
        self,
        project_id: Optional[int] = None,
        is_active: Optional[bool] = None,
        service_type: Optional[ServiceType] = None,
        skip: int = 0,
        limit: int = 100
    ) -> list[Service]:
        """Find all services, optionally scoped to project"""
        query = self.db.query(Service)

        if project_id is not None:
            query = query.filter(Service.project_id == project_id)
        if is_active is not None:
            query = query.filter(Service.is_active == is_active)
        if service_type:
            query = query.filter(Service.service_type == service_type)

        return query.offset(skip).limit(limit).all()

    def find_active_for_monitoring(self) -> list[Service]:
        """Get all services that should be monitored"""
        return self.db.query(Service).filter(Service.is_active == True).all()

    def update(self, service_id: int, data: ServiceUpdate) -> Optional[Service]:
        service = self.find_by_id(service_id)
        if not service:
            return None

        update_data = data.model_dump(exclude_unset=True)

        # Convert HttpUrl to string if present
        if 'endpoint_url' in update_data:
            update_data['endpoint_url'] = str(update_data['endpoint_url'])

        for key, value in update_data.items():
            setattr(service, key, value)

        self.db.commit()
        self.db.refresh(service)
        return service

    def delete(self, service_id: int) -> bool:
        service = self.find_by_id(service_id)
        if not service:
            return False

        self.db.delete(service)
        self.db.commit()
        return True

    def count_all(self) -> int:
        return self.db.query(Service).count()

    def count_by_status(self, is_active: bool) -> int:
        return self.db.query(Service).filter(Service.is_active == is_active).count()