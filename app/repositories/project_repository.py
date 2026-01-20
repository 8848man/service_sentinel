from typing import Optional
from sqlalchemy.orm import Session

from app.models.project import Project


class ProjectRepository:
    """Repository for Project aggregate root operations"""

    def __init__(self, db: Session):
        self.db = db

    def create(self, name: str, description: Optional[str] = None) -> Project:
        """Create a new project"""
        project = Project(
            name=name,
            description=description,
            is_active=True
        )
        self.db.add(project)
        self.db.commit()
        self.db.refresh(project)
        return project

    def find_by_id(self, project_id: int) -> Optional[Project]:
        """Find project by ID"""
        return self.db.query(Project).filter(Project.id == project_id).first()

    def find_all(
        self,
        is_active: Optional[bool] = None,
        skip: int = 0,
        limit: int = 100
    ) -> list[Project]:
        """Find all projects with optional filtering"""
        query = self.db.query(Project)

        if is_active is not None:
            query = query.filter(Project.is_active == is_active)

        return query.order_by(Project.created_at.desc()).offset(skip).limit(limit).all()

    def update(self, project_id: int, **kwargs) -> Optional[Project]:
        """Update project"""
        project = self.find_by_id(project_id)
        if not project:
            return None

        for key, value in kwargs.items():
            if hasattr(project, key) and value is not None:
                setattr(project, key, value)

        self.db.commit()
        self.db.refresh(project)
        return project

    def delete(self, project_id: int) -> bool:
        """Delete project and all associated data (cascade)"""
        project = self.find_by_id(project_id)
        if not project:
            return False

        self.db.delete(project)
        self.db.commit()
        return True

    def count(self, is_active: Optional[bool] = None) -> int:
        """Count projects"""
        query = self.db.query(Project)

        if is_active is not None:
            query = query.filter(Project.is_active == is_active)

        return query.count()
