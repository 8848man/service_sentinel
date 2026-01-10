from datetime import datetime, timedelta
from typing import Optional
from sqlalchemy.orm import Session
from sqlalchemy import desc, and_, func

from app.models.health_check import HealthCheck
from app.schemas.health_check_schema import HealthCheckCreate


class HealthCheckRepository:
    def __init__(self, db: Session):
        self.db = db

    def create(self, data: dict | HealthCheckCreate) -> HealthCheck:
        if isinstance(data, dict):
            health_check = HealthCheck(**data)
        else:
            health_check = HealthCheck(**data.model_dump())

        self.db.add(health_check)
        self.db.commit()
        self.db.refresh(health_check)
        return health_check

    def find_by_id(self, check_id: int) -> Optional[HealthCheck]:
        return self.db.query(HealthCheck).filter(HealthCheck.id == check_id).first()

    def find_recent_for_service(
        self,
        service_id: int,
        limit: int = 10
    ) -> list[HealthCheck]:
        return (
            self.db.query(HealthCheck)
            .filter(HealthCheck.service_id == service_id)
            .order_by(desc(HealthCheck.checked_at))
            .limit(limit)
            .all()
        )

    def find_latest_for_service(self, service_id: int) -> Optional[HealthCheck]:
        return (
            self.db.query(HealthCheck)
            .filter(HealthCheck.service_id == service_id)
            .order_by(desc(HealthCheck.checked_at))
            .first()
        )

    def count_failures_since(self, service_id: int, since: datetime) -> int:
        return (
            self.db.query(HealthCheck)
            .filter(
                and_(
                    HealthCheck.service_id == service_id,
                    HealthCheck.is_alive == False,
                    HealthCheck.checked_at >= since
                )
            )
            .count()
        )

    def get_stats_for_service(
        self,
        service_id: int,
        since: Optional[datetime] = None
    ) -> dict:
        query = self.db.query(HealthCheck).filter(HealthCheck.service_id == service_id)

        if since:
            query = query.filter(HealthCheck.checked_at >= since)

        total = query.count()
        if total == 0:
            return {
                "total_checks": 0,
                "successful_checks": 0,
                "failed_checks": 0,
                "uptime_percentage": 0.0,
                "avg_latency_ms": 0.0
            }

        successful = query.filter(HealthCheck.is_alive == True).count()
        failed = total - successful

        avg_latency = query.with_entities(
            func.avg(HealthCheck.latency_ms)
        ).scalar() or 0.0

        uptime_percentage = (successful / total * 100) if total > 0 else 0.0

        return {
            "total_checks": total,
            "successful_checks": successful,
            "failed_checks": failed,
            "uptime_percentage": round(uptime_percentage, 2),
            "avg_latency_ms": round(avg_latency, 2)
        }

    def find_all_for_service(
        self,
        service_id: int,
        skip: int = 0,
        limit: int = 100
    ) -> list[HealthCheck]:
        return (
            self.db.query(HealthCheck)
            .filter(HealthCheck.service_id == service_id)
            .order_by(desc(HealthCheck.checked_at))
            .offset(skip)
            .limit(limit)
            .all()
        )

    def count_for_service(self, service_id: int) -> int:
        return self.db.query(HealthCheck).filter(HealthCheck.service_id == service_id).count()