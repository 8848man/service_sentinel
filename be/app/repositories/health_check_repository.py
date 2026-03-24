from datetime import datetime, timedelta
from typing import Optional
from sqlalchemy.orm import Session
from sqlalchemy import desc, and_, func, text

from app.models.health_check import HealthCheck


class HealthCheckRepository:
    def __init__(self, db: Session):
        self.db = db

    def create(self, data: dict) -> HealthCheck:
        health_check = HealthCheck(**data)
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

    def get_latency_series(
        self,
        service_id: int,
        since: datetime,
        bucket_minutes: int,
    ) -> list[dict]:
        """
        Return time-bucketed latency aggregates for a service.

        Each dict in the returned list contains:
            bucket_start  – start of the time bucket (datetime)
            avg_ms        – average latency for the bucket (float)
            p95_ms        – 95th-percentile latency (float, PostgreSQL only)
            sample_count  – number of health checks in the bucket (int)

        Note: percentile_cont is PostgreSQL-specific. Running against SQLite
        will raise an OperationalError.
        """
        sql = text(
            """
            SELECT
                date_trunc('minute', checked_at)
                    - (EXTRACT(MINUTE FROM checked_at)::int % :bucket_minutes)
                      * INTERVAL '1 minute'                          AS bucket_start,
                AVG(latency_ms)                                      AS avg_ms,
                percentile_cont(0.95) WITHIN GROUP (ORDER BY latency_ms) AS p95_ms,
                COUNT(*)                                             AS sample_count
            FROM health_checks
            WHERE service_id = :service_id
              AND checked_at  >= :since
            GROUP BY bucket_start
            ORDER BY bucket_start
            """
        )
        rows = self.db.execute(
            sql,
            {
                "service_id": service_id,
                "since": since,
                "bucket_minutes": bucket_minutes,
            },
        ).fetchall()

        return [
            {
                "bucket_start": row.bucket_start,
                "avg_ms": float(row.avg_ms) if row.avg_ms is not None else 0.0,
                "p95_ms": float(row.p95_ms) if row.p95_ms is not None else 0.0,
                "sample_count": row.sample_count,
            }
            for row in rows
        ]